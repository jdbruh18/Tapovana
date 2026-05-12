class IntegrationsConfig {
  const IntegrationsConfig({
    required this.razorpay,
    required this.otp,
    required this.notifications,
  });

  final RazorpayIntegrationConfig razorpay;
  final OtpIntegrationConfig otp;
  final NotificationIntegrationConfig notifications;

  factory IntegrationsConfig.fromEnvironment() {
    return IntegrationsConfig(
      razorpay: RazorpayIntegrationConfig.fromEnvironment(),
      otp: OtpIntegrationConfig.fromEnvironment(),
      notifications: NotificationIntegrationConfig.fromEnvironment(),
    );
  }
}

class RazorpayIntegrationConfig {
  const RazorpayIntegrationConfig({required this.keyId, required this.keySecret, required this.webhookSecret});

  final String keyId;
  final String keySecret;
  final String webhookSecret;

  factory RazorpayIntegrationConfig.fromEnvironment() {
    return RazorpayIntegrationConfig(
      keyId: const String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: ''),
      keySecret: const String.fromEnvironment('RAZORPAY_KEY_SECRET', defaultValue: ''),
      webhookSecret: const String.fromEnvironment('RAZORPAY_WEBHOOK_SECRET', defaultValue: ''),
    );
  }

  bool get isConfigured => keyId.isNotEmpty && keySecret.isNotEmpty;
}

class OtpIntegrationConfig {
  const OtpIntegrationConfig({required this.provider, required this.senderId});

  final String provider;
  final String senderId;

  factory OtpIntegrationConfig.fromEnvironment() {
    return OtpIntegrationConfig(
      provider: const String.fromEnvironment('OTP_PROVIDER', defaultValue: 'mock'),
      senderId: const String.fromEnvironment('OTP_SENDER_ID', defaultValue: ''),
    );
  }
}

class NotificationIntegrationConfig {
  const NotificationIntegrationConfig({required this.smsProvider, required this.whatsappProvider});

  final String smsProvider;
  final String whatsappProvider;

  factory NotificationIntegrationConfig.fromEnvironment() {
    return NotificationIntegrationConfig(
      smsProvider: const String.fromEnvironment('SMS_PROVIDER', defaultValue: 'noop'),
      whatsappProvider: const String.fromEnvironment('WHATSAPP_PROVIDER', defaultValue: 'noop'),
    );
  }
}

abstract class OtpProvider {
  Future<void> sendOtp({required String phoneNumber, required String context});
  Future<bool> verifyOtp({required String phoneNumber, required String code});
}

class MockOtpProvider implements OtpProvider {
  @override
  Future<void> sendOtp({required String phoneNumber, required String context}) async {}

  @override
  Future<bool> verifyOtp({required String phoneNumber, required String code}) async {
    return code == '123456';
  }
}

enum NotificationChannel { sms, whatsapp }

abstract class NotificationProvider {
  Future<void> notify({
    required NotificationChannel channel,
    required String recipient,
    required String message,
  });
}

class NoopNotificationProvider implements NotificationProvider {
  @override
  Future<void> notify({
    required NotificationChannel channel,
    required String recipient,
    required String message,
  }) async {}
}
