import 'dart:convert';
import 'dart:typed_data';

import 'package:chia_utils/chia_crypto_utils.dart';
import 'package:chia_utils/src/utils/serialization.dart';

class PoolState with ToBytesChiaMixin {
  PoolState({
    required this.version,
    required this.poolSingletonState,
    required this.targetPuzzlehash,
    required this.ownerPublicKey,
    this.poolUrl,
    required this.relativeLockHeight,
  });

  final int version;
  final PoolSingletonState poolSingletonState;
  final Puzzlehash targetPuzzlehash;
  final JacobianPoint ownerPublicKey;
  final String? poolUrl;
  final int relativeLockHeight;

  @override
  Bytes toBytesChia() {
    var bytes = <int>[];
    bytes += intTo8Bytes(version);
    bytes += intTo8Bytes(poolSingletonState.code);
    bytes += targetPuzzlehash;
    bytes += ownerPublicKey.toBytes();
    if (poolUrl != null) {
      bytes += [1, ...serializeItem(poolUrl)];
    } else {
      bytes += [0];
    }
    bytes += intTo32Bytes(relativeLockHeight);
    return Bytes(bytes);
  }

  factory PoolState.fromBytesChia(Bytes bytes) {
    final iterator = bytes.toList().iterator;
    final versionBytes = iterator.extractBytesAndAdvance(1);
    final version = bytesToInt(versionBytes, Endian.big);

    final poolSingletonStateBytes = iterator.extractBytesAndAdvance(1);
    final poolSingletonState =
        codeToPoolSingletonState(bytesToInt(poolSingletonStateBytes, Endian.big));

    final targetPuzzlehash = Puzzlehash.fromStream(iterator);
    final ownerPublicKey = JacobianPoint.fromStreamG1(iterator);

    String? poolUrl;

    final poolUrlIsPresentBytes = iterator.extractBytesAndAdvance(1);
    if (poolUrlIsPresentBytes[0] == 1) {
      final lengthBytes = iterator.extractBytesAndAdvance(4);
      final poolUrlBytes = iterator.extractBytesAndAdvance(bytesToInt(lengthBytes, Endian.big));
      poolUrl = utf8.decode(poolUrlBytes);
    } else if (poolUrlIsPresentBytes[0] != 0) {
      throw ArgumentError('invalid isPresent bytes');
    }
    final relativeLockHeightBytes = iterator.extractBytesAndAdvance(4);
    final relativeLockHeight = bytesToInt(relativeLockHeightBytes, Endian.big);

    return PoolState(
      version: version,
      poolSingletonState: poolSingletonState,
      targetPuzzlehash: targetPuzzlehash,
      ownerPublicKey: ownerPublicKey,
      poolUrl: poolUrl,
      relativeLockHeight: relativeLockHeight,
    );
  }
}

enum PoolSingletonState {
  selfPooling,
  leavingPool,
  farmingToPool,
}

extension PoolSingletonStateCode on PoolSingletonState {
  int get code {
    switch (this) {
      case PoolSingletonState.selfPooling:
        return 1;
      case PoolSingletonState.leavingPool:
        return 2;
      case PoolSingletonState.farmingToPool:
        return 3;
    }
  }
}

PoolSingletonState codeToPoolSingletonState(int code) {
  switch (code) {
    case 1:
      return PoolSingletonState.selfPooling;
    case 2:
      return PoolSingletonState.leavingPool;
    case 3:
      return PoolSingletonState.farmingToPool;
    default:
      throw ArgumentError('Invalid PoolSingletonState code');
  }
}
