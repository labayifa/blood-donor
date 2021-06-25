import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
      ),
      body: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[
            Text(
              "Ceci est un travail visant à accompagner les bienfaits des dons de sang pour sauver des vies. La vie humaine est don, il faut en prendre soins",
              style: TextStyle(fontFamily: "Gotham", fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black)
            ),
            ListTile(
              trailing: Icon(Icons.launch, color: Colors.pinkAccent,),
              title: Text("Mon sang, Des vies",  style: TextStyle(fontFamily: "Gotham", fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.pink)),
              onTap: (){
                launch("https://www.google.com");
              },
            )
          ],
        ),
      ),
    );
  }
}
