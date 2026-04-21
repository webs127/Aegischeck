import 'package:aegischeck/core/service/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreServiceImpl implements FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreServiceImpl(this._firestore);

  @override
  Future<void> setData({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      debugPrint('[FirestoreService.setData] Writing $collection/$docId');
      await _firestore.collection(collection).doc(docId).set(data);
      debugPrint(
        '[FirestoreService.setData] Write success for $collection/$docId',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        '[FirestoreService.setData] FirebaseException(${e.code}): ${e.message}',
      );
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[FirestoreService.setData] Unexpected error: $e');
      debugPrint('[FirestoreService.setData] Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<DocumentSnapshot> getData({
    required String collection,
    required String docId,
  }) async {
    try {
      debugPrint('[FirestoreService.getData] Reading $collection/$docId');
      final snapshot = await _firestore.collection(collection).doc(docId).get();
      debugPrint(
        '[FirestoreService.getData] Read success for $collection/$docId exists=${snapshot.exists}',
      );
      return snapshot;
    } on FirebaseException catch (e) {
      debugPrint(
        '[FirestoreService.getData] FirebaseException(${e.code}): ${e.message}',
      );
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[FirestoreService.getData] Unexpected error: $e');
      debugPrint('[FirestoreService.getData] Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> updateData({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      debugPrint('[FirestoreService.updateData] Updating $collection/$docId');
      await _firestore.collection(collection).doc(docId).update(data);
      debugPrint(
        '[FirestoreService.updateData] Update success for $collection/$docId',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        '[FirestoreService.updateData] FirebaseException(${e.code}): ${e.message}',
      );
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[FirestoreService.updateData] Unexpected error: $e');
      debugPrint('[FirestoreService.updateData] Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<String> query({
    required String collection,
    required String query,
  }) async {
    try {
      final code = query.trim();
      debugPrint(
        '[FirestoreService.query] Searching $collection by orgCode=$code',
      );

      final orgQuery = await _firestore
          .collection(collection)
          .where('orgCode', isEqualTo: code)
          .limit(1)
          .get();

      if (orgQuery.docs.isEmpty) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Invalid Organization Code',
        );
      } else {
        final orgDoc = orgQuery.docs.first;
        return orgDoc.id;
      }
    } catch (e, stackTrace) {
      debugPrint('[AuthRepository.query] Failed: $e');
      debugPrint('[AuthRepository.query] Stack: $stackTrace');
      rethrow;
    }
  }
}
