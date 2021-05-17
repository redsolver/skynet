import 'package:skynet/src/client.dart';
import 'package:skynet/src/skystandards/types.dart';

import 'package:tuple/tuple.dart';

const FEED_DAC_DOMAIN = "feed-dac.hns";

// TODO Limit
Stream<List<Post>> loadPostsForUser(String userId,
    {required SkynetClient skynetClient}) async* {
  /*    LoadingState state = LoadingState.loadMore;

enum LoadingState {
  idle,
  loadMore,
  done,
} */
/* 

void main() async {
  final ctrl = StreamController<Null>();
  loadPosts(8, ctrl.stream).listen((event) {
    print('Got page $event');
  });

  await Future.delayed(Duration(seconds: 3));
  state = LoadingState.loadMore;
  await Future.delayed(Duration(seconds: 3));
  state = LoadingState.done;
  await Future.delayed(Duration(seconds: 3));
} */

/* Stream<List<Post>> loadPosts(
    int minPageLength, Stream<Null> pageLoading) async* { */
  const minItemsPerPage = 8;

  if (userId.startsWith('ed25519-')) {
    userId = userId.substring(8);
  }

  final Map skappsMap =
      await skynetClient.file.getJSON(userId, '$FEED_DAC_DOMAIN/skapps.json');
  if (skappsMap.isEmpty) {
    yield [];
    // TODO state = LoadingState.done;
    return;
  }
  final skapps = skappsMap.keys.toList();

  final buffer = <Post>[];

  final skappPostBuffer = <Post>[];

  final skappTimestampLimit = <String, int>{};
  final skappCurrentPage = <String, int>{};
  final limitBeforePageEnd = <String, int>{};

  for (final skapp in List.from(skapps)) {
    final index =
        await skynetClient.file.getJSON(userId, '${FEED_DAC_DOMAIN}/${skapp}/posts/index.json');

    // print('[debug] [FeedDAC] $index');
    if (index == null) {
      /* final index = skapps.indexOf(skapp, 0);
        if (index > -1) { */
      skapps.remove(skapp);
      // }
    } else {
      skappTimestampLimit[skapp] = index['latestItemTimestamp'] ?? 0;
      skappCurrentPage[skapp] = index['currPageNumber'];
    }
  }

  final bool onlyOneSkapp = skapps.length == 1;

  String? nextSkapp;
  String? ignoreSkapp;
  int? currentLimit;

  // Select priority skapp

  while (true) {
    if (skappTimestampLimit.isEmpty) {
      break;
    }
    String currentSkapp;
    if (onlyOneSkapp) {
      currentSkapp = skapps.first;
    } else if (nextSkapp == null) {
      final highestLimit =
          _getLatestSkapp(skappTimestampLimit, exclude: ignoreSkapp);

      currentSkapp = highestLimit.item1;

      //print('highestLimit $highestLimit');
    } else {
      currentSkapp = nextSkapp;
    }

    final secondHighestLimit =
        _getLatestSkapp(skappTimestampLimit, exclude: currentSkapp);

    //print('secondHighestLimit $secondHighestLimit');

    final localLimitBeforePageEnd = limitBeforePageEnd[currentSkapp];

    if (localLimitBeforePageEnd == null ||
        currentLimit == null ||
        currentLimit <= localLimitBeforePageEnd) {
      if ((skappCurrentPage[currentSkapp] ?? -1) < 0) {
      } else {
        print(
            '[http] load page $currentSkapp.${skappCurrentPage[currentSkapp]}');
        final pageData = await skynetClient.file.getJSON(userId,
            '${FEED_DAC_DOMAIN}/${currentSkapp}/posts/page_${skappCurrentPage[currentSkapp]}.json');

        skappCurrentPage[currentSkapp] =
            (skappCurrentPage[currentSkapp] ?? 0) - 1;

        if (pageData == null) continue;

        final List<Post> posts =
            pageData['items'].map<Post>((m) => Post.fromJson(m)).toList();
        //

        limitBeforePageEnd[currentSkapp] = posts[0].ts ?? 0; // TODO Sort

        skappPostBuffer.addAll(posts);

        // skappCurrentPage[currentSkapp]--;
      }
    }

    skappPostBuffer.sort((a, b) => -(a.ts ?? 0).compareTo(b.ts ?? 0));

    ignoreSkapp = null;
    nextSkapp = null;

    while (skappPostBuffer.isNotEmpty) {
      final post = skappPostBuffer.first;
      skappTimestampLimit[currentSkapp] = post.ts ?? 0;
      currentLimit = post.ts;

      if ((post.ts ?? 0) < secondHighestLimit.item2) {
        nextSkapp = secondHighestLimit.item1;
        ignoreSkapp = currentSkapp;
        break;
      }

      buffer.add(post);

      skappPostBuffer.removeAt(0);
    }

    if (buffer.length >= minItemsPerPage) {
      // TODO state = LoadingState.idle;

      yield buffer;
      buffer.clear();
      /* TODO while (state == LoadingState.idle) {
        await Future.delayed(Duration(milliseconds: 20));
      }
      if (state == LoadingState.done) {
        return;
      } */
    }

    if (skappPostBuffer.isEmpty) {
      skappTimestampLimit[currentSkapp] =
          (skappTimestampLimit[currentSkapp] ?? 0) - 1;

      if ((skappCurrentPage[currentSkapp] ?? -1) < 0) {
        skappCurrentPage.remove(currentSkapp);
        skappTimestampLimit.remove(currentSkapp);
      }
    }
  }
  yield buffer;
  print('Reached end of all posts.');
// TODO  state = LoadingState.done;
}

Tuple2<String, int> _getLatestSkapp(
  Map<String, int> limitMap, {
  String? exclude,
}) {
  int maxLimit = 0;
  String maxSkapp = '';
  for (final skapp in limitMap.keys) {
    if (skapp == exclude) continue;

    final limit = limitMap[skapp] ?? 0;

    if (limit > maxLimit) {
      maxLimit = limit;
      maxSkapp = skapp;
    }
  }
  return Tuple2(maxSkapp, maxLimit);
}
