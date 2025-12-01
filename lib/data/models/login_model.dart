import '../../domain/entities/login_entity.dart';

/// Data model for login request
class LoginModel extends LoginEntity {
  LoginModel({
    required super.phoneNumber,
    required super.password,
    super.username,
    super.token,
    super.userId,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'password': password,
      if (username != null) 'username': username,
    };
  }

  /// Create from JSON
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      password: json['password'] ?? '',
      username: json['username'],
      token: json['token'],
      userId: json['user_id'] ?? json['userId'],
    );
  }
}

/// Data model for login response
class LoginResponseModel extends LoginResponseEntity {
  LoginResponseModel({
    required super.success,
    super.token,
    super.userId,
    super.username,
    super.phoneNumber,
    super.message,
  });

  /// Create from JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      token: json['token'] ?? json['data']?['token'],
      userId: json['user_id'] ?? json['userId'] ?? json['data']?['user_id'] ?? json['data']?['userId'],
      username: json['username'] ?? json['data']?['username'],
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? json['data']?['phone_number'] ?? json['data']?['phoneNumber'],
      message: json['message'] ?? json['error'] ?? json['data']?['message'],
    );
  }

  /// Convert to entity
  LoginResponseEntity toEntity() {
    return LoginResponseEntity(
      success: success,
      token: token,
      userId: userId,
      username: username,
      phoneNumber: phoneNumber,
      message: message,
    );
  }
}

