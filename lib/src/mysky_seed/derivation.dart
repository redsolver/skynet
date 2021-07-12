import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'dictionary.dart';

const SEED_LENGTH = 16;
const SEED_WORDS_LENGTH = 13;
const CHECKSUM_WORDS_LENGTH = 2;
const PHRASE_LENGTH = SEED_WORDS_LENGTH + CHECKSUM_WORDS_LENGTH;

Uint8List deriveRootDiscoverableKeyFromPhrase(String phrase) {
  final seed = validatePhrase(phrase);

  return deriveRootDiscoverableKeyFromSeed(seed);
}

Uint8List deriveRootDiscoverableKeyFromSeed(Uint8List seed) {
  final s1 = sha512.convert(utf8.encode('root discoverable key')).bytes;
  final s2 = sha512.convert(seed).bytes;

  final bytes = sha512.convert([...s1, ...s2]).bytes.sublist(0, 32);

  return Uint8List.fromList(bytes);
}

String sanitizePhrase(String phrase) {
  // Remove duplicate adjacent spaces.
  return /* removeAdjacentChars( */ phrase.trim().toLowerCase(); /* , " "); */
}

Uint8List validatePhrase(String phrase) {
  phrase = sanitizePhrase(phrase);
  final phraseWords = phrase.split(' ');

  if (phraseWords.length != PHRASE_LENGTH) {
    throw 'Phrase must be 15 words long, was ${phraseWords.length}';
  }

  // Build the seed from words.
  final seedWords = Uint16List(SEED_WORDS_LENGTH);

  var i = 0;
  for (final word in phraseWords) {
    // print('word $word');
    // Check word length.
    if (word.length < 3) {
      throw 'Word ${i + 1} is not at least 3 letters long';
    }

    // Check word prefix.
    final prefix = word.substring(0, 3);
    var bound = dictionary.length;
    if (i == 12) {
      bound = 256;
    }
    var found = -1;
    for (var j = 0; j < bound; j++) {
      final curPrefix = dictionary[j].substring(0, 3);
      if (curPrefix == prefix) {
        found = j;
        break;
      }
      /* else if (curPrefix > prefix) {
        break;
      } */
    }
    if (found < 0) {
      if (i == 12) {
        throw 'Prefix for word ${i + 1} must be found in the first 256 words of the dictionary';
      } else {
        throw 'Unrecognized prefix "${prefix}" at word ${i + 1}, not found in dictionary';
      }
    }

    seedWords[i] = found;

    i++;
    if (i >= SEED_WORDS_LENGTH) break;
  }

  // Validate checksum.
  final checksumWords = generateChecksumWordsFromSeedWords(seedWords);
  for (var i = 0; i < CHECKSUM_WORDS_LENGTH; i++) {
    final prefix = dictionary[checksumWords[i]].substring(0, 3);
    if (phraseWords[i + SEED_WORDS_LENGTH].substring(0, 3) != prefix) {
      throw 'Word "${phraseWords[i + SEED_WORDS_LENGTH]}" is not a valid checksum for the seed';
    }
  }

  return seedWordsToSeed(seedWords);
}

/**
 * @param seedWords
 */
Uint16List generateChecksumWordsFromSeedWords(Uint16List seedWords) {
  if (seedWords.length != SEED_WORDS_LENGTH) {
    throw 'Input seed was not of length ${SEED_WORDS_LENGTH}';
  }

  final seed = seedWordsToSeed(seedWords);
  final h = Uint8List.fromList(sha512.convert(seed).bytes);
  final checksumWords = hashToChecksumWords(h);

  return checksumWords;
}

Uint16List hashToChecksumWords(Uint8List h) {
  var word1 = h[0] << 8;
  word1 += h[1];
  word1 >>= 6;
  var word2 = h[1] << 10;
  word2 &= 0xffff;
  word2 += h[2] << 2;
  word2 >>= 6;
  return Uint16List.fromList([word1, word2]);
}

Uint8List seedWordsToSeed(Uint16List seedWords) {
  if (seedWords.length != SEED_WORDS_LENGTH) {
    throw 'Input seed was not of length ${SEED_WORDS_LENGTH}';
  }

  // We are getting 16 bytes of entropy.
  final bytes = Uint8List(SEED_LENGTH);
  var curByte = 0;
  var curBit = 0;

  for (var i = 0; i < SEED_WORDS_LENGTH; i++) {
    final word = seedWords[i];
    var wordBits = 10;
    if (i == SEED_WORDS_LENGTH - 1) {
      wordBits = 8;
    }

    // Iterate over the bits of the 10- or 8-bit word.
    for (var j = 0; j < wordBits; j++) {
      final bitSet = (word & (1 << (wordBits - j - 1))) > 0;

      if (bitSet) {
        bytes[curByte] |= 1 << (8 - curBit - 1);
      }

      curBit += 1;
      if (curBit >= 8) {
        curByte += 1;
        curBit = 0;
      }
    }
  }

  return bytes;
}
