import 'client.dart';

String? resolveSkylink(
  String? link, {
  bool trusted = false,
  required SkynetClient skynetClient,
}) {
  if (link == null) return null;

  // TODO Tests
  if (link.startsWith('sia://')) {
    final uri = Uri.tryParse(link);

    if (uri == null) return null;

    final host = uri.host;

    if (host.endsWith('.hns')) {
      return 'https://${host.split(".").first}.hns.${skynetClient.portalHost}${link.substring(6 + host.length)}';
    } else {
      return 'https://${skynetClient.portalHost}/' + link.substring(6);
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
