import 'dart:ffi';
import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phoneauthprovider/helper/screennavigation.dart';
import 'package:phoneauthprovider/helper/user.dart';
import 'package:phoneauthprovider/model/usermodel.dart';
import 'package:phoneauthprovider/screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthProvider extends ChangeNotifier {
  static const LOGGED_IN = 'loggedIn';
  auth.FirebaseAuth firebaseAuth = auth.FirebaseAuth.instance;
  auth.User _user;
  Status _status = Status.Uninitialized;

  UserServices _userServices = UserServices();
  UserModel _userModel;
  TextEditingController phoneNo;
  String smsOTP;
  String verificationId;
  String errorMSG;
  bool loggedIn = false;
  bool loading = false;

  UserModel get userModel => _userModel;
  Status get status => _status;
  auth.User get user => _user;

  AuthProvider.initialize() {
    readPrefs();
  }

  Future<void> readPrefs() async {
    await Future.delayed(Duration(seconds: 3)).then(
      (v) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        loggedIn = prefs.getBool('loggedIn') ?? false;
        if (loggedIn) {
          _user = await firebaseAuth.currentUser;
          _userModel = await _userServices.getUserById(_user.uid);
          notifyListeners();
          return;
        }
        _status = Status.Unauthenticated;
        notifyListeners();
      },
    );
  }

  Future<void> verifyPhoneNumber(BuildContext context, String number) async {
    final auth.PhoneCodeSent smsOtpSent =
        (String verid, [int forceCodeResend]) {
      this.verificationId = verid;
      smsOTPDialog(context).then(
        (value) {
          print('signin');
        },
      );
    };
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: number.trim(),
        verificationCompleted: (auth.AuthCredential phoneAuthCre) {
          print(phoneAuthCre.toString() + ' lets make this work');
        },
        verificationFailed: (auth.FirebaseAuthException exception) {
          print('${exception.message}+ something is wrong');
        },
        codeSent: null,
        timeout: const Duration(seconds: 20),
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
      );
    } catch (e) {
      handleError(e, context);
      errorMSG = e.toString();
      notifyListeners();
    }
  }

  handleError(error, BuildContext context) {
    print(error);
    errorMSG = error.toString();
    notifyListeners();
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        print("The verification code is invalid");
        break;
      default:
        errorMSG = error.message;
        break;
    }
    notifyListeners();
  }

  void _createUser({String id, String number}) {
    _userServices.createUser({
      "Id": id,
      "number": number,
    });
  }

  signIn(BuildContext context) async {
    try {
      final auth.AuthCredential credential = auth.PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsOTP);

      final auth.User user =
          (await firebaseAuth.signInWithCredential(credential)) as auth.User;
      final auth.User currentUser = await firebaseAuth.currentUser;
      assert(user.uid == currentUser.uid);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('loggedIn', true);
      loggedIn = true;
      if (user != null) {
        _userModel = await _userServices.getUserById(user.uid);
        if (_userModel == null) {
          _createUser(id: user.uid, number: user.phoneNumber);
        }
        loading = false;
        Navigator.of(context).pop();
        changeScreen(context, Home());
        notifyListeners();
      }
    } catch (e) {
      print('${e.toString()}');
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Sms Code'),
            content: Container(
              height: 85,
              child: Column(
                children: <Widget>[
                  TextField(
                    onChanged: (val) {
                      this.smsOTP = val;
                    },
                  )
                ],
              ),
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    loading = true;
                    notifyListeners();
                    if (firebaseAuth.currentUser != null) {
                      _userModel = await _userServices
                          .getUserById(firebaseAuth.currentUser.uid);
                      if (userModel == null) {
                        await _createUser(
                            id: user.uid, number: user.phoneNumber);
                      }
                      Navigator.of(context).pop();
                      loading = false;
                      notifyListeners();
                      changeScreen(context, Home());
                    } else {
                      loading = true;
                      notifyListeners();
                      Navigator.of(context).pop();
                      signIn(context);
                    }
                  },
                  child: null)
            ],
          );
        });
  }
}
