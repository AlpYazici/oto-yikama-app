import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/revenue_model.dart';

class RevenueAnalysisScreen extends StatefulWidget {
  const RevenueAnalysisScreen({super.key});

  @override
  _RevenueAnalysisScreenState createState() => _RevenueAnalysisScreenState();
}

class _RevenueAnalysisScreenState extends State<RevenueAnalysisScreen> {

  List<RevenueAnalysis> _weeklyData = [];
  Map<String, dynamic> _todayStats = {};
  Map<String, dynamic> _weekStats = {};
  List<Map<String, dynamic>> _serviceRanking = [];
  
  @override
  void initState() {
    super.initState();
    _loadAllData();
  }
  
  Future<void> _loadAllData() async {
    await _loadWeeklyData();
    await _calculateTodayStats();
    await _calculateWeekStats();
    await _calculateServiceRanking();
  }
  
  Future<void> _loadWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    List<RevenueAnalysis> weekData = [];
    
    // Son 7 günün verilerini yükle
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = date.toString().substring(0, 10);
      final dataStr = prefs.getString('revenue_$dateStr');
      
      if (dataStr != null) {
        weekData.add(RevenueAnalysis.fromJson(json.decode(dataStr)));
      }
    }
    
    setState(() {
      _weeklyData = weekData;
    });
  }
  
  Future<void> _calculateTodayStats() async {
    final prefs = await SharedPreferences.getInstance();
    final customers = prefs.getStringList('customers') ?? [];
    double totalRevenue = 0; int totalCustomers = 0;
    final today = DateTime.now().toString().substring(0, 10);
    
    for (final String customerStr in customers) {
      final customer = Map<String, String>.from(json.decode(customerStr));
      if ((customer['date'] ?? '') == today) {
        totalCustomers++;
        totalRevenue += _extractPriceFromService(customer['service'] ?? '');
      }
    }
    
    _todayStats = {
      'revenue': totalRevenue.toInt(),
      'count': totalCustomers,
      'average': totalCustomers > 0 ? (totalRevenue / totalCustomers).toInt() : 0,
    };
    if (mounted) setState(() {});
  }
  
  Future<void> _calculateWeekStats() async {
    double total = 0;
    int count = 0;
    
    for (var analysis in _weeklyData) {
      total += analysis.totalRevenue;
      count += analysis.totalCustomers;
    }
    
    // Eğer haftalık veri yoksa müşteri listesinden hesapla
    if (_weeklyData.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final customers = prefs.getStringList('customers') ?? [];
      
      for (final String customerStr in customers) {
        final customer = Map<String, String>.from(json.decode(customerStr));
        final customerDate = customer['date'] ?? '';
        
        if (customerDate.isNotEmpty) {
          final date = DateTime.parse(customerDate + ' 00:00:00');
          final now = DateTime.now();
          final daysDiff = now.difference(date).inDays;
          
          if (daysDiff <= 7) {
            count++;
            final service = customer['service'] ?? '';
            final price = _extractPriceFromService(service);
            total += price;
          }
        }
      }
    }
    
    setState(() {
      _weekStats = {
        'revenue': total.toInt(),
        'count': count,
        'average': count > 0 ? (total / count).toInt() : 0,
      };
    });
  }
  
  Future<void> _calculateServiceRanking() async {
    final prefs = await SharedPreferences.getInstance();
    final customers = prefs.getStringList('customers') ?? [];
    
    Map<String, Map<String, dynamic>> serviceData = {};
    
    // Son 7 günün verilerini analiz et
    for (final String customerStr in customers) {
      final customer = Map<String, String>.from(json.decode(customerStr));
      final customerDate = customer['date'] ?? '';
      
      if (customerDate.isNotEmpty) {
        final date = DateTime.parse(customerDate + ' 00:00:00');
        final now = DateTime.now();
        final daysDiff = now.difference(date).inDays;
        
        if (daysDiff <= 7) {
          final service = customer['service'] ?? '';
          final price = _extractPriceFromService(service);
          
          if (!serviceData.containsKey(service)) {
            serviceData[service] = {
              'name': service,
              'count': 0,
              'revenue': 0.0,
            };
          }
          serviceData[service]!['count']++;
          serviceData[service]!['revenue'] += price;
        }
      }
    }
    
    final totalRevenue = serviceData.values.fold(0.0, (sum, item) => sum + item['revenue']);
    
    // Yüzde hesapla ve sırala
    final sortedServices = serviceData.values.map((service) {
      service['percentage'] = totalRevenue > 0 
        ? ((service['revenue'] / totalRevenue) * 100).toInt()
        : 0;
      return service;
    }).toList()
      ..sort((a, b) => b['revenue'].compareTo(a['revenue']));
    
    setState(() {
      _serviceRanking = sortedServices;
    });
  }
  
  double _extractPriceFromService(String service) {
    final match = RegExp(r'(\d+)₺').firstMatch(service);
    return match != null ? double.parse(match.group(1)!) : 0.0;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📊 Gelir Analizi'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.orange[400],
        elevation: 4,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Gelecekte filtre özelliği eklenebilir
              setState(() {
                // Şimdilik hiçbir şey yapmıyor
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Bugün', child: Text('Bugün')),
              PopupMenuItem(value: 'Bu Hafta', child: Text('Bu Hafta')),
              PopupMenuItem(value: 'Bu Ay', child: Text('Bu Ay')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[50]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Özet Kartlar
                _buildSummaryCards(),
                
                SizedBox(height: 24),
                
                // Hizmet Sıralaması (Çoktan Aza)
                _buildServiceRanking(),
                
                SizedBox(height: 24),
                
                // Haftalık Grafik
                _buildWeeklyChart(),
                
                SizedBox(height: 24),
                
                // Detaylı Tablo
                _buildDetailedTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSummaryCards() {
    return Column(
      children: [
        // Bugünkü Gelir
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 30,
                child: Icon(Icons.today, color: Colors.green[600], size: 32),
              ),
              title: Text('BUGÜNKÜ GELİR',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    '${_todayStats['revenue'] ?? 0}₺',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text('${_todayStats['count'] ?? 0} araç yıkandı',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Ort: ${_todayStats['average'] ?? 0}₺',
                      style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SizedBox(height: 16),
        
        // Haftalık Gelir
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 30,
                child: Icon(Icons.calendar_month, color: Colors.blue[600], size: 32),
              ),
              title: Text('HAFTALIK GELİR',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    '${_weekStats['revenue'] ?? 0}₺',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text('${_weekStats['count'] ?? 0} araç yıkandı',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Ort: ${_weekStats['average'] ?? 0}₺',
                      style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // En Çok Tercih Edilen
        if (_serviceRanking.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 16),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.purple[400]!, Colors.purple[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(20),
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.star, color: Colors.amber[600], size: 32),
                  ),
                  title: Text('EN ÇOK TERCİH EDİLEN',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        _serviceRanking[0]['name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text('${_serviceRanking[0]['count']} kez seçildi',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${_serviceRanking[0]['revenue']}₺',
                          style: TextStyle(color: Colors.purple[600], fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildServiceRanking() {
    if (_serviceRanking.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Henüz hizmet verisi yok', style: TextStyle(fontSize: 16)),
        ),
      );
    }
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[600], size: 28),
                SizedBox(width: 12),
                Text('🏆 HİZMET SIRALAMASI (ÇOKTAN AZA)', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              ],
            ),
            SizedBox(height: 20),
            
            ..._serviceRanking.asMap().entries.map((entry) {
              final index = entry.key;
              final service = entry.value;
              final medal = index == 0 ? '🥇' : index == 1 ? '🥈' : index == 2 ? '🥉' : '${index + 1}.';
              
              Color cardColor = index == 0 ? Colors.amber[50]! : 
                               index == 1 ? Colors.grey[100]! : 
                               index == 2 ? Colors.orange[50]! : Colors.white;
              
              Color borderColor = index == 0 ? Colors.amber : 
                                 index == 1 ? Colors.grey[400]! :
                                 index == 2 ? Colors.orange :
                                 Colors.grey[300]!;
              
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: index == 0 ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(medal, style: TextStyle(fontSize: 28)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service['name'], 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: Colors.grey[800]
                            )
                          ),
                          SizedBox(height: 4),
                          Text('${service['count']} kez - ${service['revenue'].toInt()}₺',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: borderColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${service['percentage']}%', 
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: index == 0 ? Colors.amber[800] : Colors.grey[700]
                            )
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('toplam gelirden',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyChart() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green[600], size: 28),
                SizedBox(width: 12),
                Text('📈 HAFTALIK GELİR GRAFİĞİ', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              ],
            ),
            SizedBox(height: 20),
            
            Container(
              height: 220,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _buildBarChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildBarChart() {
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final maxRevenue = _getMaxRevenue();
    
    return List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final dayRevenue = _getDayRevenue(date);
      
      final height = maxRevenue > 0 ? (dayRevenue / maxRevenue) * 160 : 0.0;
      final isToday = index == 6;
      
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isToday ? Colors.green[100] : Colors.blue[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('${dayRevenue.toInt()}₺', 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.green[800] : Colors.blue[800]
              )
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: 32,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isToday 
                  ? [Colors.green[400]!, Colors.green[600]!]
                  : [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
              boxShadow: [
                BoxShadow(
                  color: (isToday ? Colors.green : Colors.blue).withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(days[index], 
            style: TextStyle(
              fontSize: 14, 
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? Colors.green[800] : Colors.grey[700]
            )
          ),
        ],
      );
    });
  }
  
  double _getMaxRevenue() {
    double max = 0;
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final revenue = _getDayRevenue(date);
      if (revenue > max) max = revenue;
    }
    return max > 0 ? max : 1000;
  }
  
  double _getDayRevenue(DateTime date) {
    final dateStr = date.toString().substring(0, 10);
    
    // Önce haftalık verilerden bul
    for (var analysis in _weeklyData) {
      if (analysis.date.toString().substring(0, 10) == dateStr) {
        return analysis.totalRevenue;
      }
    }
    
    // Bulunamazsa bugünse bugünkü istatistiklerden al
    if (dateStr == DateTime.now().toString().substring(0, 10)) {
      return (_todayStats['revenue'] ?? 0).toDouble();
    }
    
    return 0;
  }
  
  Widget _buildDetailedTable() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: Colors.indigo[600], size: 28),
                SizedBox(width: 12),
                Text('📋 DETAYLI İSTATİSTİKLER', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              ],
            ),
            SizedBox(height: 20),
            
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Başlık
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text('HİZMET', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('ADET', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Expanded(child: Text('GELİR', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Expanded(child: Text('ORT.', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                  
                  // Veriler
                  ..._serviceRanking.map((service) {
                    final average = service['count'] > 0 
                      ? (service['revenue'] / service['count']).toInt()
                      : 0;
                    
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(service['name'], 
                              style: TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            )
                          ),
                          Expanded(
                            child: Text('${service['count']}', 
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            )
                          ),
                          Expanded(
                            child: Text('${service['revenue'].toInt()}₺', 
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )
                          ),
                          Expanded(
                            child: Text('${average}₺', 
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            )
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
