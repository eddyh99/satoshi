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
  int? _selectedPlanIndex;
  String? _debugMessage;

  List<ProductDetails> _products = [];

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
        '3 Month', 700, '3 Month Regular', 'app.satoshisignal.3month'),
    SubscriptionPlan(
        '1 Month', 300, '1 Month Regular', 'app.satoshisignal.monthly'),
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
        // Optionally notify the user about pending status
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        log('Purchase canceled: ${purchaseDetails.productID}');
        _removeLoader();
      }
    }
  }

  Future<void> _restorePendingPurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Stream<List<PurchaseDetails>> purchaseStream =
          _inAppPurchase.purchaseStream;

      purchaseStream.listen((purchaseDetailsList) async {
        for (var purchaseDetails in purchaseDetailsList) {
          log('Restored purchase: ${purchaseDetails.productID}, status: ${purchaseDetails.status}');

          if (purchaseDetails.status == PurchaseStatus.purchased ||
              purchaseDetails.status == PurchaseStatus.restored) {
            // Deliver the product and complete the transaction
            _deliverProduct(purchaseDetails);
            await _inAppPurchase.completePurchase(purchaseDetails);
          } else if (purchaseDetails.status == PurchaseStatus.pending) {
            log('Pending purchase found: ${purchaseDetails.productID}');
            await _inAppPurchase.completePurchase(purchaseDetails);
          } else if (purchaseDetails.status == PurchaseStatus.error) {
            log('Purchase error: ${purchaseDetails.error}');
          }
        }
      });

      log('Restore purchase triggered successfully');
    } catch (e) {
      log('Error while restoring purchases: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      if (result['code'] == '201') {
        // Handle successful validation
        log('Subscription registered successfully');

        // Complete the purchase transaction
        _inAppPurchase.completePurchase(purchaseDetails);
        setState(() {
          _isLoading = false;
        });
        Get.toNamed(
          "/front-screen/login",
        );
        _showSuccessDialog();
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
      print('In-app purchase not available');
    }
  }

  Future<void> _loadProducts() async {
    Set<String> ids = _plans.map((plan) => plan.id).toSet();

    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(ids);

    log(response.productDetails.toString());
    if (response.error != null) {
      print('Error fetching products: ${response.error}');
    } else {
      if (response.productDetails.isEmpty) {
        print('No products found. Please check your App Store Connect setup.');
      } else {
        print('Loaded products: ${response.productDetails}');
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
          title: Text('Confirm Subscription'),
          content: Text(
              'Do you want to subscribe to ${plan.name} for €${plan.price}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSubscription(plan);
              },
              child: Text('Confirm'),
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
      log('Error during subscription: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                Text('Please choose your subscription',
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
                SizedBox(height: 20),
                ..._plans.map((plan) {
                  int index = _plans.indexOf(plan);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlanIndex = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedPlanIndex == index
                            ? Color(0xb48b3d00)
                            : Color(0xbfa57300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(plan.name,
                              style: TextStyle(color: Colors.white)),
                          Text('€ ${plan.price}',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading || _selectedPlanIndex == null
                      ? null
                      : () => _confirmSubscription(_plans[_selectedPlanIndex!]),
                  child: Text('Subscribe'),
                ),
              ],
            ),
          ),
        )));
  }
}

class SubscriptionPlan {
  final String name;
  final int price;
  final String description;
  final String id;

  SubscriptionPlan(this.name, this.price, this.description, this.id);
}
