String sanitizePath(String path) {
  // Remove trailing slashes.
  path = trimSuffix(path, "/");

  // Remove duplicate adjacent slashes.
  path = removeAdjacentChars(path, "/");

  return path;
}
/* /**
 * Removes a prefix from the beginning of the string.
 *
 * @param str - The string to process.
 * @param prefix - The prefix to remove.
 * @param [limit] - Maximum amount of times to trim. No limit by default.
 * @returns - The processed string.
 */
String trimPrefix(str: string, prefix: string, limit?: number): string {
  while (str.startsWith(prefix)) {
    if (limit !== undefined && limit <= 0) {
      break;
    }
    str = str.slice(prefix.length);
    if (limit) {
      limit -= 1;
    }
  }
  return str;
} */

String trimSuffix(String str, String suffix, {int? limit}) {
  while (str.endsWith(suffix)) {
    if (limit != null && limit <= 0) {
      break;
    }
    str = str.substring(0, str.length - suffix.length);
    if (limit != null) {
      limit -= 1;
    }
  }
  return str;
}

String removeAdjacentChars(String str, String char) {
  final pathArray = str.split('');

  for (var i = 0; i < pathArray.length - 1;) {
    if (pathArray[i] == char && pathArray[i + 1] == char) {
      pathArray.sublist(i, 1);
    } else {
      i++;
    }
  }
  return pathArray.join("");
}
