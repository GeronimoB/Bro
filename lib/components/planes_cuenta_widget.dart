import 'package:bro_app_to/Screens/metodo_pago_screen.dart';
import 'package:bro_app_to/components/custom_box_shadow.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/providers/player_provider.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:bro_app_to/utils/plan_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class PlanesCuentaWidget extends StatefulWidget {
  final Plan plan;
  final bool isActualPlan;
  final Function(BuildContext, PlayerProvider) cancelModal;
  const PlanesCuentaWidget(
      {required this.plan,
      required this.isActualPlan,
      required this.cancelModal,
      super.key});

  @override
  State<PlanesCuentaWidget> createState() => _PlanesCuentaWidgetState();
}

class _PlanesCuentaWidgetState extends State<PlanesCuentaWidget> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final isActualPlan = widget.isActualPlan;
    final playerProvider = Provider.of<PlayerProvider>(context);
    return Container(
      width: 360,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: const Color(0xFF05FF00)),
        boxShadow: isActualPlan
            ? [const CustomBoxShadow(color: Color(0xFF05FF00), blurRadius: 10)]
            : null,
        borderRadius: BorderRadius.circular(40),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SvgPicture.asset('assets/icons/Logo.svg', width: 80),
                Text(
                  plan.nombre,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF05FF00),
                      height: 1),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              translations!["whatsIncluded"],
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...plan.cualidades.map((cualidad) => cualidades(cualidad)).toList(),
            const SizedBox(height: 8),
            Center(
              child: CustomTextButton(
                onTap: () {
                  if (!isActualPlan) {
                    final precio = plan.precio.replaceAll(',', '.');
                    final precioDouble = double.parse(precio);
                    playerProvider.isSubscriptionPayment = true;
                    playerProvider.isNewSubscriptionPayment = false;
                    playerProvider.selectPlan(plan);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MetodoDePagoScreen(
                                valueToPay: precioDouble,
                              )),
                    );
                  } else {
                    widget.cancelModal(context, playerProvider);
                  }
                },
                text: isActualPlan
                    ? translations!["cancel"]
                    : translations!["subscribe"],
                buttonPrimary: true,
                width: 116,
                height: 42,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cualidades(Map<String, dynamic> cualidad) {
    bool included = cualidad["included"];
    String text = cualidad["text"];
    String visualizacion = cualidad["visualizacion"] ?? '';
    int color = cualidad["color"] ?? 0;
    bool isVisualizacion = cualidad["isVisualizacion"] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            included ? Icons.check : Icons.cancel,
            size: 24,
            color: included
                ? const Color(0xFF05FF00)
                : const Color.fromARGB(255, 242, 51, 37),
          ),
          const SizedBox(
            width: 5,
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                maxLines: 1,
              ),
            ),
          ),
          if (isVisualizacion)
            Text(
              visualizacion,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Montserrat',
                color: Color(color),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
        ],
      ),
    );
  }
}
