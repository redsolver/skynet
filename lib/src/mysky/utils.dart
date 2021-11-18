/**
 * Extracts the domain from the current portal URL,
 * e.g. ("dac.hns.siasky.net") => "dac.hns"
 *
 * @param this - SkynetClient
 * @param fullDomain - Full URL.
 * @returns - The extracted domain.
 */
/*  Future<String> extractDomain(this: SkynetClient, String fullDomain) async {
  const portalUrl = await this.portalUrl();

  return extractDomainForPortal(portalUrl, fullDomain);
} */

import 'dart:html';

/**
 * Create a new popup window. From SkyID.
 *
 * @param url - The URL to open.
 * @param winName - The name of the popup window.
 * @param w - The width of the popup window.
 * @param h - the height of the popup window.
 * @returns - The window.
 * @throws - Will throw if the window could not be opened.
 */
WindowBase popupCenter(String url, String winName, int w, int h) {
  if (window.top == null) {
    throw "Current window is not valid";
  }

  final y = window.outerHeight / 2 + window.screenY! - h / 2;
  final x = window.outerWidth / 2 + window.screenX! - w / 2;

  final newWindow = window.open(
    url,
    winName,
    'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, copyhistory=no, width=${w}, height=${h}, top=${y}, left=${x}',
  );
  if (newWindow == null) {
    throw "Could not open window";
  }

  /* if (newWindow.focus) {
    newWindow.focus();
  } */
  return newWindow;
}
