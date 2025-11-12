import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final CollectionReference _adminCollection =
      FirebaseFirestore.instance.collection('admin');

  Future<void> tambahAdmin(Map<String, dynamic> data) async {
    await _adminCollection.add(data);
  }

  Stream<QuerySnapshot> getAdminStream() {
    return _adminCollection.snapshots();
  }

  Future<void> updateAdmin(String id, Map<String, dynamic> data) async {
    await _adminCollection.doc(id).update(data);
  }

  Future<void> hapusAdmin(String id) async {
    await _adminCollection.doc(id).delete();
  }
}
