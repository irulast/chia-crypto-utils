import 'package:chia_utils/chia_crypto_utils.dart';
import 'package:chia_utils/src/core/service/base_wallet.dart';
import 'package:chia_utils/src/pool/models/pool_state.dart';
import 'package:chia_utils/src/pool/puzzles/pool_member_inner_puz/pool_member_innerpuz.clvm.hex.dart';
import 'package:chia_utils/src/pool/puzzles/pool_waitingroom_innerpuz/pool_waitingroom_innerpuz.clvm.hex.dart';
import 'package:chia_utils/src/singleton/puzzles/singleton_launcher/singleton_launcher.clvm.hex.dart';
import 'package:chia_utils/src/singleton/puzzles/singleton_top_layer/singleton_top_layer.clvm.hex.dart';
import 'package:chia_utils/src/singleton/service/singleton_service.dart';

class PoolWalletService extends BaseWalletService {
  final standardWalletService = StandardWalletService();

  SpendBundle createPoolNftSpendBundle({
    required PoolState initialTargetState,
    required WalletKeychain keychain,
    required List<CoinPrototype> coins,
    Bytes? originId,
    int fee = 0,
    int p2SingletonDelayTime = 604800,
    required Puzzlehash p2SingletonDelayedPuzzlehash,
    Puzzlehash? changePuzzlehash,
  }) {
    final launcherParentId = originId ?? coins[0].id;
    final launcherSpendBundle = createLauncherSpendBundle(
      originId: launcherParentId,
      coins: coins,
      amount: 1,
      initialTargetState: initialTargetState,
      delayTime: p2SingletonDelayTime,
      delayPuzzlehash: p2SingletonDelayedPuzzlehash,
      keychain: keychain,
      changePuzzlehash: changePuzzlehash,
      fee: fee,
    );

    return launcherSpendBundle;
  }

  SpendBundle createLauncherSpendBundle({
    required Bytes originId,
    required List<CoinPrototype> coins,
    required int amount,
    int fee = 0,
    required PoolState initialTargetState,
    required int delayTime,
    required Puzzlehash delayPuzzlehash,
    required WalletKeychain keychain,
    Puzzlehash? changePuzzlehash,
  }) {
    final launcherParent = coins.singleWhere((coin) => coin.id == originId);
    final genesisLauncherPuzzle = singletonLauncherProgram;
    final launcherCoin = CoinPrototype(
      parentCoinInfo: launcherParent.id,
      puzzlehash: genesisLauncherPuzzle.hash(),
      amount: amount,
    );

    final escapingInnerPuzzle = createWaitingRoomInnerPuzzle(
      targetPuzzlehash: initialTargetState.targetPuzzlehash,
      relativeLockHeight: initialTargetState.relativeLockHeight,
      ownerPublicKey: initialTargetState.ownerPublicKey,
      launcherId: launcherCoin.id,
      delayTime: delayTime,
      delayPuzzlehash: delayPuzzlehash,
    );
    final escapingInnerPuzzlehash = escapingInnerPuzzle.hash();

    final selfPoolingInnerPuzzle = createPoolingInnerPuzzle(
      targetPuzzlehash: initialTargetState.targetPuzzlehash,
      poolWaitingRoomInnerHash: escapingInnerPuzzlehash,
      ownerPublicKey: initialTargetState.ownerPublicKey,
      launcherId: launcherCoin.id,
      delayTime: delayTime,
      delayPuzzlehash: delayPuzzlehash,
    );

    late Program puzzle;
    if (initialTargetState.poolSingletonState == PoolSingletonState.selfPooling) {
      puzzle = escapingInnerPuzzle;
    } else if (initialTargetState.poolSingletonState == PoolSingletonState.farmingToPool) {
      puzzle = selfPoolingInnerPuzzle;
    } else {
      throw ArgumentError('invalid initial state');
    }
    final fullPoolingPuzzle = SingletonService.puzzleForSingleton(launcherCoin.id, puzzle);
    final puzzlehash = fullPoolingPuzzle.hash();
    final poolStateBytes = makePoolExtraData(initialTargetState, delayTime, delayPuzzlehash);

    final announcementMessage =
        Program.list([Program.fromBytes(puzzlehash), Program.fromInt(amount), poolStateBytes])
            .hash();
    final assertCoinAnnouncement =
        AssertCoinAnnouncementCondition(launcherCoin.id, announcementMessage);

    final createLauncherSpendBundle = standardWalletService.createSpendBundle(
      payments: [Payment(amount, genesisLauncherPuzzle.hash())],
      coinsInput: coins,
      keychain: keychain,
      changePuzzlehash: changePuzzlehash,
      originId: launcherParent.id,
      fee: fee,
      coinAnnouncementsToAssert: [assertCoinAnnouncement],
    );

    final genesisLauncherSolution = Program.list([
      Program.fromBytes(puzzlehash),
      Program.fromInt(amount),
      poolStateBytes,
    ]);

    final launcherCoinSpend = CoinSpend(
      coin: launcherCoin,
      puzzleReveal: genesisLauncherPuzzle,
      solution: genesisLauncherSolution,
    );

    final launcherSpendBundle = SpendBundle(coinSpends: [launcherCoinSpend]);

    return createLauncherSpendBundle + launcherSpendBundle;
  }

