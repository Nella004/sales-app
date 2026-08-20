import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_snackbar.dart';
import '../api_service.dart';

class VendorFormScreen extends StatefulWidget{
  @override
  _VendorFormScreenState createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends State<VendorFormScreen> {
  final nameCtrl = TextEditingController();
  final infoCtrl = TextEditingController();
  final idCtrl = TextEditingController();
  bool submitting = false;

  void submit() async {
    if (nameCtrl.text.isEmpty) {
      AppSnackbar.error(context, 'Vendor name is required');
      return;
    }
    setState(() => submitting = true);

    try {
      await ApiService.submitVendor(nameCtrl.text, infoCtrl.text, idCtrl.text);
      if (mounted) Navigator.pop(context, true); //so true = refresh list on return
    } catch (e) {
      AppSnackbar.error(context, 'Failed to submit: $e');
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Submit Vendor')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Vendor name', prefixIcon: Icon(Icons.storefront_outlined)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: infoCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(labelText: 'Business Info', prefixIcon: Icon(Icons.info_outline_rounded)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: idCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(labelText: 'ID number', prefixIcon: Icon(Icons.badge_outlined)),
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
              : const Text('Submit'),
          ),  
        ],
      ),
    ),
  );
}