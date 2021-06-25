import 'package:blood_app/model/donor.dart';
import 'package:blood_app/screens/about.dart';
import 'package:blood_app/screens/blood_request_page.dart';
import 'package:blood_app/screens/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/donor.dart';

class MainDrawer extends StatefulWidget {

  final GoogleSignIn googleSignIn;

  MainDrawer(this.googleSignIn);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Image.asset('assets/img/logo.jpeg'),
            ),
            ListTile(
              title: Text('Accueil', style: TextStyle(color: Colors.black, fontFamily: "Gotham", fontSize: 18.0 ),),
              leading: Icon(Icons.home, color: Colors.red,),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Demande De Sang', style: TextStyle(color: Colors.black, fontFamily: "Gotham", fontSize: 16.0 ),),
              leading: Icon(Icons.comment, color: Colors.red,),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowRequest()));
              },
            ),
            ListTile(
              title: Text('Se Déconnecter', style: TextStyle(color: Colors.black, fontFamily: "Gotham", fontSize: 16.0 ),),
              leading: Icon(Icons.lock_outline, color: Colors.red,),
              onTap: () {
                widget.googleSignIn.signOut();
              },
            ),
            ListTile(
              title: Text('À Propos', style: TextStyle(color: Colors.black, fontFamily: "Gotham", fontSize: 16.0 ),),
              leading: Icon(Icons.help, color: Colors.red,),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutUs()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
