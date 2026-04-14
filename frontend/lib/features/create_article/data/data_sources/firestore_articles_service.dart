import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreArticlesService {
  FirestoreArticlesService(this._firestore);

  final FirebaseFirestore _firestore;

  static const String collectionArticlesName = 'articles';

  DocumentReference<Map<String, dynamic>> newArticleDocument() {
    return _firestore.collection(collectionArticlesName).doc();
  }

  DocumentReference<Map<String, dynamic>> articleDocument(String articleUid) {
    return _firestore.collection(collectionArticlesName).doc(articleUid);
  }

  Future<void> setArticle(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) {
    return ref.set(data);
  }

  Future<void> updateArticle(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) {
    return ref.update(data);
  }

  Future<void> deleteArticle(DocumentReference<Map<String, dynamic>> ref) {
    return ref.delete();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllArticles() {
    return _firestore
        .collection(collectionArticlesName)
        .get()
        .then((s) => s.docs);
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchAllArticles() {
    return _firestore
        .collection(collectionArticlesName)
        .snapshots()
        .map((s) => s.docs);
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      watchArticlesByStatus(
    String statusValue,
  ) {
    return _firestore
        .collection(collectionArticlesName)
        .where('status', isEqualTo: statusValue)
        .snapshots()
        .map((s) => s.docs);
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      watchArticlesByAuthorUid(String authorUid) {
    return _firestore
        .collection(collectionArticlesName)
        .where('authorUid', isEqualTo: authorUid)
        .snapshots()
        .map((s) => s.docs);
  }
}
