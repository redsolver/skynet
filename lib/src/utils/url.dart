import 'package:skynet/src/utils/paths.dart';
import 'package:skynet/src/utils/string.dart';

/**
 * Extracts the domain from the given portal URL,
 * e.g. ("https://siasky.net", "dac.hns.siasky.net/path/file") => "dac.hns/path/file"
 *
 * @param portalUrl - The portal URL.
 * @param fullDomain - Full URL.
 * @returns - The extracted domain.
 */
// TODO Implement this :)
String extractDomainForPortal(String portalHost, String fullDomain) {
  return fullDomain.replaceFirst('.$portalHost', '');
  String? path;
  try {
    // Try to extract the domain from the fullDomain.
    final fullDomainObj = Uri.parse(fullDomain);
    fullDomain = fullDomainObj.host;
    path = fullDomainObj.path;
    path = trimForwardSlash(path);
  } catch (_) {
    // If fullDomain is not a URL, ignore the error and use it as-is.
    //
    // Trim any slashes from the input URL.
    fullDomain = trimForwardSlash(fullDomain);
    // Split on first / to get the path.
    final parts = fullDomain.split(r'/(.+)');
    fullDomain = parts[0];
    final path = parts[1];
    // Lowercase the domain to match URL parsing. Leave path as-is.
    fullDomain = fullDomain.toLowerCase();
  }

  // Get the portal domain.
  // const portalUrlObj = new URL(portalUrl);
  final portalDomain = portalHost;
  print('! "$fullDomain" "$portalDomain"');

  // Remove the portal domain from the domain.
  var domain = trimSuffix(fullDomain, portalDomain, limit: 1);
  print('! "$path" "$domain"');
  domain = trimSuffix(domain, ".");
  print('! "$path" "$domain"');
  // Add back the path if there is one.
  if ((path ?? '').isNotEmpty) {
    path = trimForwardSlash(path!);
    domain = '${domain}/${path}';
  }
  print('! "$path" "$domain"');
  return domain;
}
