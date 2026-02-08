import 'package:currency_converter/models/currency_model.dart';
import 'package:currency_converter/services/api_services.dart';
import 'package:currency_converter/widgets/currencyDropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyCoverterMaterialPage extends StatefulWidget {
  const CurrencyCoverterMaterialPage({super.key});

  @override
  State<CurrencyCoverterMaterialPage> createState() =>
      _CurrencyCoverterMaterialPageState();
}

class _CurrencyCoverterMaterialPageState
    extends State<CurrencyCoverterMaterialPage> {
  TextEditingController textEditingController = TextEditingController();
  final Apiservices _apiservices = Apiservices();

  List<CurrencyModel> currencies = [];
  CurrencyModel? fromCurrency;
  CurrencyModel? toCurrency;

  double convertedAmount = 0;
  bool isLoading = false;

  // validation errors
  String? _fromError;
  String? _toError;
  String? _valueError;

  final FocusNode _valueFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      setState(() {
        // validate input as user types: show 'Please enter a valid number' for non-numeric input
        final text = textEditingController.text;
        if (text.isEmpty) {
          // clear parse error but keep 'Please enter value' until user tries to convert
          if (_valueError == 'Please enter a valid number') _valueError = null;
        } else {
          final parsed = double.tryParse(text);
          if (parsed == null) {
            _valueError = 'Please enter a valid number';
          } else {
            _valueError = null;
          }
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
    loadCurrencies();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }

  Future<void> loadCurrencies() async {
    currencies = await _apiservices.getCurrenciesList();
    setState(() {
      currencies = currencies;
      fromCurrency = currencies.firstWhere((e) => e.code == 'USD');
      toCurrency = currencies.firstWhere((e) => e.code == 'INR');
    });
  }

  Future<void> convert() async {
    setState(() {
      _fromError = fromCurrency == null ? 'Please select a currency' : null;
      _toError = toCurrency == null ? 'Please select a currency' : null;
      if (textEditingController.text.isEmpty) {
        _valueError = 'Please enter value';
      } else if (double.tryParse(textEditingController.text) == null) {
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

    setState(() => isLoading = true);

    final amount = double.tryParse(textEditingController.text) ?? 0;

    final response = await _apiservices.convertCurrency(
      from: fromCurrency!.code,
      to: toCurrency!.code,
      amount: amount,
    );

    setState(() {
      convertedAmount = response.rates[toCurrency!.code] ?? 0;
      isLoading = false;
      // clear errors on success
      _fromError = null;
      _toError = null;
      _valueError = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _clearInput() {
    setState(() {
      textEditingController.clear();
      convertedAmount = 0;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _showExitConfirmation() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Exit app?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('Are you going to exit?', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderSide: BorderSide(width: 2, style: BorderStyle.solid),
      borderRadius: BorderRadius.all(Radius.circular(5)),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _showExitConfirmation,
        ),
        backgroundColor: Colors.blueGrey,
        title: const Text(
          'Currency Converter',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                convertedAmount == 0 ? '0' : convertedAmount.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 55,
                ),
              ),
              Currencydropdown(
                label: 'From',
                value: fromCurrency,
                items: currencies,
                onChanged: (value) {
                  setState(() {
                    fromCurrency = value;
                    _fromError = null;
                  });
                },
                hint: 'From',
                errorText: _fromError,
              ),
              const SizedBox(height: 5),
              Currencydropdown(
                label: 'To',
                value: toCurrency,
                items: currencies,
                onChanged: (value) {
                  setState(() {
                    toCurrency = value;
                    _toError = null;
                  });
                },
                hint: 'To',
                errorText: _toError,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textEditingController,
                focusNode: _valueFocusNode,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Please enter an amount in USD',
                  hintStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  prefixIconColor: Colors.black,
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: border,
                  enabledBorder: border,
                  errorText: _valueError,
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  suffixIcon: textEditingController.text.isNotEmpty
                      ? IconButton(
                          onPressed: _clearInput,
                          icon: const Icon(Icons.clear, color: Colors.black),
                          tooltip: 'Clear',
                        )
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextButton(
                      onPressed: convert,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Convert'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          convertedAmount = 0;
                          textEditingController.clear();
                          fromCurrency = null;
                          toCurrency = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class CurrencyConverterMaterial extends StatelessWidget {
//   const CurrencyConverterMaterial({super.key});

// }
