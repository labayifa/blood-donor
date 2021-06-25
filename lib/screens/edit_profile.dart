import 'package:blood_app/model/donor.dart';
import 'package:blood_app/screens/thank_you.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'login_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'loading.dart';



class EditProfile extends StatefulWidget {

  Donor currentUser;
  Scaffold authScreen;
  EditProfile(this.currentUser, this.authScreen);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final _formKey = GlobalKey<FormState>();
  bool isUpdating = false;

  TextEditingController displayNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController bloodGroupController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  @override
  void initState() {
    displayNameController.text = widget.currentUser.displayName;
    addressController.text = widget.currentUser.location;
    bloodGroupController.text = widget.currentUser.bloodGroup;
    phoneNumberController.text = widget.currentUser.phoneNumber;
    genderController.text = widget.currentUser.gender;
    dobController.text = widget.currentUser.dateOfBirth;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final donorRef = FirebaseFirestore.instance.collection('donor');

    getUserLocation() async {
      Position position = await  Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest);
      List<Placemark> placemarks= await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      String completeAddress = '${placemark.subLocality},${placemark.locality}';
      addressController.text = completeAddress;
    }

    setSearchParam(String locationSearch) {
      List<String> locationSearchList = List();
      String temp = "";
      for (int i = 0; i < locationSearch.length; i++) {
        temp = temp + locationSearch[i];
        locationSearchList.add(temp);
      }
      return locationSearchList;
    }


    updateDonorDetail() async {
      donorRef.doc(widget.currentUser.id).update({
        "location":addressController.text,
        "locationSearch":setSearchParam(addressController.text),
        "bloodGroup":bloodGroupController.text,
        "phoneNumber":phoneNumberController.text,
        "gender":genderController.text,
        "dateOfBirth": dobController.text,
      });
    }

    handleDonorUpdate() async {

      setState(() {
        isUpdating = true;
      });

      await updateDonorDetail();

      setState(() {
        isUpdating = false;
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ThankYou(widget.authScreen)));
      });



    }

    pickDate() async {
      DateTime date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(DateTime.now().year-60),
          lastDate: DateTime.now(),
      );

      if(date !=null){
        setState(() {
          dobController.text = date.year.toString() +"-"+ date.month.toString() +"-"+date.day.toString();
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Merci. Héros!!"),
      ),
      body: Builder(builder: (context){
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: isUpdating?circularLoading():ListView(
              children: <Widget>[
                Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.currentUser.photoUrl),
                    radius: 50.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Quel est votre nom?';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: "Nom complet",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        )
                    ),
                    controller: displayNameController,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Les receveurs ont besoin de votre position!';
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
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty || value.length < 8) {
                        return 'Common! Number cannot be Empty';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                        hintText: "Téléphone",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        )
                    ),
                    controller: phoneNumberController,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: DropdownButtonFormField(
                        validator: (value) => value == null
                            ? 'Veuillez fournir un Groupe Sanguin' : null,
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
                    SizedBox(width: 5.0,),
                    Flexible(
                      child: DropdownButtonFormField(
                        validator: (value) => value == null
                            ? 'Veuillez renseigner votre sexe' : null,
                        onChanged: (val){
                          genderController.text = val;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )
                        ),
                        hint: Text("Choisir un sexe"),
                        items: [
                          DropdownMenuItem(child: Text("Masculin"),
                            value: "Masculin",),
                          DropdownMenuItem(child: Text("Féminin"),
                            value: "Féminin",),
                          DropdownMenuItem(child: Text("Autre"),
                            value: "Autre",),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Dite nous votre beau jour!!';
                      }
                      return null;
                    },
                    onTap: (){
                      pickDate();
                    },
                    decoration: InputDecoration(
                        hintText: "Date de naissance",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.pinkAccent
                    ),
                    controller: dobController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                      child: Text("Prêt pour un dons", style: TextStyle(color: Colors.white, fontSize: 20.0),),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Traitement en cours')));
                          handleDonorUpdate();
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
