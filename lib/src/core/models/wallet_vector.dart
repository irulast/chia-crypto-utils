// ignore_for_file: lines_longer_than_80_chars

import 'dart:typed_data';

import 'package:chia_utils/chia_crypto_utils.dart';
import 'package:meta/meta.dart';

@immutable
class WalletVector with ToBytesMixin {
  const WalletVector({
    required this.childPrivateKey,
    required this.childPublicKey,
    required this.puzzlehash,
  });

  factory WalletVector.fromBytes(Uint8List bytes) {
    var length = bytes[0];
    var left = 1;
    var right = left + length;

    final childPrivateKey = PrivateKey.fromBytes(bytes.sublist(left, right));

    length = bytes[right];
    left = right + 1;
    right = left + length;
    final childPublicKey = JacobianPoint.fromBytes(
      bytes.sublist(left, right),
      bytes[right] == 1,
    );

    length = bytes[right + 1];
    left = right + 2;
    right = left + length;

    final puzzlehash = Puzzlehash(bytes.sublist(left, right));

    return WalletVector(
      childPrivateKey: childPrivateKey,
      childPublicKey: childPublicKey,
      puzzlehash: puzzlehash,
    );
  }

  final PrivateKey childPrivateKey;
  final JacobianPoint childPublicKey;
  final Puzzlehash puzzlehash;

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      childPrivateKey.hashCode ^
      childPublicKey.hashCode ^
      puzzlehash.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WalletVector &&
            runtimeType == other.runtimeType &&
            childPrivateKey == other.childPrivateKey &&
            childPublicKey == other.childPublicKey &&
            puzzlehash == other.puzzlehash;
  }

  @override
  Uint8List toBytes() {
    final childPrivateKeyBytes = childPrivateKey.toBytes();
    final childPublicKeyBytes = childPublicKey.toBytes();
    final puzzlehashBytes = puzzlehash.toBytes();

    return Uint8List.fromList([
      childPrivateKeyBytes.length,
      ...childPrivateKeyBytes,
      childPublicKeyBytes.length,
      ...childPublicKeyBytes,
      if (childPublicKey.isExtension) 1 else 0,
      puzzlehashBytes.length,
      ...puzzlehashBytes,
    ]);
  }
}

class UnhardenedWalletVector extends WalletVector {
  UnhardenedWalletVector({
    required PrivateKey childPrivateKey,
    required JacobianPoint childPublicKey,
    required Puzzlehash puzzlehash,
    Map<Puzzlehash, Puzzlehash>? assetIdtoOuterPuzzlehash,
  })  : assetIdtoOuterPuzzlehash =
            assetIdtoOuterPuzzlehash ?? <Puzzlehash, Puzzlehash>{},
        super(
          childPrivateKey: childPrivateKey,
          childPublicKey: childPublicKey,
          puzzlehash: puzzlehash,
        );

  final Map<Puzzlehash, Puzzlehash> assetIdtoOuterPuzzlehash;
}