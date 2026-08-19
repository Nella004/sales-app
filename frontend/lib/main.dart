import 'package:flutter/material.dart';
import 'api_service.dart';
import 'screens/payout_screen.dart';
import 'screens/vendor_form_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(home: VendorListScreen());
  }


class VendorListScreen extends StatefulWidget {

  @override
  _VendorListScreenState createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  List<dynamic> vendors = [];

  @override
  void initState() {
    super.initState();
    loadVendors();
  }

  void loadVendors() async {
    final data = await ApiService.getVendors();
    setState(() => vendors = data);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Vendors')),
    body: ListView.builder(
      itemCount: vendors.length,
      itemBuilder: (ctx, i) => ListTile(
        title: Text(vendors[i]['name']),
        subtitle: Text('Status: ${vendors[i]['verification_status']}'),
        onTap: () async {
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => PayoutScreen(vendor: vendors[i]))
          );
          loadVendors(); //to refresh the status after returning
        },
      )
    ),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
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