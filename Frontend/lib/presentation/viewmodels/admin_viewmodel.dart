// Admin view model
import 'package:flutter/foundation.dart';
import 'package:car_wash_app/data/models/user.dart';
import 'package:car_wash_app/data/models/vendor.dart';
import 'package:car_wash_app/data/models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
class AdminViewModel extends ChangeNotifier {
  static const int _pageSize = 20;

  // State variables
  List<User> _allUsers = [];
  List<Vendor> _allVendors = [];
  List<Order> _allOrders = [];
  bool _isLoading = false;
  bool _isLoadingMoreUsers = false;
  bool _isLoadingMoreVendors = false;
  bool _hasMoreUsers = true;
  bool _hasMoreVendors = true;
  String? _errorMessage;
  String _userRoleFilter = 'all';
  String _userSearchQuery = '';
  String _vendorSearchQuery = '';
  Map<String, dynamic> _dashboardStats = {};
  DocumentSnapshot<Map<String, dynamic>>? _lastUserDoc;
  DocumentSnapshot<Map<String, dynamic>>? _lastVendorDoc;

  // Getters
  List<User> get allUsers {
    final query = _userSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return _allUsers;

    return _allUsers.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phoneNumber.toLowerCase().contains(query);
    }).toList();
  }

  List<Vendor> get allVendors {
    final query = _vendorSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return _allVendors;

    return _allVendors.where((vendor) {
      final businessName = (vendor.businessName ?? '').toLowerCase();
      return businessName.contains(query) ||
          vendor.userId.toLowerCase().contains(query);
    }).toList();
  }

  List<Order> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  bool get isLoadingMoreUsers => _isLoadingMoreUsers;
  bool get isLoadingMoreVendors => _isLoadingMoreVendors;
  bool get hasMoreUsers => _hasMoreUsers;
  bool get hasMoreVendors => _hasMoreVendors;
  String? get errorMessage => _errorMessage;
  String get userRoleFilter => _userRoleFilter;
  String get userSearchQuery => _userSearchQuery;
  String get vendorSearchQuery => _vendorSearchQuery;
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  // Fetch dashboard data
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final vendorsSnapshot = await FirebaseFirestore.instance.collection('vendors').get();
      final orderSnapshot = await FirebaseFirestore.instance.collection('orders').get();
      final totalOrders = orderSnapshot.size;
      final activeOrders = orderSnapshot.docs.where((doc) {
        final status = doc.data()['status'];
        return status != 'completed' && status != 'cancelled';
      }).length;
      
      double revenue = 0.0;
      for (var doc in orderSnapshot.docs) {
        if (doc.data()['status'] == 'completed') {
          revenue += (doc.data()['total_amount'] ?? 0.0);
        }
      }

      _dashboardStats = {
        'totalUsers': usersSnapshot.size,
        'totalVendors': vendorsSnapshot.size,
        'totalOrders': totalOrders,
        'totalRevenue': revenue,
        'activeOrders': activeOrders,
      };
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUserRoleFilter(String role) {
    _userRoleFilter = role;
    getAllUsers(reset: true);
  }

  void setUserSearchQuery(String query) {
    _userSearchQuery = query;
    notifyListeners();
  }

  void setVendorSearchQuery(String query) {
    _vendorSearchQuery = query;
    notifyListeners();
  }

  Future<void> getAllUsers({
    int page = 1,
    String? searchQuery,
    bool reset = true,
  }) async {
    if (searchQuery != null) {
      _userSearchQuery = searchQuery;
    }

    if (reset) {
      _allUsers = [];
      _lastUserDoc = null;
      _hasMoreUsers = true;
    }

    if (!_hasMoreUsers) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('users');

      if (_userRoleFilter != 'all') {
        query = query.where('role', isEqualTo: _userRoleFilter);
      }

      query = query.limit(_pageSize);
      if (_lastUserDoc != null) {
        query = query.startAfterDocument(_lastUserDoc!);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        _lastUserDoc = snapshot.docs.last;
      }

      if (snapshot.docs.length < _pageSize) {
        _hasMoreUsers = false;
      }

      final users = <User>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['created_at'] = _toIsoString(data['created_at']);
        data['updated_at'] = _toIsoString(data['updated_at']);
        data['last_login'] = _toIsoString(data['last_login']);

        data.putIfAbsent('email', () => '');
        data.putIfAbsent('name', () => 'Unknown');
        data.putIfAbsent('phone_number', () => '');
        data.putIfAbsent('role', () => 'customer');
        data.putIfAbsent('is_active', () => true);
        data.putIfAbsent('is_verified', () => false);
        data.putIfAbsent('is_email_verified', () => false);
        data.putIfAbsent('is_phone_verified', () => false);
        data.putIfAbsent('created_at', () => DateTime.now().toIso8601String());
        data.putIfAbsent('updated_at', () => DateTime.now().toIso8601String());

        try {
          users.add(User.fromJson(data));
        } catch (e) {
          debugPrint('Skipping invalid user document ${doc.id}: $e');
        }
      }

      _allUsers.addAll(users);
      _allUsers = _dedupeUsers(_allUsers);
      _allUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreUsers() async {
    if (_isLoadingMoreUsers || !_hasMoreUsers) return;
    _isLoadingMoreUsers = true;
    notifyListeners();
    try {
      await getAllUsers(reset: false);
    } finally {
      _isLoadingMoreUsers = false;
      notifyListeners();
    }
  }

  // Get user detail
  Future<User?> getUserDetail(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement API call to get user detail
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Activate user
  Future<bool> activateUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
      _allUsers = _allUsers.map((user) {
        if (user.id != userId) return user;
        return user.copyWith(
          isActive: true,
          updatedAt: DateTime.now(),
        );
      }).toList();
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

  // Deactivate user
  Future<bool> deactivateUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      });
      _allUsers = _allUsers.map((user) {
        if (user.id != userId) return user;
        return user.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
      }).toList();
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

  Future<void> getAllVendors({int page = 1, bool reset = true}) async {
    if (reset) {
      _allVendors = [];
      _lastVendorDoc = null;
      _hasMoreVendors = true;
    }

    if (!_hasMoreVendors) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('vendors').limit(_pageSize);

      if (_lastVendorDoc != null) {
        query = query.startAfterDocument(_lastVendorDoc!);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        _lastVendorDoc = snapshot.docs.last;
      }

      if (snapshot.docs.length < _pageSize) {
        _hasMoreVendors = false;
      }

      final vendors = <Vendor>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data.putIfAbsent('userId', () => doc.id);

        data['createdAt'] = _toIsoString(data['createdAt']);
        data['updatedAt'] = _toIsoString(data['updatedAt']);
        data['verificationDate'] = _toIsoString(data['verificationDate']);
        data['suspensionDate'] = _toIsoString(data['suspensionDate']);
        data['blockDate'] = _toIsoString(data['blockDate']);
        data['insuranceExpiry'] = _toIsoString(data['insuranceExpiry']);

        data.putIfAbsent('isVerified', () => false);
        data.putIfAbsent('createdAt', () => DateTime.now().toIso8601String());
        data.putIfAbsent('updatedAt', () => DateTime.now().toIso8601String());

        try {
          vendors.add(Vendor.fromJson(data));
        } catch (e) {
          debugPrint('Skipping invalid vendor document ${doc.id}: $e');
        }
      }

      _allVendors.addAll(vendors);
      _allVendors = _dedupeVendors(_allVendors)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreVendors() async {
    if (_isLoadingMoreVendors || !_hasMoreVendors) return;
    _isLoadingMoreVendors = true;
    notifyListeners();
    try {
      await getAllVendors(reset: false);
    } finally {
      _isLoadingMoreVendors = false;
      notifyListeners();
    }
  }

  // Verify vendor
  Future<bool> verifyVendor(String vendorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('vendors').doc(vendorId).update({
        'isVerified': true,
        'verificationDate': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      _allVendors = _allVendors.map((vendor) {
        if (vendor.id != vendorId) return vendor;
        return vendor.copyWith(
          isVerified: true,
          verificationDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
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

  // Suspend vendor
  Future<bool> suspendVendor(String vendorId, String reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('vendors').doc(vendorId).update({
        'isSuspended': true,
        'suspensionReason': reason,
        'suspensionDate': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      _allVendors = _allVendors.map((vendor) {
        if (vendor.id != vendorId) return vendor;
        return vendor.copyWith(
          isSuspended: true,
          suspensionReason: reason,
          suspensionDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
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

  Future<bool> unsuspendVendor(String vendorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await FirebaseFirestore.instance.collection('vendors').doc(vendorId).update({
        'isSuspended': false,
        'suspensionReason': null,
        'suspensionDate': null,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      _allVendors = _allVendors.map((vendor) {
        if (vendor.id != vendorId) return vendor;
        return vendor.copyWith(
          isSuspended: false,
          suspensionReason: null,
          suspensionDate: null,
          updatedAt: DateTime.now(),
        );
      }).toList();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get all orders
  Future<void> getAllOrders({int page = 1, String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var query = FirebaseFirestore.instance.collection('orders') as Query;
      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }
      final snapshot = await query.get();
      _allOrders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate report
  Future<Map<String, dynamic>?> generateReport({
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement API call to generate report
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
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

  String? _toIsoString(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    if (value is String) return value;
    return null;
  }

  List<User> _dedupeUsers(List<User> users) {
    final map = <String, User>{};
    for (final user in users) {
      map[user.id] = user;
    }
    return map.values.toList();
  }

  List<Vendor> _dedupeVendors(List<Vendor> vendors) {
    final map = <String, Vendor>{};
    for (final vendor in vendors) {
      map[vendor.id] = vendor;
    }
    return map.values.toList();
  }
}
