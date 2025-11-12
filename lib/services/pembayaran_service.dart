import 'package:cloud_firestore/cloud_firestore.dart';

class PembayaranService {
  final CollectionReference _pembayaranCollection =
      FirebaseFirestore.instance.collection('pembayaran');

  Future<void> tambahPembayaran(Map<String, dynamic> data) async {
    await _pembayaranCollection.add(data);
  }

  Stream<QuerySnapshot> getPembayaranStream() {
    return _pembayaranCollection.snapshots();
  }

  Future<void> updatePembayaran(String id, Map<String, dynamic> data) async {
    await _pembayaranCollection.doc(id).update(data);
  }

  Future<void> hapusPembayaran(String id) async {
    await _pembayaranCollection.doc(id).delete();
  }
}
