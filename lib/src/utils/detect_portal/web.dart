import 'dart:html';

String detectSkynetPortal() {
  var host = window.location.hostname?.split('.hns.').last;

  if (host == null) return 'siasky.net';

  if (host == 'localhost' || host == '127.0.0.1') {
    return 'siasky.net';
  }
  final parts = host.split('.');
  if (parts.length > 2) {
    return host.substring(parts[0].length + 1);
  }
  return host;
}
