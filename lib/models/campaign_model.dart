

// Kampanya türleri
enum CampaignType {
  allServices,      // Tüm hizmetler
  specificService,  // Belirli hizmet
  newCustomer,      // Yeni müşteri
  loyaltyProgram,   // Sadakat programı
  happyHour,        // Belirli saatler
  weekend,          // Hafta sonu
}

// Kampanya modeli
class Campaign {
  final String id;
  final String name;
  final String description;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? promoCode;
  final CampaignType type;
  
  Campaign({
    required this.id,
    required this.name,
    required this.description,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.promoCode,
    required this.type,
  });
  
  // Kampanya geçerli mi?
  bool isValid() {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
  
  // İndirimli fiyat hesapla
  double calculateDiscountedPrice(double originalPrice) {
    return originalPrice * (1 - discountPercentage / 100);
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'discountPercentage': discountPercentage,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'isActive': isActive,
    'promoCode': promoCode,
    'type': type.toString(),
  };
  
  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      discountPercentage: json['discountPercentage'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'],
      promoCode: json['promoCode'],
      type: CampaignType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => CampaignType.allServices,
      ),
    );
  }
}
