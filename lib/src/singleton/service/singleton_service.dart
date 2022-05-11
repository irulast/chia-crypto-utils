// ignore_for_file: lines_longer_than_80_chars

import 'dart:typed_data';

import 'package:chia_utils/chia_crypto_utils.dart';
import 'package:chia_utils/src/core/service/base_wallet.dart';
import 'package:chia_utils/src/singleton/puzzles/p2_singleton_or_delayed_puzhash/p2_singleton_or_delayed_puzhash.clvm.hex.dart';
import 'package:chia_utils/src/singleton/puzzles/singleton_launcher/singleton_launcher.clvm.hex.dart';
import 'package:chia_utils/src/singleton/puzzles/singleton_top_layer/singleton_top_layer.clvm.hex.dart';
import 'package:chia_utils/src/singleton/puzzles/singleton_top_layer_v1_1/singleton_top_layer_v1_1.clvm.hex.dart';

class SingletonService extends BaseWalletService {
  static Program puzzleForSingleton(
    Bytes launcherId,
    Program innerPuzzle,
  ) =>
      singletonTopLayerProgram.curry([
        Program.cons(
          Program.fromBytes(singletonTopLayerProgram.hash()),
          Program.cons(
            Program.fromBytes(launcherId),
            Program.fromBytes(singletonLauncherProgram.hash()),
          ),
        ),
        innerPuzzle
      ]);
  static Program makeSingletonStructureProgram(Bytes coinId) => Program.cons(
        Program.fromBytes(singletonTopLayerV1Program.hash()),
        Program.cons(
          Program.fromBytes(coinId),
          Program.fromBytes(singletonLauncherProgram.hash()),
        ),
      );

  static Program makeSingletonLauncherSolution(int amount, Puzzlehash puzzlehash) => Program.list([
        Program.fromBytes(puzzlehash),
        Program.fromInt(amount),
        Program.fromBytes(List.filled(128, 0)),
      ]);

  static Program createP2SingletonPuzzle({
    required Bytes singletonModHash,
    required Bytes launcherId,
    required int secondsDelay,
    required Puzzlehash delayedPuzzlehash,
  }) {
    return p2SingletonOrDelayedPuzhashProgram.curry([
      Program.fromBytes(singletonModHash),
      Program.fromBytes(launcherId),
      Program.fromBytes(singletonLauncherProgram.hash()),
      Program.fromBytes(intToBytesStandard(secondsDelay, Endian.big)),
      Program.fromBytes(delayedPuzzlehash),
    ]);
  }
}