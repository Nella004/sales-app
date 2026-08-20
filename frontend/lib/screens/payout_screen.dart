import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_snackbar.dart';
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
  bool releasing = false;
  bool verifying = false;

  @override
  void initState() {
    super.initState();
    status = widget.vendor['verification_status'] ?? 'unverified';
    loadBalance();
  }

  void loadBalance() async {
    try {
      final data = await ApiService.getBalance(widget.vendor['id']);
      setState(() => balance = data);
    } catch (e) {
      //balance will be null, UI will show "unavailable"
    }
  }

  void verify() async {
    setState(() => verifying = true);
    try {
      final updated = await ApiService.verifyVendor(widget.vendor['id'], 'verified');
      setState(() => status = updated['verification_status']);
    } catch (e) {
      AppSnackbar.error(context, 'Approval failed: $e');
    } finally {
      setState(() => verifying = false);
    }
  }

  void release() async {
    final amount = double.tryParse(amountCtrl.text);
    if (amount == null) {
      AppSnackbar.error(context, 'Enter a valid amount');
      return;
    }
    setState(() => releasing = true);
    try {
      final result = await ApiService.releasefunds(widget.vendor['id'], amount);
      loadBalance();
      amountCtrl.clear();
      AppSnackbar.success(
        context, 
        'Released \$${result['net_amount']} (fee: \$${result['fee']})',
      );
    }catch (e) {
      AppSnackbar.error(context, 'Release failed: $e');
    } finally {
      setState(() => releasing = false);
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
    appBar: AppBar(title: Text(widget.vendor['name'] ?? 'Vendor')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(StatusStyle.icon(status), size: 16, color: StatusStyle.color(status)),
              const SizedBox(width: 6),
              Text(
                status[0].toUpperCase() + status.substring(1),
                style: TextStyle(
                  color: StatusStyle.color(status),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (status != 'verified')
                TextButton.icon(
                  onPressed: verifying ? null :verify, 
                  icon: verifying
                    ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                    )
                    : const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('Approve'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          //Balance card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [AppTheme.softShadow],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _BalanceStat(
                    label: 'Held',
                    value: balance != null ? '\$${balance!['held']}' : 'â€',
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.25)),
                Expanded(
                  child: _BalanceStat(
                    label: 'Released',
                    value: balance != null ? '\$${balance!['released']}' : 'â€',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: goToReceiveFunds, 
            icon: const Icon(Icons.arrow_downward_rounded, size: 18),
            label: const Text('Simulate Payment Received'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              side: BorderSide(color: Colors.white.withOpacity(0.15)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(14)),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'Release Payout',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'Amount to release',
              prefixText: '\$',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: releasing ? null : release, 
            child: releasing
              ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                    : const Text('Release Payout'),
          ),
        ],
      ),
    ),
  );
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;
  const _BalanceStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
    ],
  );
}