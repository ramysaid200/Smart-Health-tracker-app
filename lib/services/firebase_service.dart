import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore CRUD helper service
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────────────────────────────────────────────────────
  // Document Operations
  // ──────────────────────────────────────────────────────────────────────────

  /// Get a single document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String path) =>
      _db.doc(path).get();

  /// Set (create or overwrite) a document
  Future<void> setDocument(String path, Map<String, dynamic> data) async {
    try {
      await _db.doc(path).set(data);
    } catch (e) {
      print('Error setting document at $path: $e');
      rethrow;
    }
  }

  /// Update specific fields in a document
  Future<void> updateDocument(String path, Map<String, dynamic> data) async {
    try {
      await _db.doc(path).update(data);
    } catch (e) {
      print('Error updating document at $path: $e');
      rethrow;
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String path) async {
    try {
      await _db.doc(path).delete();
    } catch (e) {
      print('Error deleting document at $path: $e');
      rethrow;
    }
  }

  /// Stream a document for real-time updates
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(String path) =>
      _db.doc(path).snapshots();

  // ──────────────────────────────────────────────────────────────────────────
  // Collection Operations
  // ──────────────────────────────────────────────────────────────────────────

  /// Get all documents in a collection
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String path, {
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _db.collection(path);
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    if (limit != null) query = query.limit(limit);
    return query.get();
  }

  /// Add a new document to a collection (auto-generated ID)
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String path,
    Map<String, dynamic> data,
  ) =>
      _db.collection(path).add(data);

  /// Stream a collection
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String path, {
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _db.collection(path);
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }

  /// Query collection with a where clause
  Future<QuerySnapshot<Map<String, dynamic>>> queryCollection(
    String path, {
    required String field,
    required dynamic isEqualTo,
  }) =>
      _db.collection(path).where(field, isEqualTo: isEqualTo).get();

  /// Query collection with date range
  Future<QuerySnapshot<Map<String, dynamic>>> queryByDateRange(
    String path, {
    required String dateField,
    required DateTime startDate,
    required DateTime endDate,
  }) =>
      _db
          .collection(path)
          .where(dateField, isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where(dateField, isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy(dateField, descending: true)
          .get();

  // ──────────────────────────────────────────────────────────────────────────
  // User-specific helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Base user path
  String userPath(String uid) => 'users/$uid';

  /// Sub-collection path
  String subPath(String uid, String collection, String docId) =>
      'users/$uid/$collection/$docId';

  String collectionPath(String uid, String collection) =>
      'users/$uid/$collection';

  /// Firestore timestamp for now
  static Timestamp get now => Timestamp.now();

  /// Firestore timestamp from DateTime
  static Timestamp fromDateTime(DateTime dt) => Timestamp.fromDate(dt);
}
