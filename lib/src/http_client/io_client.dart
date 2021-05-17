import 'package:http/http.dart';
import 'package:http/io_client.dart';

/// Create an [IOClient].
///
/// Used from conditional imports, matches the definition in `client_stub.dart`.
BaseClient createClient() => IOClient();
