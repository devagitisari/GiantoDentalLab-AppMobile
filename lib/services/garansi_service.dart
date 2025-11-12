import 'package:cloud_firestore/cloud_firestore.dart';

class GaransiService {
  final CollectionReference _garansiCollection =
      FirebaseFirestore.instance.collection('garansi');

  Future<void> tambahGaransi(Map<String, dynamic> data) async {
    await _garansiCollection.add(data);
  }

  Stream<QuerySnapshot> getGaransiStream() {
    return _garansiCollection.snapshots();
  }

  Future<void> updateGaransi(String id, Map<String, dynamic> data) async {
    await _garansiCollection.doc(id).update(data);
  }

  Future<void> hapusGaransi(String id) async {
    await _garansiCollection.doc(id).delete();
  }
}
