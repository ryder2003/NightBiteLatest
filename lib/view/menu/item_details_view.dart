import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue, FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_delivery/common_widget/round_icon_button.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:web3dart/web3dart.dart';
import '../../common/color_extension.dart';
import '../../common/constant.dart';
import '../more/my_order_view.dart';

class ItemDetailsView extends StatefulWidget {
  final String price;
  final String name;
  final String description;
  final String image;
  const ItemDetailsView({super.key, required this.price, required this.name, required this.description, required this.image });

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  Map<String, dynamic>? paymentIntent;
  late int price;
  int qty = 1;
  bool isFav = false;
  String? selectedSize;
  String? ingredients;

  late Web3Client _web3Client;
  late DeployedContract _contract;
  late ContractFunction _deposit;
  late ContractFunction _withdraw;
  late EthPrivateKey _credentials;

  @override
  void initState() {
    super.initState();
    price = int.parse(widget.price);
    _initializeWeb3();
  }

  Future<void> _initializeWeb3() async {
    const rpcUrl = "http://127.0.0.1:8545"; // Hardhat's default RPC URL
    const privateKey = "0xYOUR_PRIVATE_KEY"; // Replace with one from Hardhat's accounts

    _web3Client = Web3Client(rpcUrl, http.Client());
    _credentials = EthPrivateKey.fromHex(privateKey);

    // Load ABI
    String abi = await rootBundle.loadString('artifacts/contracts/Lock.sol/DeliveryPaymentERC20.json');
    var jsonAbi = jsonDecode(abi);
    var abiCode = ContractAbi.fromJson(jsonEncode(jsonAbi['abi']), "ExpenseManagerContract");

    // Set contract address
    EthereumAddress contractAddress = EthereumAddress.fromHex("0xYOUR_CONTRACT_ADDRESS");

    // Initialize deployed contract
    _contract = DeployedContract(abiCode, contractAddress);

    // Get contract functions
    _deposit = _contract.function("deposit");
    _withdraw = _contract.function("withdraw");
    //_getBalance = _contract.function("getBalance");
  }

