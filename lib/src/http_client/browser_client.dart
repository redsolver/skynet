import 'package:http/browser_client.dart';
import 'package:http/http.dart';

/// Create a [BrowserClient].
///
/// Used from conditional imports, matches the definition in `client_stub.dart`.
BaseClient createClient(bool withCredentials) => BrowserClient()..withCredentials = withCredentials;
