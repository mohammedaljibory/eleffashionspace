// This model represents our user data structure
class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final double? latitude;
  final double? longitude;
  final String? address;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    this.latitude,
    this.longitude,
    this.address,
    required this.createdAt,
    this.lastLogin,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      address: map['address'],
      createdAt: DateTime.parse(map['createdAt']),
      lastLogin: map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
    );
  }
}