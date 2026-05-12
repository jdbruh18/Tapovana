enum NotificationChannel { sms, whatsapp }

abstract class NotificationProvider {
  Future<void> send({
    required NotificationChannel channel,
    required String recipient,
    required String message,
  });
}

class NoopNotificationProvider implements NotificationProvider {
  @override
  Future<void> send({
    required NotificationChannel channel,
    required String recipient,
    required String message,
  }) async {}
}
