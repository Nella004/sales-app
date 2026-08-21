import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_snackbar.dart';
import '../api_service.dart';

class PayoutScreen extends StatefulWidget {
  final Map<String, dynamic> vendor;
  PayoutScreen({required this.vendor});

  @override
  _PayoutScreenState createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  Map<String, dynamic>? balance;
  double? bankBalance;
  List<dynamic> transactions = [];
  String status = '';
  bool verifying = false;
  bool loadingHistory = true;

  @override
  void initState() {
    super.initState();
    status = widget.vendor['verification_status'] ?? 'unverified';
    loadAll();
  }

  void loadAll() async {
    setState(() => loadingHistory = true);
    try {
      final b = await ApiService.getBalance(widget.vendor['id']);
      final bb = await ApiService.getVendorBankBalance(widget.vendor['id']);
      final tx = await ApiService.getTransactions(widget.vendor['id']);
      setState(() {
        balance = b;
        bankBalance = (bb['balance'] as num).toDouble();
        transactions = tx;
        loadingHistory = false;
      });
    } catch (e) {
        setState(() => loadingHistory = false);
    }
  }

  void verify() async {
    setState(() => verifying = true);
    try {
      final updated = await ApiService.verifyVendor(widget.vendor['id'], 'verified');
      setState(() => status = updated['verification_status']);
      AppSnackbar.success(context, 'Vendor Approved');
    } catch (e) {
      AppSnackbar.error(context, 'Approval failed: $e');
    } finally {
      setState(() => verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.vendor['name'] ?? 'Vendor')),
    body: RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      onRefresh: () async => loadAll(),
      child: ListView(
        padding: const EdgeInsets.all(20),
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
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [AppTheme.softShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account Balance', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  bankBalance != null ? '\$${bankBalance!.toStringAsFixed(2)}' : '-',
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if(balance != null)
            Row(
              children: [
                Expanded(child: _MiniStat(label: 'Held', value: balance!['held'])),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat(label: 'Released', value: balance!['released'])),
              ],
            ),
          
          const SizedBox(height: 28),

          Text('Transaction History', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),
          if (loadingHistory)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.accent)))
          else if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surfaceAlt, borderRadius: BorderRadius.circular(14)),
              child: Text('No transactions yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            )
          else
            ...transactions.map((t) => _TransactionTile(tx: t)),
        ],
      ),
    ),
  );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final dynamic value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text('\$$value', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _TransactionTile extends StatelessWidget{
  final Map<String, dynamic> tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isReceived = tx['type'] == 'received';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isReceived ? AppTheme.success : AppTheme.accent).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isReceived ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, 
              size: 16, 
              color: isReceived ? AppTheme.success : AppTheme.accent,
            ),
          ),
          const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isReceived ? 'Received' : 'Released', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  if (tx['reference_id'] != null)
                    Text(tx['reference_id'].toString(), style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Text('\$${tx['amount']}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );         
  }
}
