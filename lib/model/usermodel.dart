import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const NUMBER = "number";
  static const ID = 'id';
  //static const CLOSE_CONTEXTS = 'closeContexts';

  String _number;
  String _id;
  //List _closeContexts;

  //getters
  String get number => _number;
  String get id => _id;
  //List<String> get closeContexts => _closeContexts;

  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    _number = snapshot.get(NUMBER);
    _id = snapshot.get(ID);
  }
}
