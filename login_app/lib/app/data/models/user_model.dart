class UserModel {

  final int? id;
  final String name;
  final String username;
  final String email;
  final String phone;

  // Constructor
  UserModel({
    this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
  });

  // Convert JSON into Dart object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      name: json['full_name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }

  // Convert Dart object into JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'full_name': name,
      'username': username,
      'email': email,
      'phone': phone,
    };
  }
}