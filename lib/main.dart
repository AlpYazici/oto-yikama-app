import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/campaign_management_screen.dart';
import 'screens/revenue_analysis_screen.dart';
import 'models/campaign_model.dart';
import 'utils/data_manager.dart';

void main() {
 runApp(const MyApp());
}

class MyApp extends StatelessWidget {
 const MyApp({super.key});

 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Auto Club Erenköy',
     theme: ThemeData(
       primarySwatch: Colors.deepOrange,
       primaryColor: Colors.deepOrange[600],
       colorScheme: ColorScheme.fromSeed(
         seedColor: Colors.deepOrange,
         primary: Colors.deepOrange[600]!,
         secondary: Colors.orange[400]!,
       ),
       appBarTheme: AppBarTheme(
         backgroundColor: Colors.black87,
         foregroundColor: Colors.orange[400],
       ),
     ),
     home: const CarWashApp(),
   );
 }
}

class CarWashApp extends StatefulWidget {
 const CarWashApp({super.key});

 @override
 _CarWashAppState createState() => _CarWashAppState();
}

class _CarWashAppState extends State<CarWashApp> {
 static const platform = MethodChannel('com.example.car_wash_app/sms');
 final _phoneController = TextEditingController();
 final _plateController = TextEditingController();
 String _selectedService = '';
 List<Map<String, String>> _customers = [];
 List<Campaign> _activeCampaigns = [];

 @override
 void initState() {
   super.initState();
   _requestSmsPermission();
   _loadCustomersFromStorage();
   _loadActiveCampaigns();
 }

 _requestSmsPermission() async => await Permission.sms.request();

 _saveCustomersToStorage() async {
   try {
     final prefs = await SharedPreferences.getInstance();
     await prefs.setStringList('customers', _customers.map((c) => json.encode(c)).toList());
   } catch (e) {}
 }

 _loadCustomersFromStorage() async {
   try {
     final prefs = await SharedPreferences.getInstance();
     final customersJson = prefs.getStringList('customers');
     if (customersJson != null) {
       _customers = customersJson.map((c) => Map<String, String>.from(json.decode(c))).toList();
       if (mounted) setState(() {});
     }
   } catch (e) {}
 }

 _loadActiveCampaigns() async {
   try {
     _activeCampaigns = await DataManager.getActiveCampaigns();
     if (mounted) setState(() {});
   } catch (e) {
     _activeCampaigns = [];
   }
 }

 _sendSMS(String phone, String message) async {
   try {
     await platform.invokeMethod('sendSMS', {'phoneNumber': phone, 'message': message});
   } catch (e) {
     // SMS hatası sessizce geçilir
   }
 }

 _saveCustomer() async {
   if (_phoneController.text.isEmpty || _plateController.text.isEmpty || _selectedService.isEmpty) {
     _showSnackBar('Lütfen tüm alanları doldurun!');
     return;
   }

   await _loadActiveCampaigns();
   final originalPrice = _getServicePrice(_selectedService);
   var finalPrice = originalPrice;
   var campaignMessage = '';
   
   if (_activeCampaigns.isNotEmpty) {
     final campaign = _activeCampaigns.first;
     if (_canApplyCampaign(campaign, _selectedService)) {
       finalPrice = campaign.calculateDiscountedPrice(originalPrice);
       campaignMessage = '\n🎉 ${campaign.name}\n💰 ${finalPrice.toInt()}₺ (${originalPrice.toInt()}₺)';
     }
   }

   final customer = {
     'phone': _phoneController.text,
     'plate': _plateController.text.toUpperCase(),
     'service': _selectedService,
     'originalPrice': originalPrice.toString(),
     'finalPrice': finalPrice.toString(),
     'time': DateTime.now().toString().substring(11, 16),
     'date': DateTime.now().toString().substring(0, 10),
     'status': 'waiting',
     'campaign': campaignMessage,
   };

   _customers.add(customer);
   _saveCustomersToStorage();
   _sendSMS(customer['phone']!, 'Merhaba! ${customer['plate']} sıraya alındı.$campaignMessage\n🏢 Auto Club Erenköy');
   
   _phoneController.clear();
   _plateController.clear();
   _selectedService = '';
   
   _showSnackBar(campaignMessage.isNotEmpty ? 'Kaydedildi! 🎉 Kampanya uygulandı!' : 'Müşteri kaydedildi!');
   setState(() {});
 }

 double _getServicePrice(String service) {
   final match = RegExp(r'(\d+)₺').firstMatch(service);
   return match != null ? double.parse(match.group(1)!) : 0.0;
 }

 bool _canApplyCampaign(Campaign campaign, String service) {
   final now = DateTime.now();
   switch (campaign.type) {
     case CampaignType.allServices: case CampaignType.newCustomer: case CampaignType.loyaltyProgram:
       return true;
     case CampaignType.specificService:
       return campaign.name.contains('Detay') && service.contains('Detay');
     case CampaignType.happyHour:
       return now.hour >= 8 && now.hour < 10;
     case CampaignType.weekend:
       return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
   }
 }

