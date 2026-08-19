import 'package:flutter/material.dart';
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
    if (nameCtrl.text.isEmpty) return;
    setState(() => submitting = true);

    try {
      await ApiService.submitVendor(nameCtrl.text, infoCtrl.text, idCtrl.text);
      if (mounted) Navigator.pop(context, true); //so true = refresh list on return
    } catch (e) {
      ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Submit Vendor')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(labelText: 'Vendor name'),
          ),
          TextField(
            controller: infoCtrl,
            decoration: InputDecoration(labelText: 'Business Info'),
          ),
          TextField(
            controller: idCtrl,
            decoration: InputDecoration(labelText: 'ID number'),
          ),
          SizedBox(height: 20),
          submitting
            ? CircularProgressIndicator()
            : ElevatedButton(onPressed: submit, child: Text('Submit')),
        ],
      ),
    ),
  );
}