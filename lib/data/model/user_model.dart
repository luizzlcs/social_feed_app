
import 'package:social_feed_app/domain/entities/user.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
  });
  
  // Converte de Model para Entity
  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
    );
  }
  
  // Converte de JSON para Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }
  
  // Converte de Model para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}