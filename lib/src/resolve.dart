import 'dart:convert';
import 'utils/base32.dart';

import 'client.dart';

String? resolveSkylink(
  String? link, {
  bool trusted = false,
  bool isolated = false,
  required SkynetClient skynetClient,
}) {
  // print('resolveSkylink $link');
  if (link == null) return null;

  // TODO Tests
  if (link.startsWith('sia://')) {
    final uri = Uri.tryParse(link);

    if (uri == null) return null;

    final host = uri.host;

    if (host.endsWith('.hns')) {
      return 'https://${host.split(".").first}.hns.${skynetClient.portalHost}${link.substring(6 + host.length)}';
    } else {
      final skylink = link.substring(6, 6 + 46);
      if (isolated) {
        var base64SkyLink = skylink;

        while (base64SkyLink.length % 4 != 0) {
          base64SkyLink = base64SkyLink + '=';
        }

        // print(base64SkyLink);

        var b32skylink = base32.encode(
          base64.decode(base64SkyLink),
        );
        while (b32skylink.endsWith('=')) {
          b32skylink = b32skylink.substring(0, b32skylink.length - 1);
        }
        return 'https://${b32skylink}.${skynetClient.portalHost}' +
            link.substring(6 + skylink.length);
      } else {
        return 'https://${skynetClient.portalHost}/' + link.substring(6);
      }
    }
  } else if (link.startsWith('sia:')) {
    return 'https://${skynetClient.portalHost}/' + link.substring(4);
  }

  if (trusted) {
    return link;
  } else {
    // print('disallowed link $link');
    return '';
  }
}
