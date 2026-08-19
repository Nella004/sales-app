import 'package:flutter/material.dart';
import '../api_service.dart';
import 'receive_funds_screen.dart';

class PayoutScreen extends StatefulWidget {
  final Map<String, dynamic> vendor;
  PayoutScreen({required this.vendor});

  @override
  _PayoutScreenState createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  Map<String, dynamic>? balance;
  final amountCtrl = TextEditingController();
  String status = '';

  @override
  void initState() {
    super.initState();
    status = widget.vendor['verification_status'] ?? 'unverified';
    loadBalance();
  }

  void loadBalance() async {
    final data = await ApiService.getBalance(widget.vendor['id']);
    setState(() => balance = data);
  }

  void verify() async {
    final updated = await ApiService.verifyVendor(widget.vendor['id'], 'verified');
    setState(() => status = updated['verification_status']);
  }

  void release() async {
    final amount = double.tryParse(amountCtrl.text);
    if (amount == null) return;
    
    try {
      final result = await ApiService.releasefunds(widget.vendor['id'], amount);
      loadBalance();
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Released \$${result['net_amount']} (fee: \$${result['fee']})'),
        ));
    }catch (e) {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Released failed: $e')));
    }
  }

  void goToReceiveFunds() async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReceiveFundsScreen(vendor: widget.vendor)),
    );
    if (refresh == true) loadBalance();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.vendor['name'])),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status: $status'),
          SizedBox(height: 8),
          if (balance != null)
            Text('Held: \$${balance!['held']}       Released: \$${balance!['released']}'),
            SizedBox(height: 20),
          if (status != 'verified')
            ElevatedButton(onPressed: verify, child: Text('Approve Vendor')),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: goToReceiveFunds, 
            child: Text('Simulate Payment Received')
          ),
          SizedBox(height: 20),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Amount to Release'),
          ),
          SizedBox(height: 12),
          ElevatedButton(onPressed: release, child: Text('Release Payout')),
        ],
      ),
    )
  );
}