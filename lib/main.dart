import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
 runApp(MyApp());
}

class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Oto Yıkama',
     theme: ThemeData(primarySwatch: Colors.blue),
     home: CarWashApp(),
   );
 }
}

class CarWashApp extends StatefulWidget {
 @override
 _CarWashAppState createState() => _CarWashAppState();
}

class _CarWashAppState extends State<CarWashApp> {
 static const platform = MethodChannel('com.example.car_wash_app/sms');
 final _phoneController = TextEditingController();
 final _plateController = TextEditingController();
 String _selectedService = '';
 List<Map<String, String>> _customers = [];

 @override
 void initState() {
   super.initState();
   _requestSmsPermission();
   _loadCustomersFromStorage();
 }

 _requestSmsPermission() async {
   await Permission.sms.request();
 }

 _saveCustomersToStorage() async {
   final prefs = await SharedPreferences.getInstance();
   List<String> customersJson = _customers.map((customer) => json.encode(customer)).toList();
   await prefs.setStringList('customers', customersJson);
 }

 _loadCustomersFromStorage() async {
   final prefs = await SharedPreferences.getInstance();
   List<String>? customersJson = prefs.getStringList('customers');
   if (customersJson != null) {
     setState(() {
       _customers = customersJson.map((customerStr) => Map<String, String>.from(json.decode(customerStr))).toList();
     });
   }
 }

 _sendSMS(String phone, String message) async {
   try {
     await platform.invokeMethod('sendSMS', {
       'phoneNumber': phone,
       'message': message,
     });
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('SMS başarıyla gönderildi!')),
     );
   } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('SMS gönderilemedi!')),
     );
   }
 }

 _saveCustomer() {
   if (_phoneController.text.isEmpty || 
       _plateController.text.isEmpty || 
       _selectedService.isEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
     );
     return;
   }

   final customer = {
     'phone': _phoneController.text,
     'plate': _plateController.text.toUpperCase(),
     'service': _selectedService,
     'time': DateTime.now().toString().substring(11, 16),
   };

   setState(() {
     _customers.add(customer);
   });
   _saveCustomersToStorage();

   final message = 'Merhaba! ${customer['plate']} plakalı aracınız yıkamaya alındı. Size tamamlandığında haber vereceğiz.';
   _sendSMS(customer['phone']!, message);

   _phoneController.clear();
   _plateController.clear();
   setState(() {
     _selectedService = '';
   });
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: Text('🚗 Oto Yıkama Sistemi')),
     body: Padding(
       padding: EdgeInsets.all(16),
       child: Column(
         children: [
           Card(
             child: Padding(
               padding: EdgeInsets.all(16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Yeni Müşteri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   SizedBox(height: 16),
                   TextField(
                     controller: _phoneController,
                     decoration: InputDecoration(
                       labelText: 'Telefon Numarası',
                       hintText: '0532 123 45 67',
                       border: OutlineInputBorder(),
                     ),
                     keyboardType: TextInputType.phone,
                   ),
                   SizedBox(height: 16),
                   TextField(
                     controller: _plateController,
                     decoration: InputDecoration(
                       labelText: 'Araç Plakası',
                       hintText: '34 ABC 123',
                       border: OutlineInputBorder(),
                     ),
                     textCapitalization: TextCapitalization.characters,
                   ),
                   SizedBox(height: 16),
                   DropdownButtonFormField<String>(
                     value: _selectedService.isEmpty ? null : _selectedService,
                     decoration: InputDecoration(
                       labelText: 'Yıkama Paketi',
                       border: OutlineInputBorder(),
                     ),
                     items: [
                       'Dış Yıkama (50₺)',
                       'İç-Dış Yıkama (80₺)',
                       'Detay Yıkama (120₺)',
                       'Premium Yıkama (150₺)',
                     ].map((String value) {
                       return DropdownMenuItem<String>(
                         value: value,
                         child: Text(value),
                       );
                     }).toList(),
                     onChanged: (String? newValue) {
                       setState(() {
                         _selectedService = newValue ?? '';
                       });
                     },
                   ),
                   SizedBox(height: 20),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: _saveCustomer,
                       child: Text('💾 Kaydet & SMS Gönder'),
                       style: ElevatedButton.styleFrom(
                         padding: EdgeInsets.all(16),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           ),
           SizedBox(height: 20),
           Expanded(
             child: Card(
               child: Padding(
                 padding: EdgeInsets.all(16),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('Bugünkü Müşteriler (${_customers.length})', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     SizedBox(height: 16),
                     Expanded(
                       child: ListView.builder(
                         itemCount: _customers.length,
                         itemBuilder: (context, index) {
                           final customer = _customers[index];
                           return Card(
                             color: Colors.grey[100],
                             child: ListTile(
                               title: Text(customer['plate']!, 
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                               subtitle: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text('📱 ${customer['phone']}'),
                                   Text('🚗 ${customer['service']}'),
                                   Text('🕐 ${customer['time']}'),
                                 ],
                               ),
                               trailing: ElevatedButton(
                                 onPressed: () {
                                   final message = 'Merhaba! ${customer['plate']} plakalı aracınız hazır. Teşekkürler!';
                                   _sendSMS(customer['phone']!, message);
                                 },
                                 child: Text('Hazır'),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.green,
                                   foregroundColor: Colors.white,
                                 ),
                               ),
                             ),
                           );
                         },
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
         ],
       ),
     ),
   );
 }
}