import 'package:flutter/foundation.dart';
import 'package:car_wash_app/data/models/order.dart';
import 'package:car_wash_app/data/models/service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:car_wash_app/dependency_injection/injection_container.dart';
import 'package:car_wash_app/data/repositories/auth_repository.dart';
import 'package:car_wash_app/data/models/customer.dart';

class CustomerViewModel extends ChangeNotifier {
  // State variables
  List<Service> _services = [];
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;
  double? _userLatitude;
  double? _userLongitude;
  final int _currentPage = 1;
  Customer? _customerProfile;

  // Getters
  List<Service> get services => _services;
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double? get userLatitude => _userLatitude;
  double? get userLongitude => _userLongitude;
  Customer? get customerProfile => _customerProfile;

  // Fetch nearby services
  Future<void> fetchNearbyServices({
    double? latitude,
    double? longitude,
    int page = 1,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance.collection('services').get();
      _services = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Service.fromJson(data);
      }).toList();
      
      // If empty, supply a default
      if (_services.isEmpty) {
        _services = [
          Service(
            id: '1',
            vendorId: 'vendor_id_1',
            name: 'Basic Wash',
            description: 'Exterior wash with water jets',
            category: 'basic',
            price: 299,
            estimatedDuration: 30,
            imageUrl: 'https://via.placeholder.com/300',
            rating: 4.5,
            reviewCount: 120,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search services
  Future<void> searchServices(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement API call to search services
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get service detail
  Future<Service?> getServiceDetail(String serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement API call to get service detail
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Place order
  Future<bool> placeOrder({
    required String serviceId,
    required String vendorId,
    required String serviceName,
    required String vendorName,
    required double totalAmount,
    required DateTime scheduledDate,
    required String address,
    String? notes,
    String? carDetails,
    List<String>? selectedServices,
    double? latitude,
    double? longitude,
    String? servicePackage,
    Map<String, dynamic>? metadata,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = getIt<AuthRepository>().getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Fetch user profile to get name and phone
      final userProfile = await getIt<AuthRepository>().getProfile();
      final customerName = userProfile.name;
      final customerPhone = userProfile.phoneNumber;

      final orderData = {
        'customer_id': userId,
        'vendor_id': vendorId,
        'service_id': serviceId,
        'service_name': serviceName,
        'vendor_name': vendorName,
        'selected_services': selectedServices ?? [],
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'status': 'pending',
        'scheduled_date': scheduledDate.toIso8601String(),
        'address': address,
        'notes': notes ?? '',
        'car_details': carDetails ?? '',
        'latitude': latitude,
        'longitude': longitude,
        'service_package': servicePackage ?? 'full_service',
        'metadata': metadata ?? {},
        'total_amount': totalAmount,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      await FirebaseFirestore.instance.collection('orders').add(orderData);
      
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

  // Get my orders
  Future<void> getMyOrders({int page = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = getIt<AuthRepository>().getUserId() ?? 'customer_id_1';
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('customer_id', isEqualTo: userId)
          .get();
          
      _orders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();

      // Sort in memory (fallback for missing Firestore index)
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get order detail
  Future<Order?> getOrderDetail(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc =
          await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
      if (!doc.exists) {
        _errorMessage = 'Order not found';
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      final order = Order.fromJson(data);
      _selectedOrder = order;
      _errorMessage = null;
      return order;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ordersCollection = FirebaseFirestore.instance.collection('orders');

      // Primary path: Firestore document id equals orderId.
      await ordersCollection.doc(orderId).delete();

      // Compatibility fallback: delete any docs where an explicit id field matches.
      final byIdField = await ordersCollection.where('id', isEqualTo: orderId).get();
      for (final doc in byIdField.docs) {
        await doc.reference.delete();
      }

      _orders.removeWhere((order) => order.id == orderId);
      await getMyOrders();
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

  // Rate service
  Future<bool> rateService({
    required String orderId,
    required double rating,
    required String review,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'rating': rating,
        'review': review,
        'updated_at': DateTime.now().toIso8601String(),
      });

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          rating: rating,
          review: review,
          updatedAt: DateTime.now(),
        );
      }
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

  // Track order
  Future<Order?> trackOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement API call to track order
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch customer profile
  Future<void> fetchCustomerProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = getIt<AuthRepository>().getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        _customerProfile = Customer.fromJson(data);
      } else {
        _errorMessage = 'Customer profile not found';
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Fetch customer profile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update customer profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = getIt<AuthRepository>().getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Split data into user data and customer data
      final userData = <String, dynamic>{};
      final customerData = <String, dynamic>{};

      // Fields for 'users' collection
      if (data.containsKey('name')) userData['name'] = data['name'];
      if (data.containsKey('phoneNumber')) userData['phone_number'] = data['phoneNumber'];
      if (data.containsKey('profileImageUrl')) userData['profile_image_url'] = data['profileImageUrl'];

      // Fields for 'customers' collection
      final customerFields = [
        'savedAddresses', 'preferredLanguage', 'preferredCurrency',
        'emailNotifications', 'smsNotifications', 'pushNotifications', 
        'marketingEmails', 'favoriteServices', 'favoriteVendors'
      ];

      for (var field in customerFields) {
        if (data.containsKey(field)) {
          customerData[field] = data[field];
        }
      }

      // Add timestamps
      final now = DateTime.now().toIso8601String();
      if (userData.isNotEmpty) userData['updated_at'] = now;
      if (customerData.isNotEmpty) customerData['updated_at'] = now;

      // Execute updates
      final batch = FirebaseFirestore.instance.batch();
      
      if (userData.isNotEmpty) {
        batch.update(FirebaseFirestore.instance.collection('users').doc(userId), userData);
      }
      
      if (customerData.isNotEmpty) {
        batch.update(FirebaseFirestore.instance.collection('customers').doc(userId), customerData);
      }

      await batch.commit();
      
      // Refresh local profile
      await fetchCustomerProfile();
      
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

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}