import 'package:flutter/material.dart';
import 'package:phoneauthprovider/provider/authprovider.dart';
import 'package:phoneauthprovider/widget/customtext.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: CustomText(text: "Phone Auth"),
          centerTitle: true,
          elevation: 0.5,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  // auth.signOut();
                },
                child: Text("LogOUt"))
          ],
        ),
      ),
    );
  }
}
