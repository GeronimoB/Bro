import 'package:bro_app_to/components/app_bar_title.dart';
import 'package:bro_app_to/components/custom_box_shadow.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'metodo_pago_screen.dart';
import '../providers/player_provider.dart';
import '../utils/plan_model.dart';

List<Plan> planes = [
  Plan(
    idPlan: 'price_1OwbK8IkdX2ffauu5v0rezbw',
    nombre: translations!["Plan_1_name"],
    precio: '19,99',
    descripcion: translations!["Plan_1_description"],
    descripcionLarga: translations!["Plan_1_long_description"],
    cualidades: [
      {"text": translations!["Plan_1_quality_1"], "included": true},
      {"text": translations!["Plan_1_quality_2"], "included": true},
      {
        "text": translations!["Plan_1_quality_3"],
        "included": true,
        "isVisualizacion": true,
        "visualizacion": translations!["Plan_1_visualization"],
        "color": 0xfff23325
      },
      {"text": translations!["Plan_1_quality_4"], "included": false},
      {"text": translations!["Plan_1_quality_5"], "included": false},
      {"text": translations!["Plan_1_quality_6"], "included": true},
    ],
  ),
  Plan(
    idPlan: 'price_1OwceiIkdX2ffauuyNaKIHHL',
    nombre: translations!["Plan_2_name"],
    precio: '29,99',
    descripcion: translations!["Plan_2_description"],
    descripcionLarga: translations!["Plan_2_long_description"],
    cualidades: [
      {"text": translations!["Plan_2_quality_11"], "included": true},
      {"text": translations!["Plan_2_quality_1"], "included": true},
      {"text": translations!["Plan_2_quality_2"], "included": true},
      {
        "text": translations!["Plan_2_quality_3"],
        "included": true,
        "isVisualizacion": true,
        "visualizacion": translations!["Plan_2_visualization"],
        "color": 0xfff2c925
      },
      {"text": translations!["Plan_2_quality_4"], "included": false},
      {"text": translations!["Plan_2_quality_5"], "included": false},
      {"text": translations!["Plan_2_quality_6"], "included": true},
    ],
  ),
  Plan(
    idPlan: 'price_1Owcf5IkdX2ffauudm4v0KAQ',
    nombre: translations!["Plan_3_name"],
    precio: '49,99',
    descripcion: translations!["Plan_3_description"],
    descripcionLarga: translations!["Plan_3_long_description"],
    cualidades: [
      {"text": translations!["Plan_3_quality_1"], "included": true},
      {"text": translations!["Plan_3_quality_2"], "included": true},
      {
        "text": translations!["Plan_3_quality_3"],
        "included": true,
        "isVisualizacion": true,
        "visualizacion": translations!["Plan_3_visualization"],
        "color": 0xffd1eb6c
      },
      {"text": translations!["Plan_3_quality_4"], "included": false},
      {"text": translations!["Plan_3_quality_5"], "included": false},
      {"text": translations!["Plan_3_quality_6"], "included": true},
    ],
  ),
  Plan(
    idPlan: 'price_1OwcfMIkdX2ffauuEqdLsX5h',
    nombre: translations!["Plan_4_name"],
    precio: '89,99',
    descripcion: translations!["Plan_4_description"],
    descripcionLarga: translations!["Plan_4_long_description"],
    cualidades: [
      {"text": translations!["Plan_4_quality_1"], "included": true},
      {"text": translations!["Plan_4_quality_2"], "included": true},
      {
        "text": translations!["Plan_4_quality_3"],
        "included": true,
        "isVisualizacion": true,
        "visualizacion": translations!["Plan_4_visualization"],
        "color": 0xff05FF00
      },
      {"text": translations!["Plan_4_quality_4"], "included": true},
      {"text": translations!["Plan_4_quality_5"], "included": true},
      {"text": translations!["Plan_4_quality_6"], "included": true},
    ],
  ),
];

class PlanesPago extends StatefulWidget {
  const PlanesPago({super.key});

  @override
  PlanesPagoState createState() => PlanesPagoState();
}

class PlanesPagoState extends State<PlanesPago> {
  int _selectedCardIndex = -1; // Índice de la tarjeta seleccionada

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/backgroundplanes.png'),
          fit: BoxFit.cover,
        ),
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: appBarTitle(translations!["PLANS"]),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: planes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildCard(index);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: CustomTextButton(
                  onTap: () {
                    final playerProvider =
                        Provider.of<PlayerProvider>(context, listen: false);
                    final precio = playerProvider
                        .getActualPlan()!
                        .precio
                        .replaceAll(',', '.');
                    final precioDouble = double.parse(precio);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MetodoDePagoScreen(
                                valueToPay: precioDouble,
                              )),
                    );
                  },
                  text: translations!["next"],
                  buttonPrimary: true,
                  width: 116,
                  height: 39,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SvgPicture.asset(
                    'assets/icons/Logo.svg',
                    width: 104,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    Plan plan = planes[index];

    bool isSelected = _selectedCardIndex == index;

    return GestureDetector(
      onTap: () {
        final playerProvider =
            Provider.of<PlayerProvider>(context, listen: false);
        playerProvider.selectPlan(plan);
        setState(() {
          if (isSelected) {
            _selectedCardIndex = -1;
          } else {
            _selectedCardIndex = index;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: const Color(0xFF00F056),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    const CustomBoxShadow(
                      color: Color.fromARGB(255, 5, 255, 80),
                      offset: Offset(0, 0),
                    ),
                  ]
                : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/Logo.svg',
                  width: 62,
                  height: 32,
                ),
                const SizedBox(width: 10),
                Text(
                  plan.nombre,
                  style: const TextStyle(
                      color: Color(0xFF00F056),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const Spacer(),
                Text(
                  'Total: ${plan.precio}€',
                  style: const TextStyle(
                      color: Color(0xFF00F056),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              translations!["whatsIncluded"],
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!plan.isExpanded) ...[
              ...plan.cualidades
                  .map((cualidad) => cualidades(cualidad))
                  .toList()
                  .take(2),
              InkWell(
                child: Text(
                  translations!["seeMore"],
                  style: const TextStyle(
                      color: Color(0xFF00F056),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontStyle: FontStyle.italic),
                ),
                onTap: () => setState(() {
                  plan.isExpanded = true;
                }),
              ),
            ] else ...[
              ...plan.cualidades
                  .map((cualidad) => cualidades(cualidad))
                  .toList(),
              InkWell(
                child: Text(
                  translations!["seeLess"],
                  style: const TextStyle(
                      color: Color(0xFF00F056),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontStyle: FontStyle.italic),
                ),
                onTap: () => setState(() {
                  plan.isExpanded = false;
                }),
              ),
            ],
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
    return Row(
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
    );
  }
}
