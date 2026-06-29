import 'package:flutter/foundation.dart';
import 'package:car_wash_app/data/models/vendor.dart';
import 'package:car_wash_app/data/models/order.dart';
import 'package:car_wash_app/data/models/service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:car_wash_app/dependency_injection/injection_container.dart';
import 'package:car_wash_app/data/repositories/auth_repository.dart';

class VendorViewModel extends ChangeNotifier {
  // State variables
  Vendor? _vendorProfile;
  List<Order> _vendorOrders = [];
  List<Service> _vendorServices = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _totalEarnings = 0;
  int _totalOrders = 0;

  // Getters
  Vendor? get vendorProfile => _vendorProfile;
  List<Order> get vendorOrders => _vendorOrders;
  List<Service> get vendorServices => _vendorServices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalEarnings => _totalEarnings;
  int get totalOrders => _totalOrders;

  // Fetch vendor profile
  Future<void> fetchVendorProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = getIt<AuthRepository>().getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final doc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        _vendorProfile = Vendor.fromJson(data);
      } else {
        // If no vendor profile exists yet, we might want to create one or handle it
        _errorMessage = 'Vendor profile not found';
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get vendor dashboard data
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_vendorProfile == null) {
        await fetchVendorProfile();
      }
      
      _totalOrders = _vendorProfile?.orderCount ?? 0;
      _totalEarnings = _vendorProfile?.totalEarnings ?? 0.0;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get vendor orders
  Future<void> getVendorOrders({
    String? status,
    int page = 1,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authUserId = getIt<AuthRepository>().getUserId();
      if (authUserId == null) {
        throw Exception('User not logged in');
      }

      // Match both current and legacy schemas/IDs so existing orders still show.
      final candidateVendorIds = <String>{authUserId};
      if (_vendorProfile != null) {
        candidateVendorIds.add(_vendorProfile!.id);
        candidateVendorIds.add(_vendorProfile!.userId);
      }

      final orderMap = <String, Order>{};

      Future<void> collectByField(String fieldName, String vendorId) async {
        final results = await _queryOrdersByVendorField(
          fieldName: fieldName,
          vendorId: vendorId,
          status: status,
        );
        for (final order in results) {
          orderMap[order.id] = order;
        }
      }

      // Primary schema
      for (final vendorId in candidateVendorIds) {
        await collectByField('vendor_id', vendorId);
      }

      // Legacy/camelCase schema fallback
      if (orderMap.isEmpty) {
        for (final vendorId in candidateVendorIds) {
          await collectByField('vendorId', vendorId);
        }
      }

      // Fallback: infer by service ownership when order vendor field is inconsistent.
      if (orderMap.isEmpty) {
        final ownedServiceIds = await _getOwnedServiceIds(candidateVendorIds.toList());
        if (ownedServiceIds.isNotEmpty) {
          final inferredOrders = await _queryOrdersByServiceIds(
            serviceIds: ownedServiceIds,
            status: status,
          );
          for (final order in inferredOrders) {
            orderMap[order.id] = order;
          }
        }
      }

      // Last-resort fallback for inconsistent historical data:
      // load by status only and show latest records.
      if (orderMap.isEmpty) {
        Query<Map<String, dynamic>> query =
            FirebaseFirestore.instance.collection('orders');
        if (status != null && status != 'all') {
          query = query.where('status', isEqualTo: status);
        }

        final snapshot = await query.get();
        for (final order in _mapOrders(snapshot.docs)) {
          orderMap[order.id] = order;
        }
      }

      _vendorOrders = orderMap.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error fetching vendor orders: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Order>> _queryOrdersByVendorField({
    required String fieldName,
    required String vendorId,
    String? status,
  }) async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('orders')
        .where(fieldName, isEqualTo: vendorId);

    if (status != null && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();

    return _mapOrders(snapshot.docs);
  }

  Future<List<String>> _getOwnedServiceIds(List<String> vendorIds) async {
    final serviceIds = <String>{};

    for (final vendorId in vendorIds) {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await FirebaseFirestore.instance
            .collection('services')
            .where('vendor_id', isEqualTo: vendorId)
            .get();
      } catch (_) {
        continue;
      }

      if (snapshot.docs.isEmpty) {
        try {
          snapshot = await FirebaseFirestore.instance
              .collection('services')
              .where('vendorId', isEqualTo: vendorId)
              .get();
        } catch (_) {
          continue;
        }
      }

      for (final doc in snapshot.docs) {
        serviceIds.add(doc.id);
      }
    }

    return serviceIds.toList();
  }

  Future<List<Order>> _queryOrdersByServiceIds({
    required List<String> serviceIds,
    String? status,
  }) async {
    final orders = <Order>[];
    final chunks = <List<String>>[];

    for (var i = 0; i < serviceIds.length; i += 10) {
      final end = (i + 10 < serviceIds.length) ? i + 10 : serviceIds.length;
      chunks.add(serviceIds.sublist(i, end));
    }

    for (final chunk in chunks) {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('orders')
          .where('service_id', whereIn: chunk);

      if (status != null && status != 'all') {
        query = query.where('status', isEqualTo: status);
      }

      QuerySnapshot<Map<String, dynamic>> snapshot;
      snapshot = await query.get();

      orders.addAll(_mapOrders(snapshot.docs));
    }

    return orders;
  }

  List<Order> _mapOrders(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final orders = <Order>[];

    for (final doc in docs) {
      try {
        final data = doc.data();
        data['id'] = doc.id;
        orders.add(Order.fromJson(data));
      } catch (e) {
        debugPrint('Skipping invalid order document ${doc.id}: $e');
      }
    }

    return orders;
  }

  // Accept order
  Future<bool> acceptOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'confirmed',
        'updated_at': DateTime.now().toIso8601String(),
      });
      await getVendorOrders();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reject order
  Future<bool> rejectOrder(String orderId, String reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancellation_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await getVendorOrders();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Refresh orders
      await getVendorOrders();
      
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating order status: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete service
  Future<bool> deleteService(String serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('services').doc(serviceId).delete();
      await getVendorServices();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get vendor services
  Future<void> getVendorServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final vendorId = getIt<AuthRepository>().getUserId();
      if (vendorId == null) {
        throw Exception('User not logged in');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('vendor_id', isEqualTo: vendorId)
          .get();

      _vendorServices = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Service.fromJson(data);
      }).toList();
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching vendor services: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create service
  Future<bool> createService({
    required String name,
    required String description,
    required String category,
    required double price,
    required double estimatedDuration,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final vendorId = getIt<AuthRepository>().getUserId();
      if (vendorId == null) {
        throw Exception('User not logged in');
      }
      
      final serviceData = {
        'vendor_id': vendorId,
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'estimated_duration': estimatedDuration,
        'image_url': imageUrl,
        'rating': 0.0,
        'review_count': 0,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      await FirebaseFirestore.instance.collection('services').add(serviceData);
      
      // Refresh list
      await getVendorServices();
      
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error creating service: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update service
  Future<bool> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement API call to update service
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // Update availability
  Future<bool> updateAvailability(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement API call to update availability
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = getIt<AuthRepository>().getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Split data into user data and vendor data
      final userData = <String, dynamic>{};
      final vendorData = <String, dynamic>{};

      // Fields for 'users' collection
      if (data.containsKey('name')) userData['name'] = data['name'];
      if (data.containsKey('phoneNumber')) userData['phone_number'] = data['phoneNumber'];
      if (data.containsKey('profileImageUrl')) userData['profile_image_url'] = data['profileImageUrl'];

      // Fields for 'vendors' collection
      final vendorFields = [
        'businessName', 'businessRegistration', 'businessType', 
        'businessCategory', 'businessDescription', 'bankAccountNumber', 
        'bankIfscCode', 'bankAccountHolderName', 'bankName', 'serviceTypes',
        'website', 'socialMedia', 'operatingHours', 'serviceAreas'
      ];

      for (var field in vendorFields) {
        if (data.containsKey(field)) {
          vendorData[field] = data[field];
        }
      }

      // Add timestamps
      final now = DateTime.now().toIso8601String();
      if (userData.isNotEmpty) userData['updated_at'] = now;
      if (vendorData.isNotEmpty) vendorData['updated_at'] = now;

      // Execute updates
      final batch = FirebaseFirestore.instance.batch();
      
      if (userData.isNotEmpty) {
        batch.update(FirebaseFirestore.instance.collection('users').doc(userId), userData);
      }
      
      if (vendorData.isNotEmpty) {
        batch.update(FirebaseFirestore.instance.collection('vendors').doc(userId), vendorData);
      }

      await batch.commit();
      
      // Refresh local profile
      await fetchVendorProfile();
      
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Update profile error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}