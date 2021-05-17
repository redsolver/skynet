@JS('skynet')
library skynet;

import 'package:js/js.dart';

@JS('SkynetClient')
class JSSkynetClient {
  external JSSkynetClient(String portal);
  external File get file;
  external Future<JSMySky> loadMySky(String dataDomain,
      [CustomConnectorOptions options]);
}

@JS()
@anonymous
class CustomConnectorOptions {
/*   dev?: boolean;
  debug?: boolean;
  handshakeMaxAttempts?: number;
  handshakeAttemptsInterval?: number; */

  external bool get dev;
  external bool get debug;
  external int get handshakeMaxAttempts;
  external int get handshakeAttemptsInterval;

  external factory CustomConnectorOptions({
    bool dev,
    bool debug,
    int handshakeMaxAttempts,
    int handshakeAttemptsInterval,
  });
}

@JS('MySky')
class JSMySky {
  external Future<bool> checkLogin();
  external Future<String> userID();

  // external List<DacLibrary>

  // TODO dacs: DacLibrary[];
  // TODO external List<Permission> get grantedPermissions;
  // TODO external List<Permission> get pendingPermissions;

  /**
     * Loads the given DACs.
     */
  external Future<void> loadDacs(dac1);

  // TODO addPermissions(...permissions: Permission[]): Promise<void>;

  /**
     * Destroys the mysky connection by:
     *
     * 1. Destroying the connected DACs,
     *
     * 2. Closing the connection,
     *
     * 3. Closing the child iframe
     */
  external Future<void> destroy();
  external Future<void> logout();
  external Future<bool> requestLoginAccess();

  external Future<JSJSONResponse> getJSON(
    String path,
    /* opts?: CustomGetJSONOptions */
  );
  external Future<dynamic> setJSON(
    String path,
    dynamic json,
    /*  CustomSetJSONOptions opts */
  );
}

@JS()
class File {
  @JS('getJSON')
  external Future<String> getJSON(String userId, String path);
}

@JS('JSONResponse')
class JSJSONResponse {
  external get data;
  external String get skylink;
}

@JS()
@anonymous
class JsonData {}
