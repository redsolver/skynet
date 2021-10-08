import 'package:skynet/src/utils/paths.dart';

/**
 * Removes slashes from the beginning and end of the string.
 *
 * @param str - The string to process.
 * @returns - The processed string.
 */
String trimForwardSlash(String str) {
  final str2 = trimSuffix(str, "/");
  return str2.startsWith('/') ? str2.substring(1) : str2;
}
