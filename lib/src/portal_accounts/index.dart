import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:skynet/skynet.dart';
import 'package:skynet/src/client.dart';
import 'package:skynet/src/crypto.dart';
import 'package:cryptography/cryptography.dart' hide MacAlgorithm;

/**
 * The name of the response header containing the JWT token.
 */
const JWT_HEADER_NAME = "set-cookie";

/**
 * The size of the expected signature.
 */
/* final CHALLENGE_SIGNATURE_SIZE = sign.signatureLength; */

/**
 * The number of bytes of entropy to send as a challenge.
 */
const CHALLENGE_SIZE = 32;
/**
 * The type of the login challenge.
 */
const CHALLENGE_TYPE_LOGIN = "skynet-portal-login";
/**
 * The type of the registration challenge.
 */

const CHALLENGE_TYPE_REGISTER = "skynet-portal-register";

const CHALLENGE_TYPE_UPDATE = "skynet-portal-update";

const endpointLogin = "/api/login";
const endpointLoginRequest = "/api/login";

const endpointRegister = "/api/register";
const endpointRegisterRequest = "/api/register";

const endpointRegisterUserPubkey = "/api/user/pubkey/register";

/**
 * Registers a pubkey for the user for the given seed and tweak.
 *
 * @param client - The Skynet client.
 * @param seed - The seed.
 * @param tweak - The portal account tweak.
 * @param [customOptions] - The custom register user options.
 * @returns - An empty promise.
 */
Future<void> registerUserPubkey(
  SkynetClient client,
  Uint8List seed,
  String tweak,
) async {
  final keyPair = await genPortalLoginKeypair(seed, tweak);

  final publicKey = await keyPair.extractPublicKey();

  final registerRequestResponse = await client.httpClient.get(
    Uri.https(
      'account.' + client.portalHost,
      endpointRegisterUserPubkey,
      {
        'pubKey': hex.encode(publicKey.bytes),
      },
    ),
    headers: client.headers,
  );
  final registerRequestResponseData = json.decode(registerRequestResponse.body);

  final challenge = registerRequestResponseData['challenge'];

  final portalRecipient = getPortalRecipient(client.portalHost);

  final challengeResponse = await signChallenge(
    keyPair,
    challenge,
    CHALLENGE_TYPE_UPDATE,
    portalRecipient,
  );

  final data = {
    'response': challengeResponse.response,
    'signature': challengeResponse.signature,
  };

  final registerResponse = await client.httpClient.post(
    Uri.https(
      'account.' + client.portalHost,
      endpointRegisterUserPubkey,
    ),
    headers: {'content-type': 'application/json'}..addAll(client.headers ?? {}),
    body: json.encode(data),
  );

  if (registerResponse.statusCode != 204) {
    throw 'HTTP ${registerResponse.statusCode}: ${registerResponse.body}';
  }

  /* final jwt = registerResponse.headers[JWT_HEADER_NAME]!.split(';').first;

  return jwt; */
}

/**
 * Registers a user for the given seed and email.
 *
 * @param client - The Skynet client.
 * @param seed - The seed.
 * @param email - The user email.
 * @param [customOptions] - The custom register options.
 * @returns - The JWT token.
 */
Future<String> register(
  SkynetClient client,
  Uint8List seed,
  String email,
  String tweak,
) async {
  final keyPair = await genPortalLoginKeypair(seed, tweak);

  final publicKey = await keyPair.extractPublicKey();

  final registerRequestResponse = await client.httpClient.get(
    Uri.https(
      'account.' + client.portalHost,
      endpointRegisterRequest,
      {
        'pubKey': hex.encode(publicKey.bytes),
      },
    ),
  );
  if (registerRequestResponse.statusCode != 200) {
    throw 'HTTP ${registerRequestResponse.statusCode}: ${registerRequestResponse.body}';
  }

  final registerRequestResponseData = json.decode(registerRequestResponse.body);

  final challenge = registerRequestResponseData['challenge'];

  final portalRecipient = getPortalRecipient(client.portalHost);

  final challengeResponse = await signChallenge(
    keyPair,
    challenge,
    CHALLENGE_TYPE_REGISTER,
    portalRecipient,
  );

  final data = {
    'response': challengeResponse.response,
    'signature': challengeResponse.signature,
    'email': email,
  };

  final registerResponse = await client.httpClient.post(
    Uri.https(
      'account.' + client.portalHost,
      endpointRegister,
    ),
    headers: {'content-type': 'application/json'},
    body: json.encode(data),
  );

  if (registerResponse.statusCode != 200) {
    throw 'HTTP ${registerResponse.statusCode}: ${registerResponse.body}';
  }

  final jwt = registerResponse.headers[JWT_HEADER_NAME]!.split(';').first;

  return jwt;
}

