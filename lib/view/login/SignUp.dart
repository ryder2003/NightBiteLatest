import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';
import 'package:random_string/random_string.dart';

import '../../common_widget/service_widget.dart';
import '../../services/database.dart';
import '../../services/shared_pref.dart';
import 'login_view.dart';


class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {


  String? name, email, password;
  TextEditingController nameController =  TextEditingController();
  TextEditingController emailController =  TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    name = nameController.text;
    email = emailController.text;
    password = passwordController.text;

    if (password != null && name != null && email != null) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(), // Loading spinner
          );
        },
      );

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email!, password: password!);

        // Hide loading indicator after successful registration
        Navigator.pop(context);

        // Show success message using FlutterToast
        Fluttertoast.showToast(
            msg: "Registered Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);

        // Navigate to the main screen
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MainTabView()));

        // Adding data to Firebase database
        String Id = randomAlphaNumeric(10);

        await SharedPreferenceHelper().saveUserEmail(emailController.text);
        await SharedPreferenceHelper().saveUserName(nameController.text);
        await SharedPreferenceHelper().saveUserId(Id);
        await SharedPreferenceHelper().saveUserImage(
            "https://firebasestorage.googleapis.com/v0/b/perfectnew-cc234.appspot.com/o/androgynous-avatar-non-binary-queer-person.jpg?alt=media&token=7a864647-6db0-4544-8753-7dcc00f56feb");

        Map<String, dynamic> userInfoMap = {
          "Name": nameController.text,
          "Email": emailController.text,
          "Password": passwordController.text,
          "Id": Id,
          "Image":
          "https://firebasestorage.googleapis.com/v0/b/perfectnew-cc234.appspot.com/o/androgynous-avatar-non-binary-queer-person.jpg?alt=media&token=7a864647-6db0-4544-8753-7dcc00f56feb"
        };

        await DatabaseMethods().addUserDetails(userInfoMap, Id);
      } on FirebaseException catch (e) {
        // Hide loading indicator if an error occurs
        Navigator.pop(context);

        // Handle specific error cases and show error message using FlutterToast
        String errorMessage = "Registration failed";
        if (e.code == "weak-password") {
          errorMessage = "Password provided is too weak";
        } else if (e.code == "email-already-in-use") {
          errorMessage = "Account already exists";
        } else {
          errorMessage = "Registration failed: ${e.message}";
        }

        // Show error message using FlutterToast
        Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor:const Color.fromRGBO(255,245,228,1),
      body: SingleChildScrollView(

        child: Container(
          //padding:const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Image.asset('assets/img/logoblack.png'),
              //const SizedBox(height: 10,),


              Container(
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height/1.8,
                decoration: const BoxDecoration(color: Color.fromRGBO(106,156,137,1), borderRadius: BorderRadius.only(topLeft: Radius.circular(41), topRight: Radius.circular(41))),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 10,),
                      const Center(child: Text("Sign Up", style: TextStyle(color: Colors.black, fontSize: 54, fontWeight: FontWeight.bold,))),
                      const SizedBox(height: 30,),

                      //Text("Login", style: AppWidget.semiBoldTextStyle(),),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        decoration: BoxDecoration(color: const Color.fromRGBO(255,245,228,1), borderRadius: BorderRadius.circular(14)),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          controller: nameController,
                          decoration: const InputDecoration(border: InputBorder.none, hintText: "Name"),
                        ),
                      ),

                      const SizedBox(height: 30,),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        decoration: BoxDecoration(color: const Color.fromRGBO(255,245,228,1), borderRadius: BorderRadius.circular(14)),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          controller: emailController,
                          decoration: const InputDecoration(border: InputBorder.none, hintText: "Email"),
                        ),
                      ),

                      const SizedBox(height: 20,),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        decoration: BoxDecoration(color: const Color.fromRGBO(255,245,228,1), borderRadius: BorderRadius.circular(14)),
                        child: TextFormField(
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          controller: passwordController,
                          decoration: const InputDecoration(border: InputBorder.none, hintText: "Password"),
                        ),
                      ),

                      const SizedBox(height: 20,),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding:const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(color: const Color.fromRGBO(193,216,195,1), borderRadius: BorderRadius.circular(15)),
                              child: Row(
                                children: [

                                  SvgPicture.asset('assets/img/google.svg', height: 30, width: 30,),
                                  const SizedBox(width: 9,),
                                  const Text("Google", style: TextStyle(color: Colors.black, fontSize: 18),),
                                ],),
                            ),

                            const SizedBox(width: 40,),
                            //Text("Don't have an account ?", style: AppWidget.lightTextStyle(),),
                            Container(
                              padding:const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(color:const Color.fromRGBO(193,216,195,1), borderRadius: BorderRadius.circular(15) ),
                              child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(context,MaterialPageRoute(builder: (context) => const Login()) );
                                  },
                                  child: const Text("Existing User ?", style: TextStyle(color: Colors.black, fontSize: 16),)),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 30,),

                      GestureDetector(
                        onTap: () {
                          if(_formkey.currentState!.validate()){
                            setState(() {

                              registration();
                            });
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 20, ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(color: const Color.fromRGBO(205,92,8,1), borderRadius: BorderRadius.circular(14)),
                          child: Center(child: Text("Sign Up", style: AppWidget.semiBoldTextStyle(),)),
                        ),
                      ),

                      const SizedBox(height: 30,),

                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
