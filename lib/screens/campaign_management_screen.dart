import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import '../models/campaign_model.dart';

class CampaignManagementScreen extends StatefulWidget {
  const CampaignManagementScreen({super.key});

  @override
  _CampaignManagementScreenState createState() => _CampaignManagementScreenState();
}

class _CampaignManagementScreenState extends State<CampaignManagementScreen> {
  static const platform = MethodChannel('com.example.autoclub_erenkoy/sms');
  List<Campaign> _campaigns = [];
  
  // AutoClub Erenköy özel kampanya şablonları
  final List<Map<String, dynamic>> _campaignTemplates = [
    {
      'name': 'AutoClub Hoşgeldin',
      'description': 'Yeni üyelere özel %30 indirim',
      'discount': 30,
      'type': CampaignType.newCustomer,
      'icon': Icons.person_add,
      'color': Colors.deepOrange,
    },
    {
      'name': 'Hafta Sonu Avantajı',
      'description': 'Cmt-Paz AutoClub üyelerine %20 indirim',
      'discount': 20,
      'type': CampaignType.weekend,
      'icon': Icons.weekend,
      'color': Colors.black87,
    },
    {
      'name': 'Erken Kuş',
      'description': '08:00-10:00 sabah kampanyası %25 indirim',
      'discount': 25,
      'type': CampaignType.happyHour,
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
    },
    {
      'name': 'Erenköy Sadakat',
      'description': '5 yıkamada 1 bedava - sadık müşteriler',
      'discount': 20,
      'type': CampaignType.loyaltyProgram,
      'icon': Icons.favorite,
      'color': Colors.red[800],
    },
    {
      'name': 'VIP Detay İndirimi',
      'description': 'VIP Detay Bakım hizmetinde %35 indirim',
      'discount': 35,
      'type': CampaignType.specificService,
      'icon': Icons.diamond,
      'color': Colors.amber[800],
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }
  
  Future<void> _loadCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    final campaignsList = prefs.getStringList('campaigns') ?? [];
    _campaigns = campaignsList.map((c) => Campaign.fromJson(json.decode(c))).toList();
    if (mounted) setState(() {});
  }
  
