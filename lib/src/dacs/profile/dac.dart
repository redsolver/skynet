import 'dart:async';
import 'dart:convert';

import 'package:skynet/src/client.dart';

import 'package:skynet/src/skystandards/profile.dart';
import 'package:skynet/src/skystandards/types.dart';

import 'package:skynet/src/user.dart';

import '../../crypto.dart';

const DAC_DOMAIN = "profile-dac.hns";
const VERSION = 1;
const PROFILE_INDEX_PATH = '$DAC_DOMAIN/profileIndex.json';
const PREFERENCES_INDEX_PATH = '$DAC_DOMAIN/preferencesIndex.json';

class ProfileDAC /* extends DAC */ {
  final SkynetClient skynetClient;
  ProfileDAC(this.skynetClient);

  final profileCache = <String, Profile>{};

  final currentlyLoadingProfiles = <String, Completer<Profile?>>{};

  Future<Profile?> getProfile(String userId) async {
    if (userId == null) {
      return Profile(
        username: 'Anonymous',
        version: 1,
      );
    }
    if (profileCache.containsKey(userId)) return profileCache[userId];

    if (currentlyLoadingProfiles.containsKey(userId)) {
      if (!currentlyLoadingProfiles[userId]!.isCompleted) {
        return currentlyLoadingProfiles[userId]!.future;
      }
    }
    var completer = Completer<Profile?>();

    currentlyLoadingProfiles[userId] = completer;

    var lastSkapp = await skynetClient.file.getJSON(userId, PROFILE_INDEX_PATH);

    if (lastSkapp != null) {
      if (lastSkapp['profile'] != null) {
        final profile = Profile.fromJson(lastSkapp['profile']);
        profileCache[userId] = profile;
        completer.complete(profile);
        return profile;
      }
    }

    completer.complete(null);
    return null;

    // TODO Use `profile-dac.hns/profileIndex.json` #profile directly
    if (lastSkapp != null && lastSkapp['lastUpdatedBy'] != null) {
      lastSkapp = lastSkapp['lastUpdatedBy'];
      final LATEST_PROFILE_PATH = '$DAC_DOMAIN/$lastSkapp/userprofile.json';
      final profileData =
          await skynetClient.file.getJSON(userId, LATEST_PROFILE_PATH);
      if (profileData != null) {
        final profile = Profile.fromJson(profileData);
        profileCache[userId] = profile;
        completer.complete(profile);
        return profile;
      }
    }
    // ! Fallback to SkyID

    try {
      final entry = await skynetClient.registry.getEntry(
        SkynetUser.fromId(userId),
        'profile',
      );

      if (entry != null) {
        final skylink = decodeSkylinkFromRegistryEntry(entry.entry.data);

        // download the data in that Skylink
        final res = await skynetClient.httpClient.get(
          Uri.https(skynetClient.portalHost, '$skylink'),
          headers: skynetClient.headers,
        );

        var data = json.decode(res.body);
        if (data is String) {
          data = json.decode(data);
        }

        final profile = Profile(
          version: 1,
          username: data['username'],
          aboutMe: data['aboutMe'] ?? '',
          location: data['location'] ?? '',
          avatar: [
            data['avatar'] == null
                ? Image(
                    ext: 'png',
                    url: 'sia://CABdyKgcVLkjdsa0HIjBfNicRv0pqU7YL-tgrfCo23DmWw',
                    h: 120,
                    w: 120,
                  )
                : Image(
                    ext: 'png',
                    url: 'sia://${data['avatar']}/150',
                    h: 150,
                    w: 150,
                  )
          ],
        );
        profileCache[userId] = profile;
        completer.complete(profile);
        return profile;
      }
    } catch (e, st) {
      print('[ProfileDAC/SkyID] $e: $st');
    }

    completer.complete(null);
    return null;
  }
}
