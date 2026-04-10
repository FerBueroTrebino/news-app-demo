import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

import '../models/author_model.dart';

class FirestoreAuthorsService {
  FirestoreAuthorsService(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _collection = 'authors';

  Future<void> syncAuthorOnLogin(AuthUser authUser) async {
    final docRef = _firestore.collection(_collection).doc(authUser.uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      await docRef.update(AuthorModel.loginUpdateFirestoreMap());
      return;
    }

    final model = AuthorModel.fromAuthUser(authUser);
    await docRef.set(model.toFirestoreCreateMap());
  }
}
