import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery/view/login/forgotPassword.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../api/APIs.dart';
import '../../common_widget/service_widget.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import 'SignUp.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {


  String email="", password="";

  TextEditingController emailController= new TextEditingController();
  TextEditingController passwordController= new TextEditingController();

  final _formkey= GlobalKey<FormState>();

  userLogin() async {
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
      // Attempt login
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // If login is successful, dismiss the loading indicator
      Navigator.pop(context); // Dismiss the loading dialog

      // Show success message using FlutterToast
      Fluttertoast.showToast(
          msg: "Login Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

      // Navigate to the main screen
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainTabView()));
    } on FirebaseException catch (e) {
      // Dismiss the loading indicator if an error occurs
      Navigator.pop(context);

      // Handle specific errors and show error message using FlutterToast
      String errorMessage = "Login failed";
      if (e.code == 'invalid-credential') {
        errorMessage = "User not registered";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Wrong password";
      } else {
        errorMessage = "Login failed: ${e.message}";
      }

      // Show error message using FlutterToast
      Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(milliseconds: 500), (){
      setState(() {
      });
    });
  }

  //***************Google Login*************************
  _handleGoogleButtonClick(){
    //To show Progress Loader
    Dialogs.showProgressLoader(context);

    _signInWithGoogle().then((user) async{
      //To remove Progress Loader
      Navigator.pop(context);
      if(user != null){
        print("\nUser: ${user.user}");
        print("\nUser Additional Info: ${user.additionalUserInfo}");
        //It will redirect to homescreen after login

        if((await APIs.userExists())){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const MainTabView()));
        }
        else{
          await APIs.createUser().then((value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const MainTabView()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try{
      await InternetAddress.lookup('google.com');
      //Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e){
      print('\n_signInWithGoogle: $e');Dialogs.showSnackbar(context, 'No internet connection! Please check and try again...');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      //appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor:const Color.fromRGBO(255,245,228,1),
      body:  SingleChildScrollView(
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
                      const Center(child: const Text("Login", style: TextStyle(color: Colors.black, fontSize: 54, fontWeight: FontWeight.bold,))),
                      const SizedBox(height: 30,),

                      //Text("Login", style: AppWidget.semiBoldTextStyle(),),

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
                          decoration: InputDecoration(border: InputBorder.none, hintText: "Email"),
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
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          controller: passwordController,
                          decoration: InputDecoration(border: InputBorder.none, hintText: "Password"),
                        ),
                      ),

                      const SizedBox(height: 20,),

                      GestureDetector(
                        onTap:(){ Navigator.push(context,MaterialPageRoute(builder: (context) => Forgotpassword()) );},
                        child: Container(
                          margin:const EdgeInsets.symmetric(horizontal: 20),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Forget Password ?", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20,),

                      InkWell(
                        onTap: () => _handleGoogleButtonClick(),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding:const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
                                decoration: BoxDecoration(color: const Color.fromRGBO(193,216,195,1), borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  children: [

                                    SvgPicture.asset('assets/img/google.svg', height: 30, width: 30,),
                                    SizedBox(width: 9,),
                                    Text("Google", style: TextStyle(color: Colors.black, fontSize: 18),),
                                  ],),
                              ),

                              SizedBox(width: 40,),
                              //Text("Don't have an account ?", style: AppWidget.lightTextStyle(),),
                              Container(
                                padding:const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(color:const Color.fromRGBO(193,216,195,1), borderRadius: BorderRadius.circular(15) ),
                                child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(context,MaterialPageRoute(builder: (context) => Signup()) );
                                    },
                                    child: const Text("New User ?", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),)),
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30,),

                      InkWell(
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              email = emailController.text;
                              password = passwordController.text;
                              userLogin();
                            });
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 20, ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(color: const Color.fromRGBO(205,92,8,1), borderRadius: BorderRadius.circular(14)),
                          child: Center(child: Text("Login", style: AppWidget.semiBoldTextStyle(),)),
                        ),
                      ),

                      SizedBox(height: 30,)

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

//Color.fromRGBO(193,216,195,1)