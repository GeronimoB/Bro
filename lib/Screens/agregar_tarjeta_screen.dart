import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class AgregarTarjetaScreen extends StatefulWidget {
  const AgregarTarjetaScreen({super.key});

  @override
  AgregarTarjetaScreenState createState() => AgregarTarjetaScreenState();
}

class AgregarTarjetaScreenState extends State<AgregarTarjetaScreen> {
  InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subscription = _inAppPurchase.purchaseStream.listen(
      _listenToPurchase,
      onError: (error) {
        // Manejar error
      },
    );
    _initializeStore();
  }

  Future<void> _initializeStore() async {
    const Set<String> _productIds = {'0001', '0002', '0003', '0004'};
    final response = await _inAppPurchase.queryProductDetails(_productIds);
    print(response);
    if (response.notFoundIDs.isNotEmpty) {
      print('no se encontro nada');
      // Manejar productos no encontrados
    }
    if (response.error == null) {
      setState(() {
        _products = response.productDetails;
      });
    }
  }

  void _listenToPurchase(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Compra realizada
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Error en compra
      } else if (purchaseDetails.status == PurchaseStatus.pending) {
        // Compra pendiente
      }
    }
  }

  void _buyProduct(ProductDetails productDetails) {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compra dentro de la app')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ListTile(
                  title: Text(product.title),
                  subtitle: Text(product.price),
                  trailing: ElevatedButton(
                    onPressed: () => _buyProduct(product),
                    child: Text('Comprar'),
                  ),
                );
              },
            ),
    );
  }
}
