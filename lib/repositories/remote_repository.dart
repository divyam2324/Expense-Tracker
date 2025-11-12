import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class RemoteRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> uploadTransaction(String uid, TransactionModel t) async {
    await firestore.collection('users').doc(uid)
      .collection('transactions').doc(t.id).set(t.toMap());
  }

  Future<void> deleteTransaction(String uid, String id) async {
    await firestore.collection('users').doc(uid)
      .collection('transactions').doc(id).delete();
  }

  Stream<List<TransactionModel>> transactionsStream(String uid) {
    return firestore.collection('users').doc(uid)
      .collection('transactions').snapshots().map((snap) {
        return snap.docs.map((d) => TransactionModel.fromMap(d.data())).toList();
      });
  }
}
