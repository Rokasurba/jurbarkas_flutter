import 'dart:typed_data';

/// Downloads a file. On non-web platforms, this is a no-op that returns false.
/// Use the return value to show appropriate UI feedback.
bool downloadFile({
  required Uint8List bytes,
  required String fileName,
  String mimeType = 'text/csv',
}) {
  // On mobile/desktop, this stub returns false indicating download
  // is not supported. The caller should handle this by showing
  // appropriate UI (e.g., share dialog).
  return false;
}
