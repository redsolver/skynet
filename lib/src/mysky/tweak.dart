import 'dart:convert';
import 'dart:typed_data';

import 'package:skynet/src/blake2b/blake2b_hash.dart';

const discoverableBucketTweakVersion = 1;

class DiscoverableBucketTweak {
  late int version;
  late List<Uint8List> path;

  DiscoverableBucketTweak(String path) {
    final paths = path.split('/');

    final pathHashes = paths.map(hashPathComponent).toList();
    version = discoverableBucketTweakVersion;
    this.path = pathHashes;
  }

  Uint8List encode() {
    final size = 1 + 32 * path.length;
    final buf = new Uint8List(size);

    buf[0] = this.version;
    var offset = 1;
    for (final pathLevel in this.path) {
      copy(buf, offset, pathLevel);

      offset += 32;
    }
    return buf;
  }

  Uint8List getHash() {
    final encoding = this.encode();
    //  return hashAll(encoding);
    return Blake2bHash.hashWithDigestSize(
      256,
      encoding,
    );
  }
}

/* export function splitPath(path: string): Array<string> {
  return path.split("/");
} */
void copy(Uint8List list, int index, Uint8List copy) {
  for (final part in copy) {
    list[index] = part;
    index++;
  }
}

Uint8List hashPathComponent(String component) {
  return Blake2bHash.hashWithDigestSize(
    256,
    Uint8List.fromList(utf8.encode(component)),
  );
}

Uint8List deriveDiscoverableTweak(String path) {
  final dbt = DiscoverableBucketTweak(path);
  return dbt.getHash();
}