  Program makePoolExtraData(PoolState poolState, int delayTime, Puzzlehash delayPuzzlehash) =>
      Program.list([
        Program.cons(Program.fromString('p'), Program.fromBytes(poolState.toBytesChia())),
        Program.cons(Program.fromString('t'), Program.fromInt(delayTime)),
        Program.cons(Program.fromString('h'), Program.fromBytes(delayPuzzlehash)),
      ]);

  Program createWaitingRoomInnerPuzzle({
    required Puzzlehash targetPuzzlehash,
    required int relativeLockHeight,
    required JacobianPoint ownerPublicKey,
    required Bytes launcherId,
    required int delayTime,
    required Puzzlehash delayPuzzlehash,
  }) {
    final p2SingletonPuzzlehash = launcherIdToP2Puzzlehash(launcherId, delayTime, delayPuzzlehash);
    return poolWaitingRoomInnerpuzProgram.curry([
      Program.fromBytes(targetPuzzlehash),
      Program.fromBytes(p2SingletonPuzzlehash),
      Program.fromBytes(ownerPublicKey.toBytes()),
      Program.fromBytes(poolRewardPrefix),
      Program.fromInt(delayTime),
    ]);
  }

  Program createPoolingInnerPuzzle({
    required Puzzlehash targetPuzzlehash,
    required Puzzlehash poolWaitingRoomInnerHash,
    required JacobianPoint ownerPublicKey,
    required Bytes launcherId,
    required int delayTime,
    required Puzzlehash delayPuzzlehash,
  }) {
    final p2SingletonPuzzlehash = launcherIdToP2Puzzlehash(launcherId, delayTime, delayPuzzlehash);
    return poolMemberInnerpuzProgram.curry([
      Program.fromBytes(targetPuzzlehash),
      Program.fromBytes(p2SingletonPuzzlehash),
      Program.fromBytes(ownerPublicKey.toBytes()),
      Program.fromBytes(poolRewardPrefix),
      Program.fromBytes(poolWaitingRoomInnerHash),
    ]);
  }

  Bytes get poolRewardPrefix =>
      Bytes.fromHex(blockchainNetwork.aggSigMeExtraData).sublist(0, 16) + Bytes(List.filled(16, 0));

  Puzzlehash launcherIdToP2Puzzlehash(
      Bytes launcherId, int secondsDelay, Puzzlehash delayedPuzzlehash) {
    return SingletonService.createP2SingletonPuzzle(
      singletonModHash: singletonTopLayerProgram.hash(),
      launcherId: launcherId,
      secondsDelay: secondsDelay,
      delayedPuzzlehash: delayedPuzzlehash,
    ).hash();
  }

  static PoolState? coinSpendToPoolState(CoinSpend coinSpend) {
    final fullSolution = coinSpend.solution;

    // check for launcher spend
    if (coinSpend.coin.puzzlehash == singletonLauncherProgram.hash()) {
      try {
        final extraData = fullSolution.rest().rest().first();
        return PoolState.fromExtraData(extraData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}