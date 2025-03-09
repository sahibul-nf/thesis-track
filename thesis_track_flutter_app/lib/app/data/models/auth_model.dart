import 'dart:convert';

import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';

class AuthData {
    final String accessToken;
    final String refreshToken;
    final int expiresIn;
    final int expiresAt;
    final String role;
    final User user;

    AuthData({
        required this.accessToken,
        required this.refreshToken,
        required this.expiresIn,
        required this.expiresAt,
        required this.role,
        required this.user,
    });    

    factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
        accessToken: json["access_token"],
        refreshToken: json["refresh_token"],
        expiresIn: json["expires_in"],
        expiresAt: json["expires_at"],
        role: json["role"],
        user: User.fromJson(json["user"], role: json["role"]),
    );

    Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "refresh_token": refreshToken,
        "expires_in": expiresIn,
        "expires_at": expiresAt,
        "role": role,
        "user": user.toJson(),
    };
}
