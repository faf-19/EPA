import '../../domain/entities/update_profile_entity.dart';

/// Data model for update profile request
class UpdateProfileModel extends UpdateProfileEntity {
  UpdateProfileModel({
    required super.id,
    required super.fullName,
  });

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
      };
}

/// Data model for update profile response
class UpdateProfileResponseModel extends UpdateProfileResponseEntity {
  UpdateProfileResponseModel({
    required super.success,
    super.message,
    super.fullName,
  });

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final fullName = data is Map<String, dynamic>
        ? data['full_name'] ?? data['fullName'] ?? data['name']
        : json['full_name'] ?? json['fullName'] ?? json['name'];

    final successFlag = json['success'] == true ||
        json['status'] == true ||
        json['message']?.toString().toLowerCase().contains('success') == true;

    return UpdateProfileResponseModel(
      success: successFlag,
      message: json['message'] ?? json['detail'],
      fullName: fullName,
    );
  }

  UpdateProfileResponseEntity toEntity() {
    return UpdateProfileResponseEntity(
      success: success,
      message: message,
      fullName: fullName,
    );
  }
}
