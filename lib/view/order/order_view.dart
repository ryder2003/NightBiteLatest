import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/view/order/order_details.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common_widget/popular_resutaurant_row.dart';
import '../more/my_order_view.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  TextEditingController txtSearch = TextEditingController();
  List<Map<String, dynamic>> orders = [];
  Position? userPosition;

  List offerArr = [
    {
      "image": "assets/img/offer_1.png",
      "name": "Café de Noires",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/offer_2.png",
      "name": "Isso",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/offer_3.png",
      "name": "Cafe Beans",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/offer_1.png",
      "name": "Café de Noires",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/offer_2.png",
      "name": "Isso",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/offer_3.png",
      "name": "Cafe Beans",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
  ];

  // Future<void> _fetchOrders() async {
  //   try {
  //     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('orders').get();
  //     List<Map<String, dynamic>> fetchedOrders = snapshot.docs.map((doc) {
  //       var data = doc.data() as Map<String, dynamic>;
  //       return {
  //         "image": data['productImage'] ?? "assets/img/default_image.png",
  //         "name": data['productName'] ?? "Unknown",
  //         "rate": data['price']?.toString() ?? "0.0",
  //         "rating": "N/A", // Placeholder if no rating is provided
  //         "type": data['canteen Name'] ?? "Unknown Canteen",
  //         "food_type": "Western Food", // or any specific value if it's constant
  //       };
  //     }).toList();
  //
  //     setState(() {
  //       orders = fetchedOrders;
  //     });
  //   } catch (e) {
  //     print("Error fetching orders: $e");
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _checkLocationPermission();
  //   _fetchOrders();
  // }

  Future<void> _checkLocationPermission() async {
    // Check location permission status
    PermissionStatus permissionStatus = await Permission.location.status;

    if (permissionStatus.isDenied) {
      // If permission is denied, request permission
      permissionStatus = await Permission.location.request();
      if (permissionStatus.isDenied) {
        _showPermissionDeniedDialog();
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      // If permanently denied, prompt user to open settings
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _fetchUserLocation() async {
    try {
      // Request and get the user's current location
      userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("User's Location: ${userPosition!.latitude}, ${userPosition!.longitude}");
    } catch (e) {
      print("Error fetching user's location: $e");
    }
  }

  Future<void> _fetchOrders() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('orders').get();
      List<Map<String, dynamic>> fetchedOrders = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          "image": data['productImage'] ?? "assets/img/default_image.png",
          "name": data['productName'] ?? "Unknown",
          "rate": data['price']?.toString() ?? "0.0",
          "rating": "N/A", // Placeholder if no rating is provided
          "type": data['canteen Name'] ?? "Unknown Canteen",
          "food_type": "Western Food", // or any specific value if it's constant
          "latitude": userPosition?.latitude ?? 0.0, // Add user's latitude
          "longitude": userPosition?.longitude ?? 0.0, // Add user's longitude
        };
      }).toList();

      setState(() {
        orders = fetchedOrders;
      });
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _fetchUserLocation().then((_) => _fetchOrders());
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Permission Required"),
        content: Text(
          "You can only accept orders while your location is enabled. Please allow location access to proceed.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Open app settings for location permissions
              await openAppSettings();
            },
            child: Text("Allow"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 46,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest Orders",
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
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       // Text(
              //       //   "Find discounts, Offers special\nmeals and more!",
              //       //   style: TextStyle(
              //       //       color: TColor.secondaryText,
              //       //       fontSize: 14,
              //       //       fontWeight: FontWeight.w500),
              //       // ),
              //     ],
              //   ),
              // ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 140,
                  height: 30,
                  child: RoundButton(title: "check Orders", fontSize: 12 , onPressed: () {}),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // ListView.builder(
              //   physics: const NeverScrollableScrollPhysics(),
              //   shrinkWrap: true,
              //   padding: EdgeInsets.zero,
              //   itemCount: offerArr.length,
              //   itemBuilder: ((context, index) {
              //     var pObj = offerArr[index] as Map? ?? {};
              //     return PopularRestaurantRow(
              //       pObj: orders[index],
              //       onTap: () {},
              //     );
              //   }),
              // ),

              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: orders.length,
                itemBuilder: ((context, index) {
                  var order = orders[index];
                  return PopularRestaurantRow(
                    pObj: order,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_)=> OrderDetailsScreen(order: order)));
                      print("Restaurant tapped! Lat: ${order['latitude']}, Long: ${order['longitude']}");
                    },
                  );
                }),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
