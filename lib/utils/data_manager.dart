import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/revenue_model.dart';
import '../models/campaign_model.dart';

class DataManager {
  static Future<void> saveDailyRevenue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customers = prefs.getStringList('customers') ?? [];
      Map<String, ServiceStats> serviceStats = {};
      double totalRevenue = 0; int totalCustomers = 0;
      final today = DateTime.now().toString().substring(0, 10);
      
      for (final String customerStr in customers) {
        final customer = Map<String, String>.from(json.decode(customerStr));
        if ((customer['date'] ?? '') == today) {
          totalCustomers++;
          final service = customer['service'] ?? '';
          final originalPrice = _extractPriceFromService(service);
          final finalPrice = await _applyActiveCampaignDiscount(originalPrice, service);
          totalRevenue += finalPrice;
          
          if (!serviceStats.containsKey(service)) {
            serviceStats[service] = ServiceStats(serviceName: service, count: 0, revenue: 0, averagePrice: 0);
          }
          
          final currentStats = serviceStats[service]!;
          final newCount = currentStats.count + 1;
          final newRevenue = currentStats.revenue + finalPrice;
          serviceStats[service] = ServiceStats(serviceName: service, count: newCount, revenue: newRevenue, averagePrice: newRevenue / newCount);
        }
      }
      
      final analysis = RevenueAnalysis(date: DateTime.now(), totalRevenue: totalRevenue, serviceStats: serviceStats, totalCustomers: totalCustomers);
      await prefs.setString('revenue_$today', json.encode(analysis.toJson()));
      await _updateWeeklySummary();
    } catch (e) {}
  }
  
  static Future<void> _updateWeeklySummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> weekData = [];
      for (int i = 0; i < 7; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateStr = date.toString().substring(0, 10);
        final dataStr = prefs.getString('revenue_$dateStr');
        if (dataStr != null) weekData.add(json.decode(dataStr));
      }
      await prefs.setString('weekly_summary', json.encode(weekData));
    } catch (e) {}
  }
  
  static Future<List<Campaign>> getActiveCampaigns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final campaignsList = prefs.getStringList('campaigns') ?? [];
      List<Campaign> campaigns = [];
      for (final String campaignStr in campaignsList) {
        final campaign = Campaign.fromJson(json.decode(campaignStr));
        if (campaign.isValid()) campaigns.add(campaign);
      }
      return campaigns;
    } catch (e) {
      return [];
    }
  }
  
  static Future<double> _applyActiveCampaignDiscount(double originalPrice, String service) async {
    try {
      final activeCampaigns = await getActiveCampaigns();
      if (activeCampaigns.isEmpty) return originalPrice;
      
      double maxDiscount = 0;
      for (var campaign in activeCampaigns) {
        bool canApply = false;
        final now = DateTime.now();
        
        switch (campaign.type) {
          case CampaignType.allServices: case CampaignType.newCustomer: case CampaignType.loyaltyProgram:
            canApply = true;
            break;
          case CampaignType.specificService:
            canApply = campaign.name.contains('Detay') && service.contains('Detay');
            break;
          case CampaignType.happyHour:
            canApply = now.hour >= 8 && now.hour < 10;
            break;
          case CampaignType.weekend:
            canApply = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
            break;
        }
        
        if (canApply && campaign.discountPercentage > maxDiscount) {
          maxDiscount = campaign.discountPercentage;
        }
      }
      
      return originalPrice * (1 - maxDiscount / 100);
    } catch (e) {
      return originalPrice;
    }
  }
  
  static double _extractPriceFromService(String service) {
    final match = RegExp(r'(\d+)₺').firstMatch(service);
    return match != null ? double.parse(match.group(1)!) : 0.0;
  }
  
  static Future<void> cleanOldData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customers = prefs.getStringList('customers') ?? [];
      final now = DateTime.now();
      
      List<String> validCustomers = customers.where((customerStr) {
        try {
          final customer = Map<String, String>.from(json.decode(customerStr));
          final customerDate = customer['date'] ?? '';
          if (customerDate.isEmpty) return false;
          final date = DateTime.parse('$customerDate 00:00:00');
          return now.difference(date).inDays <= 30;
        } catch (e) { return false; }
      }).toList();
      
      await prefs.setStringList('customers', validCustomers);
      
      for (int i = 31; i <= 100; i++) {
        final oldDate = now.subtract(Duration(days: i));
        await prefs.remove('revenue_${oldDate.toString().substring(0, 10)}');
      }
    } catch (e) {}
  }
}