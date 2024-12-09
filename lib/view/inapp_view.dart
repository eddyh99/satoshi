import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InappView extends StatefulWidget {
  const InappView({super.key});

  @override
  State<InappView> createState() {
    return _InappViewState();
  }
}

class _InappViewState extends State<InappView> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isLoading = false;
  int? _selectedPlanIndex;

  List<ProductDetails> _products =
      []; // List to hold product details from in-app purchases

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
    if (response.error != null) {
      print('Error fetching products: ${response.error}');
    } else {
      setState(() {
        _products = response.productDetails;
      });
      print('Loaded products: ${_products}');
    }
  }

  void _handleSubscription(SubscriptionPlan plan) async {
    setState(() {
      _isLoading = true;
    });

    // Find the ProductDetails for the selected plan
    final ProductDetails? productDetails = _products.firstWhere(
      (product) => product.id == plan.id,
      orElse: () => throw Exception(
          'Product not found for ${plan.id}'), // Handle the case where product is not found
    );

    if (productDetails != null) {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Please choose your subscription',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                }).toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading || _selectedPlanIndex == null
                      ? null
                      : () => _handleSubscription(_plans[_selectedPlanIndex!]),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Subscribe'),
                )
              ],
            ),
          ),
        ));
  }
}

class SubscriptionPlan {
  final String name;
  final int price;
  final String description;
  final String id;

  SubscriptionPlan(this.name, this.price, this.description, this.id);
}
