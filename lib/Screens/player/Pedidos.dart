import 'dart:convert';
import 'dart:io';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:bro_app_to/components/app_bar_title.dart';
import 'package:bro_app_to/components/custom_box_shadow.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/api_client.dart';

class Pedidos extends StatefulWidget {
  const Pedidos({super.key});

  @override
  PedidosState createState() => PedidosState();
}

class PedidosState extends State<Pedidos> {
  int _selectedPedido = -1;

  Future<List<PedidosModel>> fetchPedidos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.getCurrentUser().userId;
    try {
      final pedidos = await ApiClient().get('auth/orders/$userId');
      if (pedidos.statusCode == 200) {
        final jsonData = jsonDecode(pedidos.body);
        final orders = jsonData["orders"];
        return mapListToPedidos(orders).reversed.toList();
      } else {
        debugPrint('Error al obtener los videos.');
        return [];
      }
    } catch (e) {
      debugPrint('Error en la solicitud de videos: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: appBarTitle(translations!["ORDERS"]),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF00E050),
            size: 32,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF212121), Color(0xFF121212)],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 50),
            FutureBuilder<List<PedidosModel>>(
                future: fetchPedidos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF05FF00)),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Expanded(
                      child: Center(
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  } else {
                    final orders = snapshot.data ?? [];

                    if (orders.isEmpty) {
                      return const Expanded(
                        child: Center(
                          child: Text(
                            "¡Aún no tienes pedidos!",
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 22.0),
                          ),
                        ),
                      );
                    }
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        child: ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];

                              return _buildPedidoItem(
                                  order, _selectedPedido == index, index);
                            }),
                      ),
                    );
                  }
                }),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Image.asset(
                    'assets/images/Logo.png',
                    width: 104,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPedidoItem(PedidosModel pedido, bool isSelected, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPedido = index;
        });
        showOrder(pedido);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? const Color(0xff05FF00) : Colors.transparent,
              width: 2.0),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [const CustomBoxShadow(color: Color(0xff05FF00), blurRadius: 5)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  pedido.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  '€ ${pedido.amount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right, color: Color(0xff05FF00)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showOrder(PedidosModel pedido) {
    String fechaHoraFormateada =
        DateFormat('yyyy-MM-dd HH:mm').format(pedido.datetime);
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xff3B3B3B),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(5, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  translations!["PurchaseThanks"],
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color(0xff00E050),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  "${translations!["Product"]}: ${pedido.description}",
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "${translations!["PurchaseDateTime"]}: $fechaHoraFormateada",
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "${translations!["PaymentMethod"]}: ${pedido.paymentMethod}",
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "${translations!["facture"]}: #${pedido.orderId}",
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                Center(
                  child: CustomTextButton(
                      onTap: () {
                        _handleDownload(pedido.url);
                      },
                      text: translations!["Dfacture"],
                      buttonPrimary: true,
                      width: 164,
                      height: 31),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDownload(String fileUrl) async {
    if (fileUrl.isEmpty) {
      return;
    }

    final status = await Permission.storage.status;

    if (!status.isGranted) {
      final result = await Permission.storage.request();
      if (!result.isGranted) {
        return;
      }
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF05FF00)),
            ),
          );
        },
      );

      final fileExtension = path.extension(fileUrl);
      final response = await http.get(Uri.parse(fileUrl));
      final downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
      final file = File(
          '${downloadsDirectory!.path}/factura_${DateTime.now().millisecondsSinceEpoch}$fileExtension');

      await file.writeAsBytes(response.bodyBytes);

      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xff3B3B3B),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(5, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      translations!["congrats"],
                      style: const TextStyle(
                          color: Color(0xff00E050),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      translations!["Factureincar"],
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ));
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Ha habido un error en la descarga, intente nuevamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      debugPrint(e.toString());
    }
  }
}

class PedidosModel {
  String description;
  String amount;
  DateTime datetime;
  String paymentMethod;
  String orderId;
  String url;

  PedidosModel({
    required this.description,
    required this.amount,
    required this.datetime,
    required this.paymentMethod,
    required this.orderId,
    required this.url,
  });

  factory PedidosModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDatetime = DateTime.parse(json['fecha']);

    String formattedOrderId = json['id'].toString().padLeft(6, '0');

    return PedidosModel(
      description: json['description'],
      amount: json['amount'].toString(),
      datetime: parsedDatetime,
      paymentMethod: json['payment_method'],
      orderId: formattedOrderId,
      url: json['factura'] ?? '',
    );
  }
}

List<PedidosModel> mapListToPedidos(List<dynamic> lista) {
  return lista.map((item) => PedidosModel.fromJson(item)).toList();
}
