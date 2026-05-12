class RazorpayConfig {
  const RazorpayConfig._();

  static const String keyId = String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: '');
  static const String checkoutPrefillContact = String.fromEnvironment('RAZORPAY_PREFILL_CONTACT', defaultValue: '');

  static bool get isConfigured => keyId.isNotEmpty;
}
