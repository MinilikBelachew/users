import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/global/global.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameTextEditController = TextEditingController();
  final phoneTextEditController = TextEditingController();
  final addressTextEditController = TextEditingController();
  DatabaseReference userRef=FirebaseDatabase.instance.ref().child("users");


  Future<void> showUserNameDialogAlert(BuildContext context, String name) {
    nameTextEditController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameTextEditController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancle",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                  onPressed: () {
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "name":nameTextEditController.text.trim(),
                    }).then((value){
                      nameTextEditController.clear();
                      Fluttertoast.showToast(msg: "Update Sucessfully.Relode to see the changes");

                    }).catchError((onError ){
                      Fluttertoast.showToast(msg: "Error Ocured.\n $onError");

                    });

                    Navigator.pop(context);

                  },
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          );
        });
  }
  Future<void> showUserPhoneDialogAlert(BuildContext context, String phone) {
    nameTextEditController.text = phone;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: phoneTextEditController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancle",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                  onPressed: () {
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "phone":phoneTextEditController.text.trim(),
                    }).then((value){
                      phoneTextEditController.clear();
                      Fluttertoast.showToast(msg: "Update Sucessfully.Relode to see the changes");

                    }).catchError((onError ){
                      Fluttertoast.showToast(msg: "Error Ocured.\n $onError");

                    });

                    Navigator.pop(context);

                  },
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          );
        });
  }
  Future<void> showUserAddressDialogAlert(BuildContext context, String Address) {
    nameTextEditController.text = Address;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: addressTextEditController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancle",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                  onPressed: () {
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "address":addressTextEditController.text.trim(),
                    }).then((value){
                      addressTextEditController.clear();
                      Fluttertoast.showToast(msg: "Update Sucessfully.Relode to see the changes");

                    }).catchError((onError ){
                      Fluttertoast.showToast(msg: "Error Ocured.\n $onError");

                    });

                    Navigator.pop(context);

                  },
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          title: Text(
            "Profile Page",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // "${userModelCurrentInfo!.name}",
                      "${userModelCurrentInfo != null ? userModelCurrentInfo!.name : "No Name"}", // Handle null case
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {
                          showUserNameDialogAlert(
                              context,
                              userModelCurrentInfo?.name ??
                                  ""); // Use safe navigation operator

                          // showUserNameDialogAlert(context, userModelCurrentInfo!.name!);
                        },
                        icon: Icon(Icons.edit))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // "${userModelCurrentInfo!.name}",
                      "${userModelCurrentInfo != null ? userModelCurrentInfo!.phone : "No Name"}", // Handle null case
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {
                          showUserPhoneDialogAlert(
                              context,
                              userModelCurrentInfo?.phone ??
                                  ""); // Use safe navigation operator

                          // showUserNameDialogAlert(context, userModelCurrentInfo!.name!);
                        },
                        icon: Icon(Icons.edit))
                  ],
                ),
                Divider(
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // "${userModelCurrentInfo!.name}",
                      "${userModelCurrentInfo != null ? userModelCurrentInfo!.address : "No Name"}", // Handle null case
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {
                          showUserAddressDialogAlert(
                              context,
                              userModelCurrentInfo?.address ??
                                  ""); // Use safe navigation operator

                          // showUserNameDialogAlert(context, userModelCurrentInfo!.name!);
                        },
                        icon: Icon(Icons.edit))
                  ],
                ),
                Divider(
                  thickness: 1,
                ),
                Text(
                  // "${userModelCurrentInfo!.name}",
                  "${userModelCurrentInfo != null ? userModelCurrentInfo!.email : "No Email"}", // Handle null case
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
