
class Organization {
  final String id;
  final String name;
  final String category; // Added category
  final String address;
  final String phone;
  final String email;
  final String? logoUrl; // Added logoUrl
  final String contactPerson;
  final String? youtubeLiveUrl;
  final String? facebookLiveUrl;
  final bool isLive;
  final List<String> subscribers;

  Organization({
    required this.id,
    required this.name,
    this.category = 'Organization',
    required this.address,
    required this.phone,
    required this.email,
    this.logoUrl,
    required this.contactPerson,
    this.youtubeLiveUrl,
    this.facebookLiveUrl,
    this.isLive = false,
    this.subscribers = const [],
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Organization',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      logoUrl: json['logoUrl'],
      contactPerson: json['contactPerson'] ?? '',
      youtubeLiveUrl: json['youtubeLiveUrl'],
      facebookLiveUrl: json['facebookLiveUrl'],
      isLive: json['isLive'] ?? false,
      subscribers: List<String>.from(json['subscribers'] ?? []),
    );
  }

  factory Organization.fromFirestore(Map<String, dynamic> data, String id) {
    return Organization(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'Organization',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      logoUrl: data['logoUrl'],
      contactPerson: data['contactPerson'] ?? '',
      youtubeLiveUrl: data['youtubeLiveUrl'],
      facebookLiveUrl: data['facebookLiveUrl'],
      isLive: data['isLive'] ?? false,
      subscribers: List<String>.from(data['subscribers'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'phone': phone,
      'email': email,
      'logoUrl': logoUrl,
      'contactPerson': contactPerson,
      'youtubeLiveUrl': youtubeLiveUrl,
      'facebookLiveUrl': facebookLiveUrl,
      'isLive': isLive,
      'subscribers': subscribers,
    };
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'phone': phone,
      'email': email,
      'logoUrl': logoUrl,
      'contactPerson': contactPerson,
      'youtubeLiveUrl': youtubeLiveUrl,
      'facebookLiveUrl': facebookLiveUrl,
      'isLive': isLive,
      'subscribers': subscribers,
    };
  }
}
