import 'package:blood_app/model/donor.dart';
import 'package:blood_app/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class RequestBlood extends StatefulWidget {

  final Donor currentUser;

  RequestBlood(this.currentUser);

  @override
  _RequestBloodState createState() => _RequestBloodState();
}

class _RequestBloodState extends State<RequestBlood> {

  final bloodRequestRef = FirebaseFirestore.instance.collection('request');

  bool isRequesting = false;

  final _formKey = GlobalKey<FormState>();


  TextEditingController displayNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController bloodGroupController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController bloodNeedDateController = TextEditingController();


  getUserLocation() async {
    Position position = await  Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest);
    List<Placemark> placemarks= await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress = '${placemark.locality}, ${placemark.administrativeArea}';
    addressController.text = completeAddress;
  }

  requestBlood() async {

    DocumentSnapshot doc = await bloodRequestRef.doc(Uuid().v4()).get();

    bloodRequestRef.doc(Uuid().v4()).set({
      "location":addressController.text,
      "bloodGroup":bloodGroupController.text,
      "phoneNumber":phoneNumberController.text,
      "bloodAmount":amountController.text,
      "bloodNeededDate": bloodNeedDateController.text,
    });

  }

  handleBloodRequest() async {
    setState(() {
      isRequesting = true;
    });

    await requestBlood();

    setState(() {
      isRequesting = false;
      Navigator.pop(context);
    });



  }

  pickDate() async {
    DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year+1),
    );

    if(date !=null){
      setState(() {
        bloodNeedDateController.text = date.year.toString() +"-"+ date.month.toString() +"-"+date.day.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demande de sang"),
      ),
     body: Builder(builder: (context){
       return isRequesting?circularLoading():Padding(
         padding: const EdgeInsets.all(10.0),
         child: Form(
           key: _formKey,
           child: ListView(
             children: <Widget>[
               Padding(
                 padding: const EdgeInsets.only(top:8.0),
                 child: TextFormField(
                   validator: (value) {
                     if (value.isEmpty) {
                       return 'Votre position pour donation';
                     }
                     return null;
                   },
                   decoration: InputDecoration(
                       fillColor: Colors.grey,
                       suffixIcon: IconButton(icon: Icon(Icons.location_on, color: Colors.red,), onPressed: getUserLocation),
                       hintText: "Votre position",
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10.0),
                       )
                   ),
                   controller: addressController,
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top:8.0),
                 child: TextFormField(
                   keyboardType: TextInputType.numberWithOptions(),
                   validator: (value) {
                     if (value.isEmpty) {
                       return 'Quatité de sang requise';
                     }
                     return null;
                   },
                   decoration: InputDecoration(
                       fillColor: Colors.grey,
                       hintText: "Quantité de sang",
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10.0),
                       )
                   ),
                   controller: amountController,
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top:8.0),
                 child: TextFormField(
                   keyboardType: TextInputType.numberWithOptions(),
                   validator: (value) {
                     if (value.isEmpty || value.length < 8) {
                       return 'Le numéro doit faire 8 caractères';
                     }
                     return null;
                   },
                   decoration: InputDecoration(
                       hintText: "Téléphone",
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10.0),
                       )
                   ),
                   controller: phoneNumberController,
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top:8.0),
                 child: DropdownButtonFormField(
                   validator: (value) => value == null
                       ? 'Veuillez choisir un groupe sanguin' : null,
                   onChanged: (val){
                     bloodGroupController.text = val;
                   },
                   decoration: InputDecoration(
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10.0),
                       )
                   ),
                   hint: Text("Groupe Sanguin"),
                   items: [
                     DropdownMenuItem(child: Text("A+"),
                       value: "A+",),
                     DropdownMenuItem(child: Text("B+"),
                       value: "B+",),
                     DropdownMenuItem(child: Text("O+"),
                       value: "O+",),
                     DropdownMenuItem(child: Text("AB+"),
                       value: "AB+",),
                     DropdownMenuItem(child: Text("A-"),
                       value: "A-",),
                     DropdownMenuItem(child: Text("B-"),
                       value: "B-",),
                     DropdownMenuItem(child: Text("O-"),
                       value: "O-",),
                     DropdownMenuItem(child: Text("AB-"),
                       value: "AB-",),
                   ],
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top:8.0),
                 child: TextFormField(
                   onTap: (){
                     pickDate();
                   },
                   validator: (value) {
                     if (value.isEmpty) {
                       return 'Choisir une date';
                     }
                     return null;
                   },
                   decoration: InputDecoration(
                       hintText: "Pour quand ?",
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10.0),
                       ),
                       fillColor: Colors.pinkAccent
                   ),
                   controller: bloodNeedDateController,
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: FlatButton(
                     child: Text("Demander du sang", style: TextStyle(color: Colors.white, fontSize: 20.0),),
                     color: Theme.of(context).primaryColor,
                     onPressed: () {

                       if (_formKey.currentState.validate()) {
                         Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));
                         handleBloodRequest();
                       }
                     }
                 ),
               ),

             ],
           ),
         ),
       );
     })
    );
  }
}