  Future<void> _saveCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('campaigns', _campaigns.map((c) => json.encode(c.toJson())).toList());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.orange[400],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'AC',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Text('Kampanya Yönetimi'),
          ],
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.orange[400],
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendCampaignSMS,
            tooltip: 'Kampanya SMS\'i Gönder',
          ),
        ],
      ),
      body: Column(
        children: [
          // Aktif kampanyalar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                        gradient: LinearGradient(
            colors: [Colors.orange[50]!, Colors.orange[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign, color: Colors.deepOrange[600], size: 24),
                    SizedBox(width: 8),
                    Text('AKTİF KAMPANYALAR', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        color: Colors.deepOrange[800]
                      )
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ..._campaigns.where((c) => c.isValid()).map((campaign) =>
                  _buildActiveCampaignCard(campaign)
                ),
                if (_campaigns.where((c) => c.isValid()).isEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text('Henüz aktif kampanya yok', 
                          style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Hazır kampanya şablonları
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Icon(Icons.content_copy, color: Colors.deepOrange[600], size: 24),
                      SizedBox(width: 8),
                      Text('HAZIR KAMPANYA ŞABLONLARI', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          color: Colors.black87
                        )
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ..._campaignTemplates.map((template) => 
                    _buildCampaignTemplateCard(template)
                  ),
                  
                  // Özel kampanya oluştur
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.grey[100]!, Colors.grey[50]!],
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[600],
                          radius: 25,
                          child: Icon(Icons.add, color: Colors.white, size: 28),
                        ),
                        title: Text('Özel Kampanya Oluştur',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text('Kendi kampanyanızı tasarlayın',
                          style: TextStyle(color: Colors.grey[600])),
                        onTap: _createCustomCampaign,
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveCampaignCard(Campaign campaign) {
    final daysLeft = campaign.endDate.difference(DateTime.now()).inDays;
    
    return Card(
      elevation: 6,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.deepOrange[400]!, Colors.deepOrange[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange[200], size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(campaign.name, 
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    )
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('%${campaign.discountPercentage.toInt()}',
                    style: TextStyle(
                      color: Colors.deepOrange[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    )
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(campaign.description,
              style: TextStyle(color: Colors.white, fontSize: 14)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text('$daysLeft gün kaldı',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCampaignTemplateCard(Map<String, dynamic> template) {
    final isActive = _campaigns.any((c) => c.name == template['name'] && c.isValid());
    
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: isActive 
              ? [template['color'].withOpacity(0.1), template['color'].withOpacity(0.2)]
              : [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: template['color'],
            radius: 28,
            child: Icon(template['icon'], color: Colors.white, size: 28),
          ),
          title: Text(template['name'], 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: isActive ? template['color'] : Colors.black87
            )
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(template['description'],
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: template['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: template['color'].withOpacity(0.3)),
                ),
                child: Text('%${template['discount']} İNDİRİM', 
                  style: TextStyle(
                    color: template['color'], 
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  )
                ),
              ),
            ],
          ),
          trailing:             Switch(
              value: isActive,
              activeThumbColor: template['color'],
              onChanged: (value) {
              if (value) {
                _activateCampaign(template);
              } else {
                // Aynı isimli kampanyayı sil
                _deactivateCampaign(template['name']);
              }
            },
          ),
        ),
      ),
    );
  }
  
  void _activateCampaign(Map<String, dynamic> template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.schedule, color: template['color']),
            SizedBox(width: 8),
            Text('Kampanya Süresi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${template['name']} kampanyası kaç gün sürecek?',
              style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDurationButton('1 Gün', 1, template),
                _buildDurationButton('3 Gün', 3, template),
                _buildDurationButton('1 Hafta', 7, template),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDurationButton(String text, int days, Map<String, dynamic> template) {
    return ElevatedButton(
      onPressed: () => _startCampaign(template, days),
      style: ElevatedButton.styleFrom(
        backgroundColor: template['color'],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
  
  void _startCampaign(Map<String, dynamic> template, int days) {
    final campaign = Campaign(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: template['name'],
      description: template['description'],
      discountPercentage: template['discount'].toDouble(),
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: days)),
      isActive: true,
      type: template['type'],
    );
    
    setState(() {
      _campaigns.add(campaign);
    });
    
    _saveCampaigns();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Kampanya başlatıldı: ${campaign.name}'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  void _deactivateCampaign(String campaignName) {
    setState(() {
      _campaigns.removeWhere((c) => c.name == campaignName);
    });
    _saveCampaigns();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.cancel, color: Colors.white),
            SizedBox(width: 8),
            Text('Kampanya durduruldu: $campaignName'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  void _sendCampaignSMS() async {
    final activeCampaigns = _campaigns.where((c) => c.isValid()).toList();
    
    if (activeCampaigns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Aktif kampanya yok!'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    // Tüm müşterilere SMS gönder
    final prefs = await SharedPreferences.getInstance();
    final customers = prefs.getStringList('customers') ?? [];
    Set<String> phoneNumbers = {};
    
    for (String customerStr in customers) {
      final customer = Map<String, String>.from(json.decode(customerStr));
      final phone = customer['phone'] ?? '';
      if (phone.isNotEmpty) {
        phoneNumbers.add(phone);
      }
    }
    
    String campaignMessage = '🎉 AUTO CLUB ERENKÖY KAMPANYA!\n\n';
    for (var campaign in activeCampaigns) {
      campaignMessage += '✅ ${campaign.name}\n';
      campaignMessage += '💰 %${campaign.discountPercentage.toInt()} İNDİRİM\n\n';
    }
    campaignMessage += '🏢 Auto Club Erenköy - Profesyonel araç bakımı!';
    
    // SMS gönderme onayı
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.send, color: Colors.blue),
            SizedBox(width: 8),
            Text('SMS Gönderimi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${phoneNumbers.length} müşteriye kampanya SMS\'i gönderilecek.\n\nDevam edilsin mi?',
                style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              for (String phone in phoneNumbers) {
                if (phone.isNotEmpty) {
                  _sendSMS(phone, campaignMessage);
                }
              }
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('${phoneNumbers.length} müşteriye SMS gönderildi!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Gönder'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _sendSMS(String phone, String message) async {
    try {
      // SMS permission kontrolü
      var status = await Permission.sms.status;
      if (status.isDenied) {
        status = await Permission.sms.request();
      }
      
      if (status.isGranted) {
        await platform.invokeMethod('sendSMS', {'phoneNumber': phone, 'message': message});
        print('SMS gönderildi: $phone');
      } else {
        print('SMS permission reddedildi');
      }
    } catch (e) {
      print('SMS hatası: $e');
    }
  }


  
  void _createCustomCampaign() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final discountController = TextEditingController();
    int selectedDays = 3;
    CampaignType selectedType = CampaignType.allServices;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.orange),
            SizedBox(width: 8),
            Text('Özel Kampanya Oluştur'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Kampanya Adı',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: discountController,
                decoration: InputDecoration(
                  labelText: 'İndirim Oranı (%)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<CampaignType>(
                initialValue: selectedType,
                decoration: InputDecoration(
                  labelText: 'Kampanya Türü',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: [
                  DropdownMenuItem(value: CampaignType.allServices, child: Text('Tüm Hizmetler')),
                  DropdownMenuItem(value: CampaignType.specificService, child: Text('Detay Yıkama')),
                  DropdownMenuItem(value: CampaignType.newCustomer, child: Text('Yeni Müşteri')),
                  DropdownMenuItem(value: CampaignType.weekend, child: Text('Hafta Sonu')),
                  DropdownMenuItem(value: CampaignType.happyHour, child: Text('Sabah Erken')),
                ],
                onChanged: (value) => selectedType = value!,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('Süre: '),
                  ...[1, 3, 7, 14].map((days) => 
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$days gün'),
                        selected: selectedDays == days,
                        onSelected: (selected) {
                          if (selected) {
                            selectedDays = days;
                            (context as Element).markNeedsBuild();
                          }
                        },
                      ),
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && discountController.text.isNotEmpty) {
                final campaign = Campaign(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descController.text.isEmpty ? nameController.text : descController.text,
                  discountPercentage: double.tryParse(discountController.text) ?? 0,
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(Duration(days: selectedDays)),
                  isActive: true,
                  type: selectedType,
                );
                
                setState(() {
                  _campaigns.add(campaign);
                });
                _saveCampaigns();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Özel kampanya oluşturuldu: ${campaign.name}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Oluştur'),
          ),
        ],
      ),
    );
  }
}
