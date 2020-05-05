import 'package:cloud_firestore/cloud_firestore.dart';


class DatabaseService {

  //collection reference
  final CollectionReference expenseCollection = Firestore.instance.collection('expenses');

  Future updateExpenseData(String name, double price) async {
    return await expenseCollection.document().setData({
      'name': name,
      'price': price,
      'addedDate': DateTime.now().toString()
    });
  }

}