import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_snackbar.dart';
import '../api_service.dart';

class ReceiveFundsScreen extends StatefulWidget {
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
    if (amount == null) {
      // ✅ Matches your exact app_snackbar.dart layout setup
      AppSnackbar.error(context, 'Enter a valid amount');
      return;
    }

    setState(() => submitting = true);
    try {
      await ApiService.receivefunds(widget.vendor['id'], amount, referenceCtrl.text);
      if (mounted) Navigator.pop(context, true); // true = refresh balance on return
    } catch (e) {
        // ✅ Matches your exact app_snackbar.dart layout setup
        AppSnackbar.error(context, 'Failed to receive funds: $e');
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Simulate Payment Received')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.webhook_rounded, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Stand in for the payment processor webhook – in production this fires automatically.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          TextField(
            controller: amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Amount Received',
              prefixText: '\$',
            ),
          ),

          const SizedBox(height: 14),
          TextField(
            controller: referenceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Reference ID (mock transaction id)',
              prefixIcon: Icon(Icons.tag_rounded),
            ),
          ),

          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: submitting ? null : submit, 
            child: submitting
              ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
              : const Text('Simulate Payment Received'),
          ),
        ],
      ),
    ),
  );
}
