import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phoneauthprovider/model/usermodel.dart';

class UserServices {
  String collection = 'users';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void createUser(Map<String, dynamic> values) {
    String id = values['id'];
    _firestore.collection(collection).doc(id).set(values);
  }

  void updateUser(Map<String, dynamic> values) {}

  Future<UserModel> getUserById(String id) =>
      _firestore.collection(collection).doc(id).get().then(
        (value) {
          if (value.data == null) {
            return null;
          }
          return UserModel.fromSnapshot(value);
        },
      );
}
