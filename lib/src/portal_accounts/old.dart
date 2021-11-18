import 'dart:convert';

import 'package:http/http.dart';
import 'package:skynet/skynet.dart';
import 'package:html/parser.dart' as parser;
import 'package:client_cookie/client_cookie.dart';

class PortalSession {
  final SkynetClient skynetClient;

  PortalSession(this.skynetClient);

  String? sessionKey;
  String? ory_kratos_session;
  Future<void> createPortalSession(String username, String password) async {
   
    final portalAccountLoginUrl = Uri.parse(
        'https://account.siasky.net/.ory/kratos/public/self-service/login/browser');
    

    final cs = CookieStore();

    final request = Request('GET', portalAccountLoginUrl)
      ..followRedirects = false;
    var loginPageResponse = await skynetClient.httpClient.send(request);

    cs.addFromHeader(loginPageResponse.headers['set-cookie']);

    final response = await skynetClient.httpClient.get(
      Uri.parse(loginPageResponse.headers['location']!),
      headers: {
        'cookie': cs.toReqHeader,
      },
    );
    cs.addFromResponse(response);

    final doc = parser.parse(response.body);

    final form = doc.getElementsByTagName('form').first;

    final csrf = doc
        .getElementsByTagName('input')
        .firstWhere((element) => element.attributes['name'] == 'csrf_token')
        .attributes['value'];

    final submitUrl = Uri.parse(form.attributes['action']!);

    final loginRequest = Request('POST', submitUrl)..followRedirects = false;

    loginRequest.headers.addAll(
      {
        'cookie': cs.toReqHeader,
      },
    );

    loginRequest.bodyFields = {
      'identifier': username,
      'password': password,
      'csrf_token': csrf!,
    };

    var loginResponse = await skynetClient.httpClient.send(loginRequest);

    cs.addFromHeader(loginResponse.headers['set-cookie']);

    cs.cookieMap.remove('csrf_token');

    if (!cs.cookieMap.containsKey('ory_kratos_session')) {
      throw 'Invalid credentials';
    }
    ory_kratos_session = cs.cookieMap['ory_kratos_session']!.value;

    final redirectRequest = Request(
      'GET',
      Uri.parse(
        'https://account.siasky.net/api/accounts/login?return_to=/', //loginResponse.headers['location']!,
      ),
    )..followRedirects = false;

    redirectRequest.headers.addAll(
      {
        'cookie': cs.toReqHeader,
      },
    );

    var redirectResponse = await skynetClient.httpClient.send(redirectRequest);

    cs.addFromHeader(redirectResponse.headers['set-cookie']);

    sessionKey = cs.cookieMap['skynet-jwt']!.value;

    print('sessionKey $sessionKey');

  }

  Future<bool> verifyPortalSession() async {
    final response = await skynetClient.httpClient.get(
        Uri.parse(
          'https://${skynetClient.portalHost}/__internal/do/not/use/authenticated',
        ),
        headers: {'cookies': 'skynet-jwt=${sessionKey}'});
        
    final data = json.decode(response.body);

    return data['authenticated'];
  }

  Future<void> setPortalSession(String $sessionKey) async {
    sessionKey = $sessionKey;
    if (!(await verifyPortalSession())) {
      throw Exception('There was a problem authenticating with the portal.');
    }
  }
}
