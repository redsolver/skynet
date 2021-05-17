import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'data_with_revision.dart';
import 'registry_classes.dart';
import 'user.dart';
import 'client.dart';

import 'file.dart';

/* 
// FILEID_V1 represents version 1 of the FileID object
const FILEID_V1 = 1;

// FileType is the type of the file
enum FileType {
  Invalid, // 0 is invalid
  PublicUnencrypted,
}

extension FileTypeID on FileType {
  int toID() {
    if (this == FileType.PublicUnencrypted) {
      return 1;
    } else {
      return null;
    }
  }
} */

/* FileType getFileTypeFromID(int id) {
  if (id == 1) return FileType.PublicUnencrypted;

  throw Exception('Invalid file type (Not PublicUnencrypted)');
} */
// getFile will lookup the entry for given skappID and filename, if it exists it
// will try and download the file behind the skylink it has found in the entry.

Future<SkyFile> getFile(
  SkynetUser user,
  String datakey, {
  int timeoutInSeconds = 10,
  String? hashedDatakey,
  required SkynetClient skynetClient,
}) async {
  return (await getFileWithRevision(
    user,
    datakey,
    hashedDatakey: hashedDatakey,
    timeoutInSeconds: timeoutInSeconds,
    skynetClient: skynetClient,
  ))
      .data;
}

Future<DataWithRevision<SkyFile>> getFileWithRevision(
  SkynetUser user,
  String datakey, {
  int timeoutInSeconds = 10,
  String? hashedDatakey,
  required SkynetClient skynetClient,
}) async {
  // lookup the registry entry
  final existing = await skynetClient.registry.getEntry(
    user,
    datakey,
    timeoutInSeconds: timeoutInSeconds,
    hashedDatakey: hashedDatakey,
  );
  if (existing == null) {
    throw Exception('not found');
  }

  final skylink = String.fromCharCodes(existing.entry.data);

  // download the data in that Skylink
  final res = await skynetClient.httpClient.get(Uri.https(skynetClient.portalHost, '$skylink'));

  // TODO Check if response is ok

  // final metadata = json.decode(res.headers['skynet-file-metadata']!);

  return DataWithRevision(
    SkyFile(
        content: res.bodyBytes,
        // filename: metadata['filename'],
        type: res.headers['content-type']),
    existing.entry.revision,
  );
}

// setFile uploads a file and sets updates the registry
Future<bool> setFile(
  SkynetUser user,
  String datakey,
  SkyFile file, {
  String? hashedDatakey,
  required SkynetClient skynetClient,
}) async {
  // upload the file to acquire its skylink
  final skylink = await skynetClient.upload.uploadFile(file);

  if (skylink == null) {
    throw 'Upload failed';
  }

  SignedRegistryEntry? existing;

  try {
    // fetch the current value to find out the revision
    final res = await skynetClient.registry.getEntry(
      user,
      datakey,
      hashedDatakey: hashedDatakey,
    );

    existing = res;
  } catch (e) {
    existing = null;
  }

  // TODO: we could (/should?) verify here

  // build the registry value
  final rv = RegistryEntry(
    datakey: datakey,
    data: utf8.encode(skylink) as Uint8List,
    revision: (existing?.entry.revision ?? 0) + 1,
  );

  if (hashedDatakey != null) {
    rv.hashedDatakey = Uint8List.fromList(hex.decode(hashedDatakey));
  }

  // sign it
  final sig = await user.sign(rv.hash());

  final srv = SignedRegistryEntry(signature: sig, entry: rv);

  // update the registry
  final updated = await skynetClient.registry.setEntryRaw(
    user,
    datakey,
    srv,
    hashedDatakey: hashedDatakey,
  );

  return updated;
}

// FileID represents a File
/* class FileID { // TODO Remove
  final version = FILEID_V1;
  String applicationID;
  FileType fileType;
  String filename;

  FileID({this.applicationID, this.fileType, this.filename}) {
    // validate file type
    if (fileType != FileType.PublicUnencrypted) {
      throw Exception('invalid file type');
    }
  }

  Map toJson() => {
        'version': version,
        'applicationid': applicationID,
        'filetype': fileType.toID(),
        'filename': filename,
      };

  FileID.fromJson(Map m) {
    applicationID = m['applicationid'];
    fileType = getFileTypeFromID(m['filetype']);
    filename = m['filename'];
  }

  Uint8List toBytes() => Uint8List.fromList([
        ...withPadding(version),
        ...withPadding(applicationID.length),
        ...utf8.encode(applicationID), // ?
        ...[fileType.toID(), 0, 0, 0, 0, 0, 0, 0],
        ...withPadding(filename.length),
        ...utf8.encode(filename),
      ]);

  Uint8List hash() {
    return Blake2bHash.hashWithDigestSize(
      256,
      toBytes(),
    );
  }
} */
