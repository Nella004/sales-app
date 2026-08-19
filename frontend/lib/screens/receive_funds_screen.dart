import 'package:flutter/material.dart';
import '../api_service.dart';

class ReceiveFundsScreen extends StatefulWidget{
  final Map<String, dynamic> vendor;
  ReceiveFundsScreen({required this.vendor});

  @override
  _ReceiveFundsScreenState createState() => _ReceiveFundsScreenState();
}

class _ReceiveFundsScreenState extends State<ReceiveFundsScreen> {
  final amountCtrl = TextEditingController();
  final referenceCtrl = TextEditingController();
  bool submitting = false;

  void submit() async {
    final amount = double.tryParse(amountCtrl.text);
    if (amount == null) return;
    setState(() => submitting = true);

    try {
      await ApiService.receivefunds(widget.vendor['id'], amount, referenceCtrl.text);
      if (mounted) Navigator.pop(context, true); //meaning true = refresh balance on return
    } catch (e) {
      ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('Failed to receive funds: $e')));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
     appBar: AppBar(title: Text('Simulate Payment Received')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Stand=in for a payment processor webhook - in production, this call would be triggered automatically, not tapped by a person.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(height: 16),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Amount received '),
          ),
          TextField(
            controller: referenceCtrl,
            decoration: InputDecoration(labelText: 'Reference ID (mock transaction id)'),
          ),
          SizedBox(height: 20),
          submitting
            ? CircularProgressIndicator()
            : ElevatedButton(onPressed: submit, child: Text('Simulate Payment Received'))
        ],
      ),
    ),
  );
}