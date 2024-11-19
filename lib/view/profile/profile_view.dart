import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/APIs.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../more/my_order_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  bool _isUploading = false; // Flag for tracking upload state
  final ImagePicker picker = ImagePicker();

  // Text Controllers with default values from APIs.me
  TextEditingController txtName = TextEditingController(text: APIs.me.name);
  TextEditingController txtEmail = TextEditingController(text: APIs.me.email);
  TextEditingController txtMobile = TextEditingController(text: APIs.me.contact);
  TextEditingController txtAddress = TextEditingController(text: APIs.me.address);
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Profile",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyOrderView()));
                      },
                      icon: Image.asset(
                        "assets/img/shopping_cart.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: TColor.placeholder,
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                child: _isUploading
                    ? const CircularProgressIndicator() // Show loader when uploading
                    : _image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: Image.file(
                    File(_image!),
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.cover,
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.cover,
                    imageUrl: APIs.me.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _showBottomSheet,
                icon: Icon(
                  Icons.edit,
                  color: TColor.primary,
                  size: 12,
                ),
                label: Text(
                  "Edit Profile",
                  style: TextStyle(color: TColor.primary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: RoundTitleTextfield(
                  title: "Name",
                  hintText: "Enter Name",
                  controller: txtName,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: RoundTitleTextfield(
                  title: "Email",
                  hintText: "Enter Email",
                  keyboardType: TextInputType.emailAddress,
                  controller: txtEmail,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: RoundTitleTextfield(
                  title: "Mobile No",
                  hintText: "Enter Mobile No",
                  controller: txtMobile,
                  keyboardType: TextInputType.phone,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: RoundTitleTextfield(
                  title: "Address",
                  hintText: "Enter Address",
                  controller: txtAddress,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundButton(
                    title: "Save",
                    onPressed: () async {
                      // Update `me` instance with new values before sending to Firestore
                      APIs.me.name = txtName.text;
                      APIs.me.email = txtEmail.text;
                      APIs.me.contact = txtMobile.text;
                      APIs.me.address = txtAddress.text;

                      // Call `updateUserInfo()` to update in Firestore
                      await APIs.updateUserInfo();

                      // Show snackbar to confirm update
                      Dialogs.showSnackbar(context, 'Profile Updated Successfully');

                      // Rebuild UI to reflect new data
                      setState(() {});
                    }),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ));
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        final mq = MediaQuery.of(context);
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
              top: mq.size.height * .03, bottom: mq.size.height * .08),
          children: [
            const Text(
              "Pick Profile Picture",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: mq.size.height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.size.width * .3, mq.size.height * .15),
                  ),
                  onPressed: () async {
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      _handleImageUpload(File(image.path));
                    }
                  },
                  child: Image.asset('assets/img/gallery.png'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.size.width * .3, mq.size.height * .15),
                  ),
                  onPressed: () async {

                    final XFile? image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      _handleImageUpload(File(image.path));
                    }
                  },
                  child: Image.asset('assets/img/camera.png'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _handleImageUpload(File image) async {
    try {
      setState(() => _isUploading = true);
      Navigator.pop(context);

      await APIs.updateProfilePicture(image);

      if (mounted) {
        setState(() {
          _image = image.path;
          _isUploading = false;
        });
        Dialogs.showSnackbar(context, 'Profile picture updated successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        Dialogs.showSnackbar(context, 'Failed to upload image');
      }
    }
  }
}
