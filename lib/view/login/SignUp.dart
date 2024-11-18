import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';
import 'package:random_string/random_string.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Function for Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // The user canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Show success message and navigate to main screen
      Fluttertoast.showToast(msg: "Logged in with Google successfully", backgroundColor: Colors.black);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainTabView()));
    } catch (e) {
      Fluttertoast.showToast(msg: "Google sign-in failed: $e", backgroundColor: Colors.black);
    }
  }

  Future<void> registration() async {
    name = nameController.text;
    email = emailController.text;
    password = passwordController.text;

    if (password != null && name != null && email != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email!, password: password!);
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Registered Successfully", backgroundColor: Colors.black);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainTabView()));

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
          "contact": "",
          "address": "",
          "latitude": "",
          "longitude": "",
          "Image": "https://firebasestorage.googleapis.com/v0/b/perfectnew-cc234.appspot.com/o/androgynous-avatar-non-binary-queer-person.jpg?alt=media&token=7a864647-6db0-4544-8753-7dcc00f56feb"
        };

        await DatabaseMethods().addUserDetails(userInfoMap, Id);
      } on FirebaseException catch (e) {
        Navigator.pop(context);
        String errorMessage = "Registration failed";
        if (e.code == "weak-password") {
          errorMessage = "Password provided is too weak";
        } else if (e.code == "email-already-in-use") {
          errorMessage = "Account already exists";
        } else {
          errorMessage = "Registration failed: ${e.message}";
        }
        Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.black);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 245, 228, 1),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Image.asset('assets/img/logoblack.png'),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(106, 156, 137, 1),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(41), topRight: Radius.circular(41)),
              ),
              child: Form(
                key: _formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.black, fontSize: 54, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField("Name", nameController, "Please enter your name"),
                    const SizedBox(height: 20),
                    _buildTextField("Email", emailController, "Please enter your email"),
                    const SizedBox(height: 20),
                    _buildTextField("Password", passwordController, "Please enter your password", isPassword: true),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGoogleLoginButton(),
                        const SizedBox(width: 40),
                        _buildExistingUserButton(),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            registration();
                          });
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(205, 92, 8, 1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, String errorMessage, {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 245, 228, 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: (value) => value == null || value.isEmpty ? errorMessage : null,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return GestureDetector(
      onTap: () => signInWithGoogle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(color: const Color.fromRGBO(193, 216, 195, 1), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            SvgPicture.asset('assets/img/google.svg', height: 30, width: 30),
            const SizedBox(width: 9),
            const Text("Google", style: TextStyle(color: Colors.black, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingUserButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: const Color.fromRGBO(193, 216, 195, 1), borderRadius: BorderRadius.circular(15)),
        child: const Text("Existing User?", style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
    );
  }
}
