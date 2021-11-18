import 'dart:html';

String detectSkynetPortal() {
  // print('detectSkynetPortal v0.1.1');

  var host = window.location.hostname?.split('.hns.').last;

  if (host == null) return 'siasky.net';

/*   if (host.endsWith('.hns')) {
    return '';
  } */

  if (host == 'localhost' || host == '127.0.0.1') {
    return 'siasky.net';
  }
  final parts = host.split('.');
  if (parts.length > 2) {
    host = host.substring(parts[0].length + 1);
  }
  if (host == 'eth.link') {
    return 'siasky.net';
  }
  return host;
}