  Future<void> _makeBlockchainPayment() async {
    try {
      // Call deposit function
      final transaction = Transaction.callContract(
        contract: _contract,
        function: _deposit,
        parameters: [BigInt.from(price), widget.name],
        value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0.01), // Adjust Ether amount if needed
      );

      // Send transaction
      final result = await _web3Client.sendTransaction(
        _credentials,
        transaction,
        chainId: 31337, // Hardhat's default chain ID
      );

      print("Transaction successful: $result");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment successful! TX: $result")),
      );
    } catch (e) {
      print("Error during transaction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.network(
            widget.image,
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              ); // Fallback widget in case the image fails to load
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(), // Show a loading indicator while the image loads
              );
            },
          ),
          Container(
            width: media.width,
            height: media.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.black, Colors.transparent, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: media.width - 60,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: TColor.white,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 35,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  widget.name,
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        IgnorePointer(
                                          ignoring: true,
                                          child: RatingBar.builder(
                                            initialRating: 4,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 20,
                                            itemPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 1.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: TColor.primary,
                                            ),
                                            onRatingUpdate: (rating) {
                                              print(rating);
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          " 4 Star Ratings",
                                          style: TextStyle(
                                              color: TColor.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "\$$price",
                                          style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 31,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          "/per Portion",
                                          style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  "Description",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  widget.description,
                                  style: TextStyle(
                                      color: TColor.secondaryText,
                                      fontSize: 12),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  child: Divider(
                                    color:
                                        TColor.secondaryText.withOpacity(0.4),
                                    height: 1,
                                  )),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  "Customize your Order",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  decoration: BoxDecoration(
                                      color: TColor.textfield,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedSize, // Display the selected value
                                      items: ["Small", "Big"].map((e) {
                                        return DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        // Update the state when a new value is selected
                                        setState(() {
                                          selectedSize = val;
                                        });
                                      },
                                      hint: const Text(
                                        "- Select the size of portion -",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  decoration: BoxDecoration(
                                      color: TColor.textfield,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: ingredients, // Display the selected value
                                      items: ["Sauce", "Napkins", "cheese dip"].map((e) {
                                        return DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        // Update the state when a new value is selected
                                        setState(() {
                                          ingredients = val;
                                        });
                                      },
                                      hint: const Text(
                                        "- Extra things to add -",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Row(
                                  children: [
                                    Text(
                                      "Number of Portions",
                                      style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        qty = qty - 1;

                                        if (qty < 1) {
                                          qty = 1;
                                        }
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        height: 25,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: TColor.primary,
                                            borderRadius:
                                                BorderRadius.circular(12.5)),
                                        child: Text(
                                          "-",
                                          style: TextStyle(
                                              color: TColor.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      height: 25,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: TColor.primary,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.5)),
                                      child: Text(
                                        qty.toString(),
                                        style: TextStyle(
                                            color: TColor.primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        qty = qty + 1;

                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        height: 25,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: TColor.primary,
                                            borderRadius:
                                                BorderRadius.circular(12.5)),
                                        child: Text(
                                          "+",
                                          style: TextStyle(
                                              color: TColor.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 220,
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Container(
                                      width: media.width * 0.25,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        color: TColor.primary,
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(35),
                                            bottomRight: Radius.circular(35)),
                                      ),
                                    ),
                                    Center(
                                      child: Stack(
                                        alignment: Alignment.centerRight,
                                        children: [
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  top: 8,
                                                  bottom: 8,
                                                  left: 10,
                                                  right: 20),
                                              width: media.width - 80,
                                              height: 190,
                                              decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  35),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  35),
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 12,
                                                        offset: Offset(0, 4))
                                                  ]),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Total Price",
                                                    style: TextStyle(
                                                        color:
                                                            TColor.primaryText,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Text(
                                                    "\$${(price * qty)}",
                                                    style: TextStyle(
                                                        color:
                                                            TColor.primaryText,
                                                        fontSize: 21,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  SizedBox(
                                                    width: 130,
                                                    height: 50,
                                                    child: RoundIconButton(
                                                        title: "Buy Now",
                                                        icon:
                                                            "assets/img/shopping_add.png",
                                                        color: TColor.primary,
                                                        onPressed: () {
                                                          //makePayment("80");
                                                          // Call the modal sheet with payment options
                                                          showPaymentOptions(context, widget.name,widget.price, widget.image);
                                                        }),
                                                  )
                                                ],
                                              )),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const MyOrderView()));
                                            },
                                            child: Container(
                                              width: 45,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          22.5),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2))
                                                  ]),
                                              alignment: Alignment.center,
                                              child: Image.asset(
                                                  "assets/img/shopping_cart.png",
                                                  width: 20,
                                                  height: 20,
                                                  color: TColor.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ]),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                  Container(
                    height: media.width - 20,
                    alignment: Alignment.bottomRight,
                    margin: const EdgeInsets.only(right: 4),
                    child: InkWell(
                        onTap: () {
                          isFav = !isFav;
                          setState(() {});
                        },
                        child: Image.asset(
                            isFav
                                ? "assets/img/favorites_btn.png"
                                : "assets/img/favorites_btn_2.png",
                            width: 70,
                            height: 70)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 35,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.asset(
                          "assets/img/btn_back.png",
                          width: 20,
                          height: 20,
                          color: TColor.white,
                        ),
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
                          color: TColor.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // void showPaymentOptions(BuildContext context, String name, String price, String image) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               "Choose Payment Method",
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: Theme.of(context).primaryColor,
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             ElevatedButton.icon(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 makePayment('80'); // Call the Stripe payment
  //               },
  //               icon: const Icon(Icons.payment),
  //               label: const Text("Pay Now"),
  //               style: ElevatedButton.styleFrom(
  //                 minimumSize: const Size(double.infinity, 50),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             ElevatedButton.icon(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 payWithBlockchain(name, price, image); // Placeholder for blockchain payment
  //               },
  //               icon: const Icon(Icons.currency_bitcoin),
  //               label: const Text("Pay with Blockchain"),
  //               style: ElevatedButton.styleFrom(
  //                 minimumSize: const Size(double.infinity, 50),
  //                 backgroundColor: Colors.orange,
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void showPaymentOptions(BuildContext context, String name, String price, String image) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Section
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Choose Payment Method",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 20),

              // Pay Now Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  makePayment('80'); // Call the Stripe payment
                },
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text("Pay Now"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.orange[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 10),

              // Pay with Blockchain Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  payWithBlockchain(name, price, image); // Placeholder for blockchain payment
                },
                icon: const Icon(Icons.currency_bitcoin, color: Colors.white),
                label: const Text("Pay with Blockchain"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 10),

              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void payWithBlockchain(String name, String price, String image) {
    // Placeholder logic for blockchain payment
    print("Blockchain payment initiated for $name at \$$price.");
  }


  Future<void> makePayment(String amount) async{
    try {
      paymentIntent = await createPaymentIntent(amount, 'INR');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent?['client_secret'],
              style: ThemeMode.dark, merchantDisplayName: 'Aarav'
          )).then((value) {

      });
      displayPaymentSheet();
    }catch(e,s){
      print('exception:$e$s');
    }
  }

  displayPaymentSheet()async{
    try{
      await Stripe.instance.presentPaymentSheet().then((value) async{

        // Add order details to Firebase after successful payment
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final orderData = {
            'userId': currentUser.uid,
            'userEmail': currentUser.email,
            'productName': widget.name,
            'price': widget.price,
            'productImage': widget.image,
            'timestamp': FieldValue.serverTimestamp(),
            'canteen Name': "BH-1",
            'latitude': 25.427184,
            'longitude': 81.771839,
          };

          await FirebaseFirestore.instance.collection('orders').add(orderData);
        }


        // //code for updating order into firebase
        // Map<String, dynamic> orderInfoMap={
        //   "Product": widget.name,
        //   "Price": widget.price,
        //   "Name": name,
        //   "Email": mail,
        //   "Image": image,
        //   "ProductImage": widget.image,
        // };
        // await DatabaseMethods().orderDetails(orderInfoMap);

        showDialog(context: context, builder: (_) => AlertDialog(
          content: Column(mainAxisSize: MainAxisSize.min,
            children: [Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green,),
                Text("Payment Successfull")
              ],
            )

            ],
          ),
        ));
        paymentIntent=null;
      }).onError((error, stackTrace){
        print("Error is :---> $error $stackTrace");
      });
    } on StripeException catch(e){
      print("Error is:---> $e");
      showDialog(context: context, builder: (_) => AlertDialog(
        content: Text("Cancelled"),
      ));
    } catch(e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency)async{
    try{
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]':'card'
      };

      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretkey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },body: body,
      );
      return jsonDecode(response.body);
    }catch(err){
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount){
    final calculatedAmount=(int.parse(amount)*100);
    return calculatedAmount.toString();
  }

}
