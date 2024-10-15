import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

import '../../common_widget/service_widget.dart';
import '../../services/database.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({super.key});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  TextEditingController nameController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  TextEditingController detailController = new TextEditingController();
  bool isLoading = false;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    setState(() {

    });
  }

  uploadItem() async {
    if (selectedImage != null && nameController.text.isNotEmpty) {
      setState(() {
        isLoading = true; // Start loading
      });

      try {
        String addId = randomAlphaNumeric(10);
        Reference firebaseStorageRef = FirebaseStorage.instance.ref().child("blogImage").child(addId);

        final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
        var downloadUrl = await (await task).ref.getDownloadURL();

        Map<String, dynamic> addProduct = {
          "Name": nameController.text,
          "Image": downloadUrl,
          "Price": priceController.text,
          "Detail": detailController.text
        };

        await DatabaseMethods().addProducts(addProduct, value!).then((value) {
          setState(() {
            selectedImage = null;
            nameController.clear();
            priceController.clear();
            detailController.clear();
            value = null;
            isLoading = false; // Stop loading
          });

          Fluttertoast.showToast(
              msg: "Product is added successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0
          );
        });
      } catch (e) {
        setState(() {
          isLoading = false; // Stop loading in case of an error
        });

        Fluttertoast.showToast(
            msg: "An error occured in adding.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please fill in all the fields.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  String? value;
  final List<String> categoryitem = ['Rolls','Rice','Pasta','Maggie','Snacks','Drinks','Desserts'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
              onTap: () { Navigator.pop(context);},
              child: Icon(Icons.arrow_back_ios_new_outlined)),
          title: Center(child: Text("App Product", style: AppWidget.semiBoldTextStyle()))),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20.0, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              SizedBox(height: 30.09,),


              Text("Upload the product Image", style: AppWidget.lightTextStyle(),),


              SizedBox(height: 30.0,),

              Center(
                child: selectedImage == null? GestureDetector(
                  onTap: () {
                    getImage();
                  },
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.7), borderRadius: BorderRadius.all(Radius.circular(13.0))),
                    child: Icon(Icons.camera_alt_outlined),
                  ),
                ): Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.7), borderRadius: BorderRadius.all(Radius.circular(13.0))),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.file(selectedImage!, fit: BoxFit.cover,)),
                  ),
                ),
              ),


              SizedBox(height: 40.0,),


              Text("Product Name", style: AppWidget.lightTextStyle(),),


              SizedBox(height: 20.09,),


              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: Color(0xFFececf8), borderRadius: BorderRadius.circular(14)),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration( border: InputBorder.none),
                ),
              ),


              SizedBox(height: 30.0,),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Product Price :", style: AppWidget.lightTextStyle(),),
                  SizedBox(width: 50,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width/2.5,
                    decoration: BoxDecoration(color: Color(0xFFececf8), borderRadius: BorderRadius.circular(14)),
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration( border: InputBorder.none),
                    ),
                  ),
                ],
              ),


              SizedBox(height: 30.0,),


              Text("Product Detail", style: AppWidget.lightTextStyle(),),


              SizedBox(height: 20.0,),


              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: Color(0xFFececf8), borderRadius: BorderRadius.circular(14)),
                child: TextField(
                  maxLines: 8,
                  controller: detailController,
                  decoration: InputDecoration( border: InputBorder.none),
                ),
              ),


              SizedBox(height: 30.0,),


              Text("Product Category", style: AppWidget.lightTextStyle(),),


              SizedBox(height: 20.09,),


              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: Color(0xFFececf8), borderRadius: BorderRadius.circular(14)),
                child:
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items: categoryitem
                        .map((item) => DropdownMenuItem(
                        value: item, child:
                    Text(item, style: AppWidget.semiBoldTextStyle())
                    )
                    ).toList(),
                    onChanged: ((value) => setState(() {
                      this.value = value;
                    })),
                    dropdownColor: Colors.white,
                    hint: Text("Select Category"),
                    iconSize: 37,
                    icon: Icon(Icons.arrow_drop_down_circle_outlined),
                    value: value,
                  ),
                ),
              ),


              SizedBox(height: 30.0,),


              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  width: MediaQuery.of(context).size.width/2,
                  child: ElevatedButton(
                      onPressed: (){
                        uploadItem();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                            child: Text("Add Product", style: TextStyle(fontSize: 23.0,),)),
                      )),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