/**
 * Logs in a user for the given seed and email.
 *
 * @param client - The Skynet client.
 * @param seed - The seed.
 * @param email - The user email.
 * @param [customOptions] - The custom login options.
 * @returns - The JWT token.
 */
Future<String> login(
  SkynetClient client,
  Uint8List seed,
  String tweak,
) async {
  final keyPair = await genPortalLoginKeypair(seed, tweak);

  final publicKey = await keyPair.extractPublicKey();
  final privateKey = await keyPair.extractPrivateKeyBytes();

  final loginRequestResponse = await client.httpClient.get(
    Uri.https(
      'account.' + client.portalHost,
      endpointLogin,
      {
        'pubKey': hex.encode(publicKey.bytes),
      },
    ),
  );
  final loginRequestResponseData = json.decode(loginRequestResponse.body);

  final challenge = loginRequestResponseData['challenge'];

  final portalRecipient = getPortalRecipient(client.portalHost);

  final challengeResponse = await signChallenge(
    keyPair,
    challenge,
    CHALLENGE_TYPE_LOGIN,
    portalRecipient,
  );

  final data = {
    'response': challengeResponse.response,
    'signature': challengeResponse.signature,
  };

  final loginResponse = await client.httpClient.post(
    Uri.https(
      'account.' + client.portalHost,
      endpointLogin,
    ),
    headers: {'content-type': 'application/json'},
    body: json.encode(data),
  );

  if (loginResponse.statusCode != 204) {
    throw 'HTTP ${loginResponse.statusCode}: ${loginResponse.body}';
  }

  final jwt = loginResponse.headers[JWT_HEADER_NAME]!.split(';').first;

  return jwt;
}

/**
 * Signs the given challenge.
 *
 * @param privateKey - The user's login private key.
 * @param challenge - The challenge received from the server.
 * @param challengeType - The type of the challenge.
 * @param portalRecipient - The portal we are communicating with.
 * @returns - The challenge response from the client.
 */
Future<ChallengeResponse> signChallenge(
  SimpleKeyPair keyPair,
  String challenge,
  String challengeType, // : "skynet-portal-login" | "skynet-portal-register",
  String portalRecipient,
) async {
  // validateHexString("challenge", challenge, "challenge from server");

  final challengeBytes = hex.decode(challenge);
  if (challengeBytes.length != CHALLENGE_SIZE) {
    throw 'Invalid challenge: wrong length';
  }

  final typeBytes = utf8.encode(challengeType);

  final portalBytes = utf8.encode(portalRecipient);

  final dataBytes =
      Uint8List.fromList([...challengeBytes, ...typeBytes, ...portalBytes]);

  final signatureBytes = await ed25519.sign(dataBytes, keyPair: keyPair);

  /* =
      sign(dataBytes, privateKeyBytes).slice(0, CHALLENGE_SIGNATURE_SIZE); */

  // validateUint8ArrayLen("signatureBytes", signatureBytes, "calculated signature", CHALLENGE_SIGNATURE_SIZE);

  return ChallengeResponse(
    response: hex.encode(dataBytes),
    signature: hex.encode(signatureBytes.bytes),
  );
}

class ChallengeResponse {
  final String response;
  final String signature;
  ChallengeResponse({required this.response, required this.signature});
}

/**
 * Generates a portal login keypair.
 *
 * @param seed - The user seed.
 * @param email - The email.
 * @returns - The login keypair.
 */
Future<SimpleKeyPair> genPortalLoginKeypair(
    Uint8List seed, String tweak) async {
  final hash = hashWithSalt(seed, tweak);

  return await genKeyPairFromHash(hash);
}

/**
 * Gets the portal recipient string from the portal URL, e.g. siasky.net =>
 * siasky.net, dev1.siasky.dev => siasky.dev.
 *
 * @param portalUrl - The full portal URL.
 * @returns - The shortened portal recipient name.
 */
String getPortalRecipient(String portalHost) {
  final parts = portalHost.split(".");

  // Get last two portions of the hostname.
  return 'https://' + parts.sublist(parts.length - 2, parts.length).join(".");
}
