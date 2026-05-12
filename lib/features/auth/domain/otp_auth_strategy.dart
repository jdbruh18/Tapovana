abstract class OtpAuthStrategy {
  Future<void> requestOtp({required String phoneNumber});
  Future<bool> verifyOtp({required String phoneNumber, required String otpCode});
}

class MockOtpAuthStrategy implements OtpAuthStrategy {
  @override
  Future<void> requestOtp({required String phoneNumber}) async {}

  @override
  Future<bool> verifyOtp({required String phoneNumber, required String otpCode}) async {
    return otpCode == '123456';
  }
}
