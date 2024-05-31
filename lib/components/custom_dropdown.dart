import 'package:flutter/material.dart';

class DropdownWidget<T> extends StatefulWidget {
  const DropdownWidget({
    Key? key,
    required this.items,
    required this.onChanged,
    required this.value,
    this.header,
    this.unselectedItemColor,
    this.width = 80,
    this.offsetX = -65,
  }) : super(key: key);
  final Map<String, String> items;
  final String? header;
  final void Function(String value) onChanged;
  final String value;
  final double width;
  final double offsetX;
  final Color? unselectedItemColor;

  @override
  State<DropdownWidget<T>> createState() => _DropdownWidgetState<T>();
}

class _DropdownWidgetState<T> extends State<DropdownWidget<T>>
    with SingleTickerProviderStateMixin {
  var _expanded = false;
  OverlayEntry? overlay;

  final key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void _changeExpansionStatus(BuildContext context, double offsetX) {
    if (_expanded) {
      removeOverlay();
    } else {
      insertOverlay(context, offsetX);
    }

    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  void dispose() {
    if (_expanded && overlay != null) overlay?.remove();
    super.dispose();
  }

  void removeOverlay() {
    overlay?.remove();
  }

  final layerLink = LayerLink();

  void insertOverlay(BuildContext context, double offsetX) {
    overlay = OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        top: key.currentContext!.position.dy,
        left: key.currentContext!.position.dx,
        child: CompositedTransformFollower(
          showWhenUnlinked: false,
          offset: Offset(
            offsetX,
            40,
          ),
          link: layerLink,
          child: _OverlayDropdown(
            width: widget.width,
            selectedValue: widget.value,
            values: widget.items,
            color: widget.unselectedItemColor,
            onSelectedItem: (val) {
              _changeExpansionStatus(context, offsetX);
              widget.onChanged.call(val);
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.header != null) ...[
          Text(
            widget.header!,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
        ],
        CompositedTransformTarget(
          link: layerLink,
          child: GestureDetector(
            onTap: () {
              _changeExpansionStatus(context, widget.offsetX);
            },
            child: Container(
              key: key,
              height: 42,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
              width: widget.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: widget.width * 0.6,
                    child: Text(
                      widget.items.entries
                          .firstWhere((entry) => entry.key == widget.value,
                              orElse: () => const MapEntry('', ''))
                          .value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 24,
                    color: Color(0xFF00F056),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverlayDropdown<T> extends StatelessWidget {
  const _OverlayDropdown({
    Key? key,
    required this.values,
    required this.selectedValue,
    required this.onSelectedItem,
    required this.width,
    this.color = Colors.transparent,
  }) : super(key: key);

  final Map<String, String> values;
  final Color? color;
  final double width;
  final String selectedValue;
  final void Function(String value) onSelectedItem;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.transparent,
      child: Container(
        width: 180,
        height: null,
        constraints: const BoxConstraints(maxHeight: 180),
        decoration: BoxDecoration(
          color: const Color.fromARGB(230, 41, 41, 41),
          border: Border.all(
            color: const Color(0xFF00F056),
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: values.entries
                .map(
                  (entry) => _OverlayDropdownItem(
                    value: entry.key,
                    displayText: entry.value,
                    onTap: onSelectedItem,
                    isSelected: entry.key == selectedValue,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _OverlayDropdownItem<T> extends StatelessWidget {
  const _OverlayDropdownItem({
    Key? key,
    required this.value,
    required this.displayText,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final String value;
  final String displayText;
  final bool isSelected;
  final void Function(String value) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap.call(value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 12,
        ),
        height: 32,
        color: Colors.transparent,
        child: Text(
          displayText,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00F056) : Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

extension _BuildContextExtension on BuildContext {
  RenderBox get renderBox => findRenderObject() as RenderBox;
  Offset get position {
    final render = renderBox.localToGlobal(Offset.zero);
    return render;
  }
}
