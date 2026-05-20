/// OAuth Configuration
class OAuthConfiguration {
  OAuthConfiguration({
    required this.provider,
    required this.redirectURI,
    this.scope,
    this.loginHint,
  });

  final OAuthProvider provider;
  final String redirectURI;
  final List<String>? scope;
  final String? loginHint;
}

/// OAuth Supported Provider
enum OAuthProvider {
  GOOGLE,
  FACEBOOK,
  GITHUB,
  APPLE,
  LINKEDIN,
  BITBUCKET,
  GITLAB,
  TWITTER,
  DISCORD,
  TWITCH,
  MICROSOFT,
}

extension ParseOAuthProviderToString on OAuthProvider {
  String toShortString() {
    return toString().split('.').last.toLowerCase();
  }
}
