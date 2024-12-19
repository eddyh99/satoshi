import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:satoshi/utils/functions.dart';
import 'package:satoshi/utils/globalvar.dart';

class InappView extends StatefulWidget {
  const InappView({super.key});

  @override
  State<InappView> createState() {
    return _InappViewState();
  }
}

class _InappViewState extends State<InappView> {
  var email = Get.arguments[0]["email"];
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isLoading = false;
  SubscriptionPlan? _selectedPlan;
  String? _debugMessage;

  List<ProductDetails> _products = [];

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      name: '1 Month Satoshi Signal Membership',
      price: 300,
      id: 'app.satoshisignal.monthly',
    ),
    SubscriptionPlan(
      name: '3 Month Satoshi Signal Membership',
      price: 700,
      id: 'app.satoshisignal.3month',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      for (var purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          log('Purchase successful: ${purchaseDetails.productID}');
          _deliverProduct(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.restored) {
          log('Purchase restored: ${purchaseDetails.productID}');
          _deliverProduct(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          log('Purchase error: ${purchaseDetails.error}');
          _removeLoader();
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          log('Purchase canceled: ${purchaseDetails.productID}');
          _removeLoader();
        }
      }
    });
  }

  void _showDebugMessage(String message) {
    setState(() {
      _debugMessage = message;
    });
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Complete any pending purchase
        _inAppPurchase.completePurchase(purchaseDetails);

        log('Purchase successful: ${purchaseDetails.productID}');
        _deliverProduct(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        log('Purchase error: ${purchaseDetails.error}');
        _removeLoader();
      } else if (purchaseDetails.status == PurchaseStatus.pending) {
        log('Purchase pending for product: ${purchaseDetails.productID}');
        _showPendingPurchaseDialog();

        // Optionally notify the user about pending status
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        log('Purchase canceled: ${purchaseDetails.productID}');
        _removeLoader();
      }
    }
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Extract the receipt (Base64 string)
    final String receipt =
        purchaseDetails.verificationData.serverVerificationData;

    log('Sending receipt for validation: $receipt');

    // Send the receipt to your backend
    Map<String, dynamic> mdata = {
      'email': email,
      'receipt': receipt, // Send the receipt for backend validation
    };

    var url = Uri.parse("$urlapi/auth/ios_purchase");
    await satoshiAPI(url, jsonEncode(mdata)).then((ress) {
      log("Request Data: $ress");
      var result = jsonDecode(ress);
      log(result['code']);

      if (result['code'] == '201') {
        log("ok");
        setState(() {
          _isLoading = false;
        });
        if (result['isLinked'] == "exists") {
          log("exists");
          // Notify user about the existing subscription
          _showSubscriptionConflictDialog();
        } else {
          log("sukses");
          // Deliver the product if validation is successful
          _showSuccessDialog();
        }
      } else {
        log('Validation failed with message: ${result['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((error) {
      log('Error during API call: $error');
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _showSubscriptionConflictDialog() {
    Get.defaultDialog(
      title: "Subscription Conflict",
      middleText:
          "This subscription is already linked to another account. Please cancel it first and try again.",
      textConfirm: "OK",
      onConfirm: () {
        Get.back(); // Close the dialog
        Get.toNamed("/front-screen/login"); // Navigate back to the login screen
      },
    );
  }

  void _showPendingPurchaseDialog() {
    Get.defaultDialog(
      title: "Purchase Pending",
      middleText:
          "Your purchase is still pending. Please wait for it to complete or try again later.",
      textConfirm: "OK",
      onConfirm: () {
        Get.back(); // Close the dialog
        Get.toNamed("/front-screen/login"); // Navigate back to the login screen
      },
    );
  }

  void _showSuccessDialog() {
    Get.defaultDialog(
      title: "Success",
      middleText: "Your subscription has been successfully registered!",
      onConfirm: () {
        // Redirect to login page after the user clicks 'OK'
        Get.toNamed("/front-screen/login");
      },
      textConfirm: "OK",
    );
  }

  void _removeLoader() {
    Navigator.of(context, rootNavigator: true).pop();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (available) {
      await _loadProducts();
    } else {
      log('In-app purchase not available');
    }
  }

  Future<void> _loadProducts() async {
    Set<String> ids = _plans.map((plan) => plan.id).toSet();

    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(ids);

    log(response.productDetails.toString());
    if (response.error != null) {
      log('Error fetching products: ${response.error}');
    } else {
      if (response.productDetails.isEmpty) {
        log('No products found. Please check your App Store Connect setup.');
      } else {
        log('Loaded products: ${response.productDetails}');
        if (mounted) {
          setState(() {
            _products = response.productDetails;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // Clean up the purchaseStream listener
    _inAppPurchase.purchaseStream.listen((event) {}).cancel();
    super.dispose();
  }

  void _confirmSubscription(SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Subscription'),
          content: Text(
            'Do you want to subscribe to ${plan.name} for €${plan.price}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSubscription(plan);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _handleSubscription(SubscriptionPlan plan) async {
    setState(() {
      _isLoading = true;
    });

    showLoaderDialog(context);
    try {
      // Find the ProductDetails for the selected plan
      final ProductDetails productDetails = _products.firstWhere(
        (product) => product.id == plan.id,
        orElse: () => throw Exception('Product not found for ${plan.id}'),
      );
      String hashedEmail = sha256.convert(utf8.encode(email)).toString();

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: hashedEmail,
      );
      bool result =
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      log('Purchase initiated: $result');
    } catch (e) {
      _showDebugMessage('Error: $e');
      setState(() {
        _isLoading = false;
      });
      _showPendingPurchaseDialog();
      log('Error during subscription: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    Get.defaultDialog(
      title: "Error",
      middleText: message,
      textConfirm: "OK",
      onConfirm: () {
        Get.back(); // Close the dialog
      },
    );
  }

  @override
// Define the currently selected subscription in the state
  int _selectedPlanIndex = -1;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please choose your subscription',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 20),

                // Monthly Satoshi Signal Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPlanIndex = 0; // Select Monthly Plan
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: _selectedPlanIndex == 0
                          ? Color(0xFFBFA573)
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Monthly Satoshi Signal',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),

                if (_selectedPlanIndex == 0) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Description: Enjoy premium signals for 1 month.\n'
                    'Duration: 1 Month\n'
                    'Price: 300 EUR/month',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],

                const SizedBox(height: 20),

                // 3 Month Satoshi Signal Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPlanIndex = 1; // Select 3 Month Plan
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: _selectedPlanIndex == 1
                          ? Color(0xFFBFA573)
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      '3 Month Satoshi Signal',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),

                if (_selectedPlanIndex == 1) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Description: Enjoy premium signals for 3 months.\n'
                    'Duration: 3 Months\n'
                    'Price: 750 EUR/3 months',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],

                const SizedBox(height: 20),

                // Subscribe Button
                ElevatedButton(
                  onPressed: _selectedPlanIndex == -1
                      ? null
                      : () => _confirmSubscription(
                            _selectedPlanIndex == 0
                                ? SubscriptionPlan(
                                    name: 'Monthly Satoshi Signal',
                                    price: 300,
                                    id: 'monthly_plan')
                                : SubscriptionPlan(
                                    name: '3 Month Satoshi Signal',
                                    price: 750,
                                    id: '3_month_plan'),
                          ),
                  child: const Text('Subscribe'),
                ),

                if (_debugMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Debug: $_debugMessage',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionPlan {
  final String name;
  final int price;
  final String id;

  SubscriptionPlan({
    required this.name,
    required this.price,
    required this.id,
  });
}
