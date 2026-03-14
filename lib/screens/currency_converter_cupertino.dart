import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CurrencyCoverterCupertinoPage extends StatefulWidget {
  const CurrencyCoverterCupertinoPage({super.key});

  @override
  State<CurrencyCoverterCupertinoPage> createState() =>
      _CurrencyCoverterCupertinoPageState();
}

class _CurrencyCoverterCupertinoPageState
    extends State<CurrencyCoverterCupertinoPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _valueFocusNode = FocusNode();

  final List<String> _currencies = [
    'USD',
    'INR',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'SGD',
  ];

  String? _fromCurrency = 'USD';
  String? _toCurrency = 'INR';

  double _convertedAmount = 0;
  bool _isLoading = false;

  String? _fromError;
  String? _toError;
  String? _valueError;

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      setState(() {
        final text = _textController.text;
        if (text.isEmpty) {
          if (_valueError == 'Please enter a valid number') {
            _valueError = null;
          }
        } else {
          final parsed = double.tryParse(text);
          _valueError = parsed == null ? 'Please enter a valid number' : null;
        }
      });
    });

    _valueFocusNode.addListener(() {
      if (_valueFocusNode.hasFocus && _valueError != null) {
        setState(() {
          _valueError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }

  double _rate(String code) {
    const rates = {
      'USD': 1.0,
      'INR': 83.0,
      'EUR': 0.93,
      'GBP': 0.80,
      'JPY': 134.0,
      'AUD': 1.60,
      'CAD': 1.35,
      'SGD': 1.35,
    };
    return rates[code] ?? 1.0;
  }

  double _convertAmount(double amount, String from, String to) {
    if (from == to) return amount;
    final inUsd = amount / _rate(from);
    return inUsd * _rate(to);
  }

  Future<void> _showCurrencyPicker(bool isFrom) async {
    final current = isFrom ? _fromCurrency : _toCurrency;
    final initialIndex = current == null ? 0 : _currencies.indexOf(current);

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => SizedBox(
        height: 260,
        child: CupertinoPicker(
          backgroundColor: CupertinoColors.systemBackground,
          scrollController:
              FixedExtentScrollController(initialItem: initialIndex),
          itemExtent: 40,
          onSelectedItemChanged: (index) {
            setState(() {
              if (isFrom) {
                _fromCurrency = _currencies[index];
                _fromError = null;
              } else {
                _toCurrency = _currencies[index];
                _toError = null;
              }
            });
          },
          children: _currencies
              .map((code) => Center(child: Text(code)))
              .toList(growable: false),
        ),
      ),
    );
  }

  void _convert() {
    setState(() {
      _fromError = _fromCurrency == null ? 'Please select a currency' : null;
      _toError = _toCurrency == null ? 'Please select a currency' : null;

      if (_textController.text.isEmpty) {
        _valueError = 'Please enter value';
      } else if (double.tryParse(_textController.text) == null) {
        _valueError = 'Please enter a valid number';
      } else {
        _valueError = null;
      }
    });

    if (_fromError != null || _toError != null || _valueError != null) {
      if (_valueError != null) {
        _valueFocusNode.requestFocus();
      }
      return;
    }

    setState(() => _isLoading = true);

    final amount = double.tryParse(_textController.text) ?? 0;
    final result = _convertAmount(amount, _fromCurrency!, _toCurrency!);

    setState(() {
      _convertedAmount = result;
      _isLoading = false;
      _fromError = null;
      _toError = null;
      _valueError = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _reset() {
    setState(() {
      _textController.clear();
      _convertedAmount = 0;
      _fromCurrency = 'USD';
      _toCurrency = 'INR';
      _fromError = null;
      _toError = null;
      _valueError = null;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _showExitConfirmation() async {
    final shouldExit = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Exit app?'),
        content: const Text('Are you going to exit?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildErrorText(String? text) {
      if (text == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: CupertinoColors.destructiveRed,
            fontSize: 12,
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
          onPressed: _showExitConfirmation,
        ),
        middle: const Text('Currency Converter'),
        backgroundColor: CupertinoColors.systemGrey,
      ),
      backgroundColor: CupertinoColors.systemGrey2,
      child: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _convertedAmount == 0
                          ? '0'
                          : _convertedAmount.toStringAsFixed(2),
                      style: const TextStyle(
                        color: CupertinoColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 55,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton.filled(
                      onPressed: () => _showCurrencyPicker(true),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('From'),
                          Text(_fromCurrency ?? 'Select'),
                        ],
                      ),
                    ),
                    buildErrorText(_fromError),
                    const SizedBox(height: 8),
                    CupertinoButton.filled(
                      onPressed: () => _showCurrencyPicker(false),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('To'),
                          Text(_toCurrency ?? 'Select'),
                        ],
                      ),
                    ),
                    buildErrorText(_toError),
                    const SizedBox(height: 10),
                    CupertinoTextField(
                      controller: _textController,
                      focusNode: _valueFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      placeholder: 'Please enter an amount',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: CupertinoColors.systemGrey,
                          width: 1.5,
                        ),
                      ),
                      suffix: _textController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: _reset,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  color: CupertinoColors.black,
                                ),
                              ),
                            )
                          : null,
                    ),
                    buildErrorText(_valueError),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: CupertinoButton.filled(
                            onPressed: _convert,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 0),
                            child: const Text('Convert'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: CupertinoButton(
                            color: CupertinoColors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 0),
                            borderRadius: BorderRadius.circular(10),
                            onPressed: _reset,
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: CupertinoColors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const ColoredBox(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              child: Center(child: CupertinoActivityIndicator()),
            ),
        ],
      ),
    );
  }
}
