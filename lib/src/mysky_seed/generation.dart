import 'dart:math';
import 'dart:typed_data';

import 'derivation.dart';
import 'dictionary.dart';

String generatePhrase() {
  final seedWords = Uint16List(SEED_WORDS_LENGTH);

  final random = Random.secure();
  // window.crypto.getRandomValues(seedWords);

  // Populate the seed words from the random values.
  for (var i = 0; i < SEED_WORDS_LENGTH; i++) {
    seedWords[i] = random.nextInt(1 << 16);

    var numBits = 10;
    // For the 13th word, only the first 256 words are considered valid.
    if (i == 12) {
      numBits = 8;
    }
    seedWords[i] = seedWords[i] % (1 << numBits);
  }

  // Generate checksum from hash of the seed.
  final checksumWords = generateChecksumWordsFromSeedWords(seedWords);

  final phraseWords = List<String>.filled(PHRASE_LENGTH, '');

  for (var i = 0; i < SEED_WORDS_LENGTH; i++) {
    phraseWords[i] = dictionary[seedWords[i]];
  }
  for (var i = 0; i < CHECKSUM_WORDS_LENGTH; i++) {
    phraseWords[i + SEED_WORDS_LENGTH] = dictionary[checksumWords[i]];
  }

  return phraseWords.join(" ");
}