 void _showSnackBar(String message, [Color? color]) {
   if (mounted) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(message),
         backgroundColor: color ?? Colors.deepOrange[600],
         behavior: SnackBarBehavior.floating,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
       ),
     );
   }
 }

 @override
 Widget build(BuildContext context) {
   return DefaultTabController(
     length: 4,
     child: Scaffold(
       appBar: AppBar(
         title: Text('🏢 Auto Club Erenköy'),
         backgroundColor: Colors.black87,
         foregroundColor: Colors.orange[400],
         elevation: 6,
         bottom: TabBar(
           isScrollable: false,
           indicatorColor: Colors.orange[400],
           labelColor: Colors.orange[400],
           unselectedLabelColor: Colors.orange[200],
           tabs: [
             Tab(icon: Icon(Icons.add_circle, size: 20), text: 'Yeni'),
             Tab(icon: Icon(Icons.queue, size: 20), text: 'Sıra'),
             Tab(icon: Icon(Icons.bar_chart, size: 20), text: 'Gelir'),
             Tab(icon: Icon(Icons.campaign, size: 20), text: 'Kampanya'),
           ],
         ),
       ),
       body: TabBarView(
         children: [
           _buildNewCustomerTab(),
           _buildQueueTab(),
           const RevenueAnalysisScreen(),
           const CampaignManagementScreen(),
         ],
       ),
       // Gün sonu kaydet butonu
       floatingActionButton: FloatingActionButton.extended(
         onPressed: () async {
           await DataManager.saveDailyRevenue();
           _showSnackBar('Günlük veriler kaydedildi!', Colors.green);
         },
         label: Text('Gün Sonu'),
         icon: Icon(Icons.save),
         backgroundColor: Colors.deepOrange[600],
       ),
     ),
   );
 }

 Widget _buildNewCustomerTab() {
   return Container(
     decoration: BoxDecoration(
       gradient: LinearGradient(
         colors: [Colors.blue[50]!, Colors.white],
         begin: Alignment.topCenter,
         end: Alignment.bottomCenter,
       ),
     ),
     child: Padding(
       padding: EdgeInsets.all(16),
       child: Column(
         children: [
           // Aktif kampanya uyarısı
           if (_activeCampaigns.isNotEmpty)
             Container(
               margin: EdgeInsets.only(bottom: 16),
               child: Card(
                 color: Colors.orange[50],
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 child: Padding(
                   padding: EdgeInsets.all(16),
                   child: Row(
                     children: [
                       Icon(Icons.campaign, color: Colors.deepOrange[600], size: 32),
                       SizedBox(width: 12),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('AKTİF KAMPANYA!', 
                               style: TextStyle(
                                 color: Colors.deepOrange[800], 
                                 fontWeight: FontWeight.bold,
                                 fontSize: 16
                               )),
                             Text(_activeCampaigns.first.name,
                               style: TextStyle(color: Colors.deepOrange[700], fontSize: 14)),
                             Text('%${_activeCampaigns.first.discountPercentage.toInt()} İNDİRİM',
                               style: TextStyle(
                                 color: Colors.deepOrange[800], 
                                 fontWeight: FontWeight.bold,
                                 fontSize: 14
                               )),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
             ),

           Card(
             elevation: 6,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
             child: Padding(
               padding: EdgeInsets.all(20),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Icon(Icons.person_add, color: Colors.deepOrange[700], size: 28),
                       SizedBox(width: 12),
                       Text('Yeni Müşteri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                     ],
                   ),
                   SizedBox(height: 20),
                   TextField(
                     controller: _phoneController,
                     decoration: InputDecoration(
                       labelText: 'Telefon Numarası',
                       hintText: '0532 123 45 67',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                       filled: true,
                       fillColor: Colors.grey[50],
                       prefixIcon: Icon(Icons.phone, color: Colors.deepOrange[600]),
                     ),
                     keyboardType: TextInputType.phone,
                   ),
                   SizedBox(height: 16),
                   TextField(
                     controller: _plateController,
                     decoration: InputDecoration(
                       labelText: 'Araç Plakası',
                       hintText: '34 ABC 123',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                       filled: true,
                       fillColor: Colors.grey[50],
                       prefixIcon: Icon(Icons.directions_car, color: Colors.deepOrange[600]),
                     ),
                     textCapitalization: TextCapitalization.characters,
                   ),
                   SizedBox(height: 16),
                   DropdownButtonFormField<String>(
                     initialValue: _selectedService.isEmpty ? null : _selectedService,
                     decoration: InputDecoration(
                       labelText: 'Yıkama Paketi',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                       filled: true,
                       fillColor: Colors.grey[50],
                       prefixIcon: Icon(Icons.local_car_wash, color: Colors.deepOrange[600]),
                     ),
                     items: [
                       'Ekonomik Paket (60₺)',
                       'Standart Paket (85₺)', 
                       'AutoClub Premium (130₺)',
                       'VIP Detay Bakım (180₺)',
                       'Kış Özel Bakım (110₺)',
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
                   SizedBox(height: 24),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: _saveCustomer,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.deepOrange[600],
                         foregroundColor: Colors.white,
                         padding: EdgeInsets.all(16),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(12),
                         ),
                         elevation: 4,
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.save, size: 24),
                           SizedBox(width: 8),
                           Text('Kaydet & SMS Gönder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           ),
         ],
       ),
     ),
   );
 }

 Widget _buildQueueTab() {
   final todayCustomers = _customers.where((c) => 
     c['date'] == DateTime.now().toString().substring(0, 10)).toList();

   return Container(
     decoration: BoxDecoration(gradient: LinearGradient(
       colors: [Colors.orange[50]!, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
     padding: EdgeInsets.all(16),
     child: Column(children: [
       _buildQueueHeader(todayCustomers.length),
       SizedBox(height: 16),
       Expanded(child: todayCustomers.isEmpty ? _buildEmptyQueue() : _buildCustomerList(todayCustomers)),
     ]),
   );
 }

 Widget _buildQueueHeader(int count) => Card(
   elevation: 6, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
   child: Container(
     padding: EdgeInsets.all(20),
     decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
       gradient: LinearGradient(colors: [Colors.black87, Colors.grey[900]!])),
     child: Row(children: [
       Icon(Icons.queue, color: Colors.orange[400], size: 32), SizedBox(width: 16),
       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         Text('BUGÜNKÜ MÜŞTERİLER', style: TextStyle(color: Colors.orange[400], fontSize: 18, fontWeight: FontWeight.bold)),
         Text('$count araç sırada', style: TextStyle(color: Colors.orange[300], fontSize: 14)),
       ])),
       Container(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
         child: Text('$count', style: TextStyle(color: Colors.deepOrange[600], fontSize: 24, fontWeight: FontWeight.bold))),
     ]),
   ),
 );

 Widget _buildEmptyQueue() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
   Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]), SizedBox(height: 16),
   Text('Henüz bugün müşteri yok', style: TextStyle(fontSize: 18, color: Colors.grey[600])), SizedBox(height: 8),
   Text('Yeni müşteri eklemek için "Yeni" sekmesini kullanın', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
 ]));

 Widget _buildCustomerList(List<Map<String, String>> customers) => ListView.builder(
   itemCount: customers.length,
   itemBuilder: (context, index) => _buildCustomerCard(customers[index], index),
 );

 Widget _buildCustomerCard(Map<String, String> customer, int index) {
   final hasDiscount = customer['campaign']?.isNotEmpty ?? false;
   return Card(elevation: 4, margin: EdgeInsets.only(bottom: 12),
     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
     child: Container(
       decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
         gradient: LinearGradient(colors: hasDiscount ? [Colors.orange[50]!, Colors.orange[100]!] : [Colors.white, Colors.grey[50]!])),
       child: ListTile(contentPadding: EdgeInsets.all(16),
         leading: CircleAvatar(backgroundColor: hasDiscount ? Colors.deepOrange[600] : Colors.black87, radius: 25,
           child: Text('${index + 1}', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
         title: Text(customer['plate']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,
           color: hasDiscount ? Colors.deepOrange[800] : Colors.black87)),
         subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
           SizedBox(height: 8),
           _buildInfoRow(Icons.phone, customer['phone']!),
           _buildInfoRow(Icons.local_car_wash, customer['service']!),
           _buildInfoRow(Icons.access_time, customer['time']!),
           if (hasDiscount) Container(margin: EdgeInsets.only(top: 8), padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(color: Colors.deepOrange[600], borderRadius: BorderRadius.circular(8)),
             child: Text('🎉 KAMPANYA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
         ]),
         trailing: ElevatedButton(onPressed: () => _completeCustomer(customer),
           style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange[600], foregroundColor: Colors.white,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
           child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check, size: 18), SizedBox(width: 4), Text('Hazır')])),
       ),
     ),
   );
 }

 Widget _buildInfoRow(IconData icon, String text) => Padding(padding: EdgeInsets.symmetric(vertical: 2),
   child: Row(children: [Icon(icon, size: 16, color: Colors.grey[600]), SizedBox(width: 4), Expanded(child: Text(text, style: TextStyle(fontSize: 14)))]));

 void _completeCustomer(Map<String, String> customer) {
   _sendSMS(customer['phone']!, 'Merhaba! ${customer['plate']} hazır. Teşekkürler!\\n🏢 Auto Club Erenköy');
   _customers.remove(customer);
   _saveCustomersToStorage();
   _showSnackBar('${customer['plate']} teslim edildi!', Colors.deepOrange[600]);
   setState(() {});
 }
}