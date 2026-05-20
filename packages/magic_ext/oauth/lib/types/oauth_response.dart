import 'package:json_annotation/json_annotation.dart';
import 'package:magic_sdk/modules/user/user_response_type.dart';

import 'oid_type.dart';

part 'oauth_response.g.dart';

@JsonSerializable(explicitToJson: true)
class MagicPartialResult {
  MagicPartialResult(this.idToken, this.userInfo);

  String? idToken;
  UserInfo? userInfo;

  factory MagicPartialResult.fromJson(Map<String, dynamic> json) =>
      _$MagicPartialResultFromJson(json);

  Map<String, dynamic> toJson() => _$MagicPartialResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OAuthPartialResult {
  OAuthPartialResult(
    this.provider,
    this.scope,
    this.accessToken,
    this.userHandle,
    this.userInfo,
  );

  String? provider;
  List<String>? scope;
  String? accessToken;
  String? userHandle;
  OpenIDConnectProfile? userInfo;

  factory OAuthPartialResult.fromJson(Map<String, dynamic> json) =>
      _$OAuthPartialResultFromJson(json);

  Map<String, dynamic> toJson() => _$OAuthPartialResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OAuthResponse {
  OAuthResponse(this.oauth, this.magic);

  OAuthPartialResult? oauth;
  MagicPartialResult? magic;

  factory OAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$OAuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OAuthResponseToJson(this);
}
