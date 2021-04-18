@JS('skynet')
library skynet;

// import 'dart:js';

import 'package:js/js.dart';

// The `Map` constructor invokes JavaScript `new google.maps.Map(location)`
@JS('SkynetClient')
class JSSkynetClient {
  external JSSkynetClient(String portal);
  external File get file;
  external Future<JSMySky> loadMySky(String dataDomain);
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
  external Future<void> loadDacs(dacs);

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
  external Future<JSJSONResponse> setJSON(
    String path,
    JsonData json,
    /*  CustomSetJSONOptions opts */
  );
  /*   protected catchError(errorMsg: string): Promise<void>;
    protected launchUI(): Promise<Window>;
    protected connectUi(childWindow: Window): Promise<Connection>;
    protected loadDac(dac: DacLibrary): Promise<void>;
    protected handleLogin(loggedIn: boolean): void;
    protected signRegistryEntry(entry: RegistryEntry, path: string): Promise<Signature>; */
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

/* @JS()
@anonymous
class JsonData extends Map {} */

@JS()
@anonymous
class JsonData {}

// The `Location` constructor invokes JavaScript `new google.maps.LatLng(...)`
//
// We recommend against using custom JavaScript names whenever
// possible. It is easier for users if the JavaScript names and Dart names
// are consistent.
/* @JS('LatLng')
class Location {
  external Location(num lat, num lng);
} */
/// A workaround to converting an object from JS to a Dart Map.
/* Map jsToMap(jsObject) {
  return new Map.fromIterable(
    _getKeysOfObject(jsObject),
    value: (key) => getProperty(jsObject, key),
  );
}

// Both of these interfaces exist to call `Object.keys` from Dart.
//
// But you don't use them directly. Just see `jsToMap`.
@JS('Object.keys')
external List<String> _getKeysOfObject(jsObject);
 */
