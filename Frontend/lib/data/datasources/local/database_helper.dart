// Local database helper

// Database Helper
// Purpose: SQLite database operations and local data persistence
// Author: CarWash Pro Development Team
// Date: March 3, 2026

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
/// DatabaseHelper handles all SQLite database operations
/// 
/// Responsibilities:
/// - Database initialization and migrations
/// - CRUD operations
/// - Query execution
/// - Data persistence
/// - Transaction management
class DatabaseHelper {
  static const String _databaseName = 'carwash_pro.db';
  static const int _databaseVersion = 1;

  static const String _tableUsers = 'users';
  static const String _tableServices = 'services';
  static const String _tableBookings = 'bookings';
  static const String _tableOrders = 'orders';
  static const String _tableReviews = 'reviews';
  static const String _tableVendors = 'vendors';
  static const String _tableFavorites = 'favorites';
  static const String _tableAddresses = 'addresses';
  static const String _tablePaymentMethods = 'payment_methods';
  static const String _tableCache = 'cache';

  static Database? _database;

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  /// 
  /// Creates database and tables on first run
  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw Exception('Database initialization error: ${e.toString()}');
    }
  }

  /// Create database tables on first run
  Future<void> _onCreate(Database db, int version) async {
    try {
      await _createUserTable(db);
      await _createServiceTable(db);
      await _createBookingTable(db);
      await _createOrderTable(db);
      await _createReviewTable(db);
      await _createVendorTable(db);
      await _createFavoriteTable(db);
      await _createAddressTable(db);
      await _createPaymentMethodTable(db);
      await _createCacheTable(db);
    } catch (e) {
      throw Exception('Table creation error: ${e.toString()}');
    }
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Add migration logic here for future versions
  }

  // ==================== TABLE CREATION ====================

  /// Create users table
  Future<void> _createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableUsers (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        phoneNumber TEXT,
        role TEXT NOT NULL,
        profileImage TEXT,
        isVerified INTEGER DEFAULT 0,
        isSuspended INTEGER DEFAULT 0,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
  }

  /// Create services table
  Future<void> _createServiceTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableServices (
        id TEXT PRIMARY KEY,
        vendorId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        duration INTEGER,
        category TEXT,
        image TEXT,
        rating REAL DEFAULT 0,
        reviewCount INTEGER DEFAULT 0,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT,
        FOREIGN KEY (vendorId) REFERENCES $_tableVendors(id)
      )
    ''');
  }

  /// Create bookings table
  Future<void> _createBookingTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableBookings (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        serviceId TEXT NOT NULL,
        vendorId TEXT NOT NULL,
        bookingDate TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        totalAmount REAL NOT NULL,
        notes TEXT,
        isReviewed INTEGER DEFAULT 0,
        createdAt TEXT,
        FOREIGN KEY (customerId) REFERENCES $_tableUsers(id),
        FOREIGN KEY (serviceId) REFERENCES $_tableServices(id),
        FOREIGN KEY (vendorId) REFERENCES $_tableVendors(id)
      )
    ''');
  }

  /// Create orders table
  Future<void> _createOrderTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableOrders (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        vendorId TEXT NOT NULL,
        serviceId TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        bookingDate TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        platformFee REAL DEFAULT 0,
        vendorAmount REAL DEFAULT 0,
        paymentStatus TEXT DEFAULT 'pending',
        cancellationReason TEXT,
        createdAt TEXT,
        FOREIGN KEY (customerId) REFERENCES $_tableUsers(id),
        FOREIGN KEY (vendorId) REFERENCES $_tableVendors(id),
        FOREIGN KEY (serviceId) REFERENCES $_tableServices(id)
      )
    ''');
  }

  /// Create reviews table
  Future<void> _createReviewTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableReviews (
        id TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        customerId TEXT NOT NULL,
        vendorId TEXT NOT NULL,
        rating INTEGER NOT NULL,
        reviewText TEXT,
        images TEXT,
        createdAt TEXT,
        FOREIGN KEY (orderId) REFERENCES $_tableOrders(id),
        FOREIGN KEY (customerId) REFERENCES $_tableUsers(id),
        FOREIGN KEY (vendorId) REFERENCES $_tableVendors(id)
      )
    ''');
  }

  /// Create vendors table
  Future<void> _createVendorTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableVendors (
        id TEXT PRIMARY KEY,
        businessName TEXT NOT NULL,
        businessDescription TEXT,
        businessAddress TEXT,
        businessPhoneNumber TEXT,
        businessEmail TEXT,
        businessImage TEXT,
        isVerified INTEGER DEFAULT 0,
        isSuspended INTEGER DEFAULT 0,
        rating REAL DEFAULT 0,
        totalOrders INTEGER DEFAULT 0,
        completedOrders INTEGER DEFAULT 0,
        createdAt TEXT
      )
    ''');
  }

  /// Create favorites table
  Future<void> _createFavoriteTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableFavorites (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        serviceId TEXT NOT NULL,
        createdAt TEXT,
        FOREIGN KEY (userId) REFERENCES $_tableUsers(id),
        FOREIGN KEY (serviceId) REFERENCES $_tableServices(id)
      )
    ''');
  }

  /// Create addresses table
  Future<void> _createAddressTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableAddresses (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        address TEXT NOT NULL,
        city TEXT NOT NULL,
        state TEXT,
        zipCode TEXT,
        isDefault INTEGER DEFAULT 0,
        createdAt TEXT,
        FOREIGN KEY (userId) REFERENCES $_tableUsers(id)
      )
    ''');
  }

  /// Create payment methods table
  Future<void> _createPaymentMethodTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tablePaymentMethods (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        cardNumber TEXT NOT NULL,
        cardHolderName TEXT,
        expiryDate TEXT,
        cvv TEXT,
        cardType TEXT,
        isDefault INTEGER DEFAULT 0,
        createdAt TEXT,
        FOREIGN KEY (userId) REFERENCES $_tableUsers(id)
      )
    ''');
  }

  /// Create cache table
  Future<void> _createCacheTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableCache (
        id TEXT PRIMARY KEY,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL,
        expiresAt TEXT,
        createdAt TEXT
      )
    ''');
  }

  // ==================== GENERIC CRUD OPERATIONS ====================

  /// Insert record
  /// 
  /// Parameters:
  ///   - table: Table name
  ///   - data: Map of column-value pairs
  ///   - conflictAlgorithm: How to handle conflicts
  /// 
  /// Returns: ID of inserted record
  Future<int> insert(
    String table,
    Map<String, dynamic> data, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    try {
      final db = await database;
      return await db.insert(
        table,
        data,
        conflictAlgorithm: conflictAlgorithm,
      );
    } catch (e) {
      throw Exception('Insert error: ${e.toString()}');
    }
  }

  /// Insert multiple records
  /// 
  /// Parameters:
  ///   - table: Table name
  ///   - dataList: List of maps
  /// 
  /// Returns: List of inserted IDs
  Future<List<int>> insertBatch(
    String table,
    List<Map<String, dynamic>> dataList,
  ) async {
    try {
      final db = await database;
      final batch = db.batch();

      for (final data in dataList) {
        batch.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      final results = await batch.commit();
      return results.cast<int>();
    } catch (e) {
      throw Exception('Batch insert error: ${e.toString()}');
    }
  }

  /// Query single record by ID
  /// 
  /// Parameters:
  ///   - table: Table name
  ///   - id: Record ID
  /// 
  /// Returns: Record map or null if not found
  Future<Map<String, dynamic>?> queryById(String table, String id) async {
    try {
      final db = await database;
      final results = await db.query(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      throw Exception('Query error: ${e.toString()}');
    }
  }

  /// Query multiple records
  /// 
  /// Parameters:
  ///   - table: Table name
  ///   - where: WHERE clause (optional)
  ///   - whereArgs: WHERE arguments (optional)
  ///   - orderBy: ORDER BY clause (optional)
  ///   - limit: LIMIT value (optional)
  /// 
  /// Returns: List of records
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    try {
      final db = await database;
      return await db.query(
        table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Query error: ${e.toString()}');
    }
  }

  /// Update record
  /// 
  /// Parameters:
  ///   - table: Table name
  ///   - data: Map of updates
  ///   - where: WHERE clause
  ///   - whereArgs: WHERE arguments
  /// 
  /// Returns: Number of rows updated
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e) {
      throw Exception('Update error: ${e.toString()}');
    }
  }

  /// Delete record
  /// 
  /// Parameters:
  ///   - table: Table name
  ///   - where: WHERE clause
  ///   - whereArgs: WHERE arguments
  /// 
  /// Returns: Number of rows deleted
  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e) {
      throw Exception('Delete error: ${e.toString()}');
    }
  }

  /// Delete record by ID
  Future<int> deleteById(String table, String id) async {
    return delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all records from table
  Future<int> deleteAll(String table) async {
    try {
      final db = await database;
      return await db.delete(table);
    } catch (e) {
      throw Exception('Delete all error: ${e.toString()}');
    }
  }

  // ==================== USER OPERATIONS ====================

  /// Save user to local database
  /// 
  /// Parameters:
  ///   - userId: User ID
  ///   - userData: User data map
  /// 
  /// Returns: Insert result
  Future<int> saveUser(String userId, Map<String, dynamic> userData) async {
    return insert(_tableUsers, userData);
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    return queryById(_tableUsers, userId);
  }

  /// Update user
  Future<int> updateUser(String userId, Map<String, dynamic> updates) async {
    return update(
      _tableUsers,
      updates,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Delete user
  Future<int> deleteUser(String userId) async {
    return deleteById(_tableUsers, userId);
  }

  /// Clear all user data
  Future<int> clearUserData() async {
    return deleteAll(_tableUsers);
  }

  // ==================== SERVICE OPERATIONS ====================

  /// Save service
  /// 
  /// Parameters:
  ///   - serviceData: Service data map
  /// 
  /// Returns: Insert result
  Future<int> saveService(Map<String, dynamic> serviceData) async {
    return insert(_tableServices, serviceData);
  }

  /// Get service by ID
  Future<Map<String, dynamic>?> getService(String serviceId) async {
    return queryById(_tableServices, serviceId);
  }

  /// Get services by vendor
  /// 
  /// Parameters:
  ///   - vendorId: Vendor ID
  /// 
  /// Returns: List of services
  Future<List<Map<String, dynamic>>> getServicesByVendor(
    String vendorId,
  ) async {
    return query(
      _tableServices,
      where: 'vendorId = ?',
      whereArgs: [vendorId],
    );
  }

  /// Get all active services
  Future<List<Map<String, dynamic>>> getActiveServices() async {
    return query(
      _tableServices,
      where: 'isActive = ?',
      whereArgs: [1],
    );
  }

  /// Search services
  /// 
  /// Parameters:
  ///   - searchQuery: Search query
  /// 
  /// Returns: Matching services
  Future<List<Map<String, dynamic>>> searchServices(String searchQuery) async {
    return query(
      _tableServices,
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$searchQuery%', '%$searchQuery%'],
    );
  }

  /// Update service
  Future<int> updateService(
    String serviceId,
    Map<String, dynamic> updates,
  ) async {
    return update(
      _tableServices,
      updates,
      where: 'id = ?',
      whereArgs: [serviceId],
    );
  }

  /// Delete service
  Future<int> deleteService(String serviceId) async {
    return deleteById(_tableServices, serviceId);
  }

  /// Save multiple services
  Future<List<int>> saveServices(
    List<Map<String, dynamic>> serviceList,
  ) async {
    return insertBatch(_tableServices, serviceList);
  }

  /// Clear all services
  Future<int> clearServices() async {
    return deleteAll(_tableServices);
  }

  // ==================== BOOKING OPERATIONS ====================

  /// Save booking
  Future<int> saveBooking(Map<String, dynamic> bookingData) async {
    return insert(_tableBookings, bookingData);
  }

  /// Get booking by ID
  Future<Map<String, dynamic>?> getBooking(String bookingId) async {
    return queryById(_tableBookings, bookingId);
  }

  /// Get bookings by customer
  /// 
  /// Parameters:
  ///   - customerId: Customer ID
  /// 
  /// Returns: Customer's bookings
  Future<List<Map<String, dynamic>>> getBookingsByCustomer(
    String customerId,
  ) async {
    return query(
      _tableBookings,
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'createdAt DESC',
    );
  }

  /// Get bookings by status
  /// 
  /// Parameters:
  ///   - status: Booking status
  /// 
  /// Returns: Bookings with given status
  Future<List<Map<String, dynamic>>> getBookingsByStatus(
    String status,
  ) async {
    return query(
      _tableBookings,
      where: 'status = ?',
      whereArgs: [status],
    );
  }

  /// Update booking status
  Future<int> updateBookingStatus(
    String bookingId,
    String newStatus,
  ) async {
    return update(
      _tableBookings,
      {'status': newStatus, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  /// Delete booking
  Future<int> deleteBooking(String bookingId) async {
    return deleteById(_tableBookings, bookingId);
  }

  // ==================== ORDER OPERATIONS ====================

  /// Save order
  Future<int> saveOrder(Map<String, dynamic> orderData) async {
    return insert(_tableOrders, orderData);
  }

  /// Get order by ID
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    return queryById(_tableOrders, orderId);
  }

  /// Get orders by customer
  Future<List<Map<String, dynamic>>> getOrdersByCustomer(
    String customerId,
  ) async {
    return query(
      _tableOrders,
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'createdAt DESC',
    );
  }

  /// Get orders by vendor
  Future<List<Map<String, dynamic>>> getOrdersByVendor(
    String vendorId,
  ) async {
    return query(
      _tableOrders,
      where: 'vendorId = ?',
      whereArgs: [vendorId],
      orderBy: 'createdAt DESC',
    );
  }

  /// Update order status
  Future<int> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    return update(
      _tableOrders,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  /// Get pending orders count
  Future<int> getPendingOrdersCount() async {
    final results = await query(
      _tableOrders,
      where: 'status = ?',
      whereArgs: ['pending'],
    );
    return results.length;
  }

  // ==================== REVIEW OPERATIONS ====================

  /// Save review
  Future<int> saveReview(Map<String, dynamic> reviewData) async {
    return insert(_tableReviews, reviewData);
  }

  /// Get review by ID
  Future<Map<String, dynamic>?> getReview(String reviewId) async {
    return queryById(_tableReviews, reviewId);
  }

  /// Get reviews by vendor
  Future<List<Map<String, dynamic>>> getReviewsByVendor(
    String vendorId,
  ) async {
    return query(
      _tableReviews,
      where: 'vendorId = ?',
      whereArgs: [vendorId],
      orderBy: 'createdAt DESC',
    );
  }

  /// Get reviews by order
  Future<List<Map<String, dynamic>>> getReviewsByOrder(
    String orderId,
  ) async {
    return query(
      _tableReviews,
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
  }

  /// Get average rating for vendor
  Future<double> getAverageRating(String vendorId) async {
    final reviews = await getReviewsByVendor(vendorId);
    if (reviews.isEmpty) return 0;
    
    final totalRating = reviews.fold<double>(
      0,
      (sum, review) => sum + (review['rating'] as num).toDouble(),
    );
    
    return totalRating / reviews.length;
  }

  // ==================== FAVORITE OPERATIONS ====================

  /// Add to favorites
  Future<int> addToFavorites(
    String userId,
    String serviceId,
  ) async {
    return insert(_tableFavorites, {
      'id': '$userId-$serviceId',
      'userId': userId,
      'serviceId': serviceId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get favorites for user
  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    return query(
      _tableFavorites,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  /// Check if service is favorite
  Future<bool> isFavorite(String userId, String serviceId) async {
    final result = await queryById(_tableFavorites, '$userId-$serviceId');
    return result != null;
  }

  /// Remove from favorites
  Future<int> removeFromFavorites(String userId, String serviceId) async {
    return deleteById(_tableFavorites, '$userId-$serviceId');
  }

  // ==================== ADDRESS OPERATIONS ====================

  /// Save address
  Future<int> saveAddress(Map<String, dynamic> addressData) async {
    return insert(_tableAddresses, addressData);
  }

  /// Get addresses for user
  Future<List<Map<String, dynamic>>> getAddresses(String userId) async {
    return query(
      _tableAddresses,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  /// Update address
  Future<int> updateAddress(
    String addressId,
    Map<String, dynamic> updates,
  ) async {
    return update(
      _tableAddresses,
      updates,
      where: 'id = ?',
      whereArgs: [addressId],
    );
  }

  /// Delete address
  Future<int> deleteAddress(String addressId) async {
    return deleteById(_tableAddresses, addressId);
  }

  // ==================== CACHE OPERATIONS ====================

  /// Save data to cache
  /// 
  /// Parameters:
  ///   - key: Cache key
  ///   - value: Cache value
  ///   - expiresIn: Expiration time in seconds (optional)
  /// 
  /// Returns: Insert result
  Future<int> setCache(
    String key,
    String value, {
    int? expiresIn,
  }) async {
    final expiresAt = expiresIn != null
        ? DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String()
        : null;

    return insert(
      _tableCache,
      {
        'id': key,
        'key': key,
        'value': value,
        'expiresAt': expiresAt,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get data from cache
  /// 
  /// Parameters:
  ///   - key: Cache key
  /// 
  /// Returns: Cached value or null if expired/not found
  Future<String?> getCache(String key) async {
    try {
      final result = await queryById(_tableCache, key);
      
      if (result == null) return null;

      // Check if expired
      if (result['expiresAt'] != null) {
        final expiresAt = DateTime.parse(result['expiresAt']);
        if (DateTime.now().isAfter(expiresAt)) {
          // Cache expired, delete it
          await deleteById(_tableCache, key);
          return null;
        }
      }

      return result['value'];
    } catch (e) {
      return null;
    }
  }

  /// Clear expired cache
  Future<int> clearExpiredCache() async {
    return delete(
      _tableCache,
      where: 'expiresAt IS NOT NULL AND expiresAt < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }

  /// Clear all cache
  Future<int> clearAllCache() async {
    return deleteAll(_tableCache);
  }

  // ==================== TRANSACTION OPERATIONS ====================

  /// Execute operations in transaction
  /// 
  /// Parameters:
  ///   - operation: Async operation to execute
  /// 
  /// Returns: Operation result
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) operation,
  ) async {
    try {
      final db = await database;
      return await db.transaction(operation);
    } catch (e) {
      throw Exception('Transaction error: ${e.toString()}');
    }
  }

  // ==================== DATABASE MANAGEMENT ====================

  /// Get database statistics
  /// 
  /// Returns: Map with database info
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final db = await database;
      
      final stats = <String, dynamic>{};
      final tables = [
        _tableUsers,
        _tableServices,
        _tableBookings,
        _tableOrders,
        _tableReviews,
        _tableVendors,
        _tableFavorites,
        _tableAddresses,
        _tablePaymentMethods,
        _tableCache,
      ];

      for (final table in tables) {
        final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
        final count = (result.first['count'] as int?) ?? 0;
        stats[table] = count;
      }

      return stats;
    } catch (e) {
      throw Exception('Database stats error: ${e.toString()}');
    }
  }

  /// Clear all data
  /// 
  /// WARNING: This deletes all data from database
  Future<void> clearAllData() async {
    try {
      final db = await database;
      final tables = [
        _tableUsers,
        _tableServices,
        _tableBookings,
        _tableOrders,
        _tableReviews,
        _tableVendors,
        _tableFavorites,
        _tableAddresses,
        _tablePaymentMethods,
        _tableCache,
      ];

      for (final table in tables) {
        await db.delete(table);
      }
    } catch (e) {
      throw Exception('Clear all data error: ${e.toString()}');
    }
  }

  /// Delete database file
  /// 
  /// WARNING: This permanently deletes the database
  Future<void> deleteDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);
      
      final dbFile = File(path);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      
      _database = null;
    } catch (e) {
      throw Exception('Delete database error: ${e.toString()}');
    }
  }

  /// Close database
  Future<void> closeDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
    } catch (e) {
      throw Exception('Close database error: ${e.toString()}');
    }
  }

  /// Vacuum database (cleanup space)
  Future<void> vacuum() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
    } catch (e) {
      throw Exception('Vacuum error: ${e.toString()}');
    }
  }
}

// ==================== IMPORTS ====================


