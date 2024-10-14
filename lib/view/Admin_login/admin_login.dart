import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/view/login/forgotPassword.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../main.dart';


class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {


  TextEditingController usernameController= new TextEditingController();
  TextEditingController passwordController= new TextEditingController();

  final _formkey= GlobalKey<FormState>();

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
              Image.asset('image/logoblack.png'),
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
                      const Center(child: const Text("Admin Login", style: TextStyle(color: Colors.black, fontSize: 54, fontWeight: FontWeight.bold,))),
                      const SizedBox(height: 30,),

                      //Text("Login", style: AppWidget.semiBoldTextStyle(),),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        decoration: BoxDecoration(color: const Color.fromRGBO(255,245,228,1), borderRadius: BorderRadius.circular(14)),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                          controller: usernameController,
                          decoration: InputDecoration(border: InputBorder.none, hintText: "Username"),
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



                      const SizedBox(height: 30,),

                      InkWell(
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            loginAdmin();
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 20, ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(color: const Color.fromRGBO(205,92,8,1), borderRadius: BorderRadius.circular(14)),
                          child: Center(child: Text("Login", style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22.0
                          ),)),
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

  loginAdmin(){
    FirebaseFirestore.instance.collection("Admin").get().then((snapshot){
      snapshot.docs.forEach((result){
        if(result.data()['Username'] != usernameController.text.trim()){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.greenAccent,
              content: Text("Username is not correct",
                  style: TextStyle(color: Colors.black, fontSize: 16))));
        }else if(result.data()['Password'] != passwordController.text.trim()){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.greenAccent,
              content: Text("Password is not correct",
                  style: TextStyle(color: Colors.black, fontSize: 16))));
        }
        else {
          Navigator.push(context,MaterialPageRoute(builder: (context) => MainTabView()));
        }
      });
    });
  }


}