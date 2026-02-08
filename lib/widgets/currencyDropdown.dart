import 'package:currency_converter/models/currency_model.dart';
import 'package:flutter/material.dart';

class Currencydropdown extends StatelessWidget {
  final CurrencyModel? value;
  final List<CurrencyModel> items;
  final ValueChanged<CurrencyModel?> onChanged;
  final String hint;
  final String? label;
  final String? errorText;

  const Currencydropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
    this.label,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 56.0;

    return GestureDetector(
      onTap: () async {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset topLeft = box.localToGlobal(Offset.zero);
        final Size size = box.size;

        final selected = await showMenu<CurrencyModel>(
          context: context,
          position: RelativeRect.fromLTRB(
            topLeft.dx,
            topLeft.dy + size.height,
            topLeft.dx + size.width,
            topLeft.dy,
          ),
          items: [
            PopupMenuItem<CurrencyModel>(
              enabled: false,
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: size.width,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: itemHeight * 3),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: items.map((item) {
                        return InkWell(
                          onTap: () => Navigator.of(context).pop(item),
                          child: Container(
                            height: itemHeight,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(item.flag, style: const TextStyle(fontSize: 22, color: Colors.black)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${item.code} - ${item.name}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );

        if (selected != null) onChanged(selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          // show error text and red borders when present
          errorText: errorText,
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        isEmpty: value == null,
        child: Row(
        children: [
          if (label != null) Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              label!,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: value == null
                ? Text(hint, style: const TextStyle(color: Colors.black))
                : Row(
                    children: [
                      Text(value!.flag, style: const TextStyle(fontSize: 22, color: Colors.black)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${value!.code} - ${value!.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      ),
    );
  }
}
