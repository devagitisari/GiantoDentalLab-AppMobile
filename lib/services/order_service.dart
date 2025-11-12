import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final CollectionReference _orderCollection =
      FirebaseFirestore.instance.collection('order');

  Future<void> tambahOrder(Map<String, dynamic> data) async {
    await _orderCollection.add(data);
  }

  Stream<QuerySnapshot> getOrderStream() {
    return _orderCollection.snapshots();
  }

  Future<void> updateOrder(String id, Map<String, dynamic> data) async {
    await _orderCollection.doc(id).update(data);
  }

  Future<void> hapusOrder(String id) async {
    await _orderCollection.doc(id).delete();
  }
}
