import 'package:skynet/src/client.dart';

/**
 * The response to a pin request.
 *
 * @property skylink - 46-character skylink.
 */
class PinResponse {
  String skylink;
  PinResponse(this.skylink);
}

/**
 * Re-pins the given skylink.
 *
 * @param this - SkynetClient
 * @param skylinkUrl - 46-character skylink, or a valid skylink URL.
 * @param [customOptions] - Additional settings that can optionally be set.
 * @returns - The returned JSON and revision number.
 * @throws - Will throw if the returned signature does not match the returned entry, or if the skylink in the entry is invalid.
 */
Future<PinResponse> pinSkylink(
  String skylink, {
  required SkynetClient skynetClient,
}) async {
  // final skylink = validateSkylinkString("skylinkUrl", skylinkUrl, "parameter");

  // const opts = { ...defaultPinOptions, ...this.customOptions, ...customOptions };

  // Don't include the path since the endpoint doesn't support it.
  // const path = parseSkylink(skylinkUrl, { onlyPath: true });
  /* if (path) {
    throw new Error("Skylink string should not contain a path");
  } */

  final res = await skynetClient.httpClient.post(
    Uri.https(skynetClient.portalHost, '/skynet/pin/${skylink}'),
    headers: skynetClient.headers,
  );

  if (res.statusCode != 200) {
    throw 'HTTP ${res.statusCode}: ${res.body}';
  }

  // Sanity check.
  // validatePinResponse(response);

  // Get the skylink.
  final returnedSkylink = res.headers["skynet-skylink"]!;

  // Format the skylink.
  // returnedSkylink = formatSkylink(returnedSkylink);

  return PinResponse(returnedSkylink);
}

/**
 * Validates the pin response.
 *
 * @param response - The pin response.
 * @throws - Will throw if not a valid pin response.
 */
/* function validatePinResponse(response: AxiosResponse): void {
  try {
    if (!response.headers) {
      throw new Error("response.headers field missing");
    }

    validateString('response.headers["skynet-skylink"]', response.headers["skynet-skylink"], "pin response field");
  } catch (err) {
    throw new Error(
      `Did not get a complete pin response despite a successful request. Please try again and report this issue to the devs if it persists. ${err}`
    );
  }
} */
