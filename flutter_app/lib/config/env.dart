class Env {
  static const String portOneStoreId = String.fromEnvironment(
    'PORTONE_STORE_ID',
    defaultValue: '',
  );

  static const String portOneChannelKey = String.fromEnvironment(
    'PORTONE_CHANNEL_KEY',
    defaultValue: '',
  );

  static bool get isPaymentConfigured =>
      portOneStoreId.isNotEmpty && portOneChannelKey.isNotEmpty;
}