import 'package:skynet/src/client.dart';

abstract class DAC {
  dynamic get $internalObject => null;
  final SkynetClient skynetClient;
  DAC(this.skynetClient);
}
