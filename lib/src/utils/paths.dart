String sanitizePath(String path) {
  // Remove trailing slashes.
  path = trimSuffix(path, "/");

  // Remove duplicate adjacent slashes.
  path = removeAdjacentChars(path, "/");

  return path;
}

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
