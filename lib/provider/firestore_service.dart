import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/product_model.dart';
import '../model/user.dart';
import 'authentication_service.dart';

final firestoreProvider = Provider((ref) => FirestoreService());

class FirestoreService {
  final _usersCollection = FirebaseFirestore.instance.collection('users');
  final _productCollection = FirebaseFirestore.instance.collection('products');
  final _cartCollection = FirebaseFirestore.instance.collection('user');
  final _auth = AuthenticationService();

  Future<void> addProducts(ProductModel products) async =>
      await _productCollection.add(products.toMap());

  Stream<QuerySnapshot<Map<String, dynamic>>> getProducts() {
    return _productCollection.snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> addProductsToCart(
          ProductModel products) async =>
      await _cartCollection
          .doc(_auth.currentUser!.uid)
          .collection('cart')
          .add(products.toMap());

  Future<QuerySnapshot<Map<String, dynamic>>> getProductIdFromCart(
      String docId) async {
    return await _cartCollection
        .doc(_auth.currentUser!.uid)
        .collection('cart')
        .where('id', isEqualTo: docId)
        .get();
  }

  Future removeProductFromCart(String id) async {
    await _cartCollection.doc(_auth.currentUser!.uid).delete();
  }

  Stream<List<ProductModel>> getProductsFromCart() {
    final products = _cartCollection
        .doc(_auth.currentUser!.uid)
        .collection('cart')
        .snapshots();
    return products.map((event) =>
        event.docs.map((e) => ProductModel.fromMap(e.data())).toList());
  }

  Future<void> saveUserInfo(UserModel user) async =>
      await _usersCollection.doc(user.id).set(user.toMap());

  Future<UserModel> getUserInfo() async {
    final user = await _usersCollection.doc(_auth.currentUser!.uid).get();
    return UserModel.fromMap(user.data());
  }
}
