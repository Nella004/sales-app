import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'theme.dart';
import 'api_service.dart';
import 'splash_screen.dart';
import 'screens/payout_screen.dart';
import 'screens/vendor_form_screen.dart';
import 'screens//send_money_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Vendor Payouts',
    theme: AppTheme.dark,
    home: SplashScreen(),
    );
}


class VendorListScreen extends StatefulWidget {
  @override
  _VendorListScreenState createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  List<dynamic> vendors = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVendors();
  }

  void loadVendors() async {
    setState(() => loading = true);
    try{
      final data = await ApiService.getVendors();
      setState(() {
        vendors = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Vendors'),
      actions: [
        IconButton(
          icon: const Icon(Icons.send_rounded),
          tooltip: 'Send Money',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SendMoneyScreen())
          )
        )
      ],
    ),
    body: RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      onRefresh: () async => loadVendors(),
      child: loading
        ? const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          )
        : vendors.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: vendors.length,
              itemBuilder: (ctx, i) {
                final vendor = vendors[i];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 300 + (i * 60)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 16),
                      child: child,
                    ),
                  ),

                  child: _VendorCard(
                    vendor: vendor,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PayoutScreen(vendor: vendor),
                        ),
                      );
                      loadVendors();
                    },
                  ),
                );
              },
            ),

    ),

    floatingActionButton: FloatingActionButton.extended(
      icon: const Icon(Icons.add_rounded),
      label: const Text('New Vendor'),
      onPressed: () async {
        final refresh = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VendorFormScreen()),
        );
        if (refresh == true) loadVendors();
      },
    ),
  );
}

class _VendorCard extends StatefulWidget {
  final Map<String, dynamic> vendor;
  final VoidCallback onTap;
  const _VendorCard({ required this.vendor, required this.onTap});

  @override
  State<_VendorCard> createState() => _VendorCardState();
}

class _VendorCardState extends State<_VendorCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final status = widget.vendor['verification_status'] ?? 'unverified';
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale, 
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [AppTheme.softShadow],
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  (widget.vendor['name'] ?? '?').toString().substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vendor['name'] ?? 'Unnamed',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(StatusStyle.icon(status), size: 14, color: StatusStyle.color(status)),
                        const SizedBox(width: 4),
                        Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: StatusStyle.color(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.storefront_rounded, size: 56, color: AppTheme.textSecondary.withOpacity(0.4)),
                const SizedBox(height: 16),
                const Text(
                  'No vendors yet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap "New Vendor" to add your first one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ),
      ),
    )
  );
}
