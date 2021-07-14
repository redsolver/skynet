String trimUserIdPrefix(String userId) {
  if (userId.startsWith('ed25519-')) {
    return userId.substring(8);
  } else if (userId.startsWith('ed25519:')) {
    return userId.substring(8);
  } else {
    return userId;
  }
}
