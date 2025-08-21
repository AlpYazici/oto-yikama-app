

// Gelir analizi modeli
class RevenueAnalysis {
  final DateTime date;
  final double totalRevenue;
  final Map<String, ServiceStats> serviceStats;
  final int totalCustomers;
  
  RevenueAnalysis({
    required this.date,
    required this.totalRevenue,
    required this.serviceStats,
    required this.totalCustomers,
  });
  
  // JSON'a dönüştür (kayıt için)
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'totalRevenue': totalRevenue,
    'totalCustomers': totalCustomers,
    'serviceStats': serviceStats.map((key, value) => MapEntry(key, value.toJson())),
  };
  
  factory RevenueAnalysis.fromJson(Map<String, dynamic> json) {
    return RevenueAnalysis(
      date: DateTime.parse(json['date']),
      totalRevenue: json['totalRevenue'].toDouble(),
      totalCustomers: json['totalCustomers'],
      serviceStats: Map<String, ServiceStats>.from(
        json['serviceStats'].map((key, value) => 
          MapEntry(key, ServiceStats.fromJson(value)))
      ),
    );
  }
}

// Hizmet istatistikleri modeli
class ServiceStats {
  final String serviceName;
  final int count;
  final double revenue;
  final double averagePrice;
  
  ServiceStats({
    required this.serviceName,
    required this.count,
    required this.revenue,
    required this.averagePrice,
  });
  
  Map<String, dynamic> toJson() => {
    'serviceName': serviceName,
    'count': count,
    'revenue': revenue,
    'averagePrice': averagePrice,
  };
  
  factory ServiceStats.fromJson(Map<String, dynamic> json) {
    return ServiceStats(
      serviceName: json['serviceName'],
      count: json['count'],
      revenue: json['revenue'].toDouble(),
      averagePrice: json['averagePrice'].toDouble(),
    );
  }
}
