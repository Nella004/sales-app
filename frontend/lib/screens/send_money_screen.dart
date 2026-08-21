import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_snackbar.dart';
import '../api_service.dart';

class SendMoneyScreen extends StatefulWidget{
  @override
  _SendMoneyScreenState createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  List<dynamic> verifiedVendors = [];
  Map<String, dynamic>? selectedVendor;
  final amountCtrl = TextEditingController();
  bool loading = true;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    loadVendors();
  }

  void loadVendors() async{
    setState(() => loading = true);
    try {
      final all = await ApiService.getVendors();
      setState(() {
        verifiedVendors = all.where((v) => v['verification_status'] == 'verified').toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void send() async {
    if (selectedVendor == null) {
      AppSnackbar.error(context, 'Choose a vendor to send to');
      return;
    }
    final amount = double.tryParse(amountCtrl.text);
    if (amount == null || amount <= 0) {
      AppSnackbar.error(context, 'Enter a valid amount');
      return;
    }
    setState(() => sending = true);
    try {
      final result = await ApiService.sendMoney(selectedVendor!['id'], amount);
      AppSnackbar.success(
        context,
        'Sent \$${result['net_amount']} to ${selectedVendor!['name']} (fee: \$${result['fee']})',
      );
      amountCtrl.clear();
      setState(() => selectedVendor = null);
    } catch (e) {
      AppSnackbar.error(context, 'Send failed : $e');
    } finally {
      setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Send Money')),
    body: loading
      ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
      :Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Send to',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          if (verifiedVendors.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'No verified vendors yet. Approve a vendor first.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          )
          else
          Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true, 
                value: selectedVendor,
                dropdownColor: AppTheme.surfaceAlt,
                hint: Text('Choose a vendor', style: TextStyle(color: AppTheme.textSecondary)),
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                items: verifiedVendors
                  .map<DropdownMenuItem<Map<String, dynamic>>>(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(v['name'] ?? 'Unnamed'),
                    ),
                  )
                  .toList(),
                onChanged: (v) => setState(() => selectedVendor = v),
              ),
            ),
          ),

          const SizedBox(height: 28),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style:  const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
          ),

          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: sending ? null :send, 
            child: sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Send'), 
          ),
        ],
      ),
    ),
  );

}