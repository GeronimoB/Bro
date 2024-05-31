import 'package:bro_app_to/utils/current_state.dart';
import 'package:flutter/material.dart';

import 'custom_text_button.dart';

class ModalDecition extends StatefulWidget {
  final String text;
  final Function confirmCallback;
  final Function cancelCallback;
  const ModalDecition(
      {super.key,
      required this.text,
      required this.confirmCallback,
      required this.cancelCallback});

  @override
  State<ModalDecition> createState() => _ModalDecitionState();
}

class _ModalDecitionState extends State<ModalDecition> {
  @override
  Widget build(BuildContext context) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: const TextStyle(
                  color: Color(0xff00E050),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CustomTextButton(
                    onTap: () {
                      widget.confirmCallback.call();
                    },
                    text: translations!["yes"],
                    buttonPrimary: true,
                    width: 60,
                    height: 35),
                CustomTextButton(
                    onTap: () {
                      widget.cancelCallback.call();
                    },
                    text: translations!["not"],
                    buttonPrimary: false,
                    width: 60,
                    height: 35),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
