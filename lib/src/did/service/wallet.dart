// ignore_for_file: lines_longer_than_80_chars

import 'package:chia_crypto_utils/chia_crypto_utils.dart';
import 'package:chia_crypto_utils/src/clvm/keywords.dart';
import 'package:chia_crypto_utils/src/core/models/conditions/create_puzzle_announcement_condition.dart';
import 'package:chia_crypto_utils/src/did/models/uncurried_did_puzzle.dart';
import 'package:chia_crypto_utils/src/utils/curry_and_tree_hash.dart';

class DIDWalletService extends BaseWalletService {
  final StandardWalletService standardWalletService = StandardWalletService();
  static const defaultDidAmount = 1;

  // TODO(nvjoshi2): use chia's did update spending method (intermediary spend for new inner puzzle reveal)
  SpendBundle createUpdateSpend(
    DidInfo didInfo,
    PrivateKey privateKey,
    Puzzlehash newInnerPuzzlehash,
  ) {
    final p2Solution = BaseWalletService.makeSolutionFromConditions([
      CreateCoinCondition(
        newInnerPuzzlehash,
        didInfo.coin.amount,
        memos: [newInnerPuzzlehash],
      ),
    ]);

    final innerSolution = makeRunInnerPuzzleModeInnerSolution(p2Solution);

    final fullSolution = Program.list([
      didInfo.lineageProof.toProgram(),
      Program.fromInt(didInfo.coin.amount),
      innerSolution,
    ]);
    final coinSpend = CoinSpend(
      coin: didInfo.coin,
      puzzleReveal: didInfo.fullPuzzle,
      solution: fullSolution,
    );

    return SpendBundle(coinSpends: [coinSpend])
        .signWithPrivateKey(privateKey)
        .signedBundle;
  }

  SpendBundle createExitSpend(
    Puzzlehash destinationPuzzlehash,
    DidInfo didInfo,
    PrivateKey privateKey,
  ) {
    final p2Solution = BaseWalletService.makeSolutionFromConditions([
      CreateCoinCondition(
        destinationPuzzlehash,
        didInfo.coin.amount - 1,
        memos: [destinationPuzzlehash],
      ),
      DidExitCondition(),
    ]);

    final innerSolution = makeRunInnerPuzzleModeInnerSolution(p2Solution);

    final fullSolution = Program.list([
      didInfo.lineageProof.toProgram(),
      Program.fromInt(didInfo.coin.amount),
      innerSolution,
    ]);
    final coinSpend = CoinSpend(
      coin: didInfo.coin,
      puzzleReveal: didInfo.fullPuzzle,
      solution: fullSolution,
    );

    return SpendBundle(coinSpends: [coinSpend])
        .signWithPrivateKey(privateKey)
        .signedBundle;
  }

  SpendBundle createRecoverySpendBundle(
    DidRecord recoveringDidRecord,
    PrivateKey newPrivateKey,
    Puzzlehash newInnerPuzzlehash,
    List<LineageProof> recoveryInfos,
    List<Bytes> recoveryIds,
    SpendBundle messageSpendBundle,
  ) {
    final recoveringDidInfo =
        recoveringDidRecord.toDidInfoFromParentInfoOrThrow();
    final recoveringCoin = recoveringDidInfo.coin;
    final newPublicKey = newPrivateKey.getG1();

    final innerSolution = makeRecoveryModeInnerSolution(
      newAmount: recoveringCoin.amount,
      newInnerPuzzlehash: newInnerPuzzlehash,
      recoveryInfos: recoveryInfos,
      newPublicKey: newPublicKey,
      recoveryList: recoveryIds,
      recoveryId: recoveringCoin.id,
    );

    final innerPuzzle = recoveringDidInfo.innerPuzzle;
    final fullPuzzle =
        DIDWalletService.makeFullPuzzle(innerPuzzle, recoveringDidInfo.did);

    final parentInfo = recoveringDidInfo.lineageProof;
    final fullSolution = Program.list(
      [
        parentInfo.toProgram(),
        Program.fromInt(recoveringCoin.amount),
        innerSolution
      ],
    );

    final coinSpend = CoinSpend(
      coin: recoveringCoin,
      puzzleReveal: fullPuzzle,
      solution: fullSolution,
    );

    final message = newInnerPuzzlehash;
    final sigs = [AugSchemeMPL.sign(newPrivateKey, message)];
    for (var _ = 0; _ < messageSpendBundle.coinSpends.length; _++) {
      sigs.add(AugSchemeMPL.sign(newPrivateKey, message));
    }
    final aggSigs = AugSchemeMPL.aggregate(sigs);

    return SpendBundle(coinSpends: [coinSpend], signatures: {aggSigs}) +
        messageSpendBundle;
  }

  SpendBundle createTransferSpendBundle({
    required DidInfo didInfo,
    required Puzzlehash newP2Puzzlehash,
    Puzzlehash? changePuzzlehash,
    List<CoinPrototype> coinsForFee = const [],
    int fee = 0,
    required WalletKeychain keychain,
  }) {
    return createSpendBundle(
          didInfo: didInfo,
          newP2Puzzlehash: newP2Puzzlehash,
          keychain: keychain,
        ) +
        standardWalletService.createFeeSpendBundle(
          fee: fee,
          standardCoins: coinsForFee,
          keychain: keychain,
          changePuzzlehash: changePuzzlehash,
        );
  }

  SpendBundle createSpendBundle({
    required DidInfo didInfo,
    Puzzlehash? newP2Puzzlehash,
    List<Payment> additionalPayments = const [],
    List<Bytes> puzzlesToAnnounce = const [],
    List<CreateCoinAnnouncementCondition> createCoinAnnouncements = const [],
    List<AssertCoinAnnouncementCondition> assertCoinAnnouncements = const [],
    List<AssertPuzzleAnnouncementCondition> assertPuzzleAnnouncements =
        const [],
    required WalletKeychain keychain,
  }) {
    final walletVector =
        keychain.getWalletVectorOrThrow(didInfo.p2Puzzle.hash());

    return createSpendBundleFromPrivateKey(
      didInfo: didInfo,
      privateKey: walletVector.childPrivateKey,
      additionalPayments: additionalPayments,
      assertCoinAnnouncements: assertCoinAnnouncements,
      assertPuzzleAnnouncements: assertPuzzleAnnouncements,
      createCoinAnnouncements: createCoinAnnouncements,
      newP2Puzzlehash: newP2Puzzlehash,
      puzzlesToAnnounce: puzzlesToAnnounce,
    );
  }

  SpendBundle createSpendBundleFromPrivateKey({
    required DidInfo didInfo,
    required PrivateKey privateKey,
    bool revealBackupIds = false,
    Puzzlehash? newP2Puzzlehash,
    List<Payment> additionalPayments = const [],
    List<Bytes> puzzlesToAnnounce = const [],
    List<CreateCoinAnnouncementCondition> createCoinAnnouncements = const [],
    List<AssertCoinAnnouncementCondition> assertCoinAnnouncements = const [],
    List<AssertPuzzleAnnouncementCondition> assertPuzzleAnnouncements =
        const [],
  }) {
    final spendBundle = createUnsignedSpendBundle(
      didInfo: didInfo,
      revealBackupIds: revealBackupIds,
      newP2Puzzlehash: newP2Puzzlehash,
      additionalPayments: additionalPayments,
      puzzlesToAnnounce: puzzlesToAnnounce,
      createCoinAnnouncements: createCoinAnnouncements,
      assertCoinAnnouncements: assertCoinAnnouncements,
      assertPuzzleAnnouncements: assertPuzzleAnnouncements,
    );

    return standardWalletService
        .signSpendBundleWithPrivateKey(spendBundle, privateKey)
        .signedBundle;
  }

  SpendBundle createUnsignedSpendBundle({
    required DidInfo didInfo,
    bool revealBackupIds = false,
    Puzzlehash? newP2Puzzlehash,
    List<Payment> additionalPayments = const [],
    List<Bytes> puzzlesToAnnounce = const [],
    List<CreateCoinAnnouncementCondition> createCoinAnnouncements = const [],
    List<AssertCoinAnnouncementCondition> assertCoinAnnouncements = const [],
    List<AssertPuzzleAnnouncementCondition> assertPuzzleAnnouncements =
        const [],
  }) {
    final newInnerPuzzleHash = () {
      if (newP2Puzzlehash == null) {
        return didInfo.innerPuzzle.hash();
      }

      final uncurriedParent =
          UncurriedDidInnerPuzzle.fromProgram(didInfo.innerPuzzle);
      return calculateInnerPuzzleHash(
        p2Puzzlehash: newP2Puzzlehash,
        backupIdsHashProgram: uncurriedParent.backUpIdsHashProgram,
        nVerificationsRequiredProgram:
            uncurriedParent.numberOfVerificationsRequiredProgram,
        singletonStructure: uncurriedParent.singletonStructureProgram,
        metadataProgram: uncurriedParent.metadataProgram,
      );
    }();

    final targetP2PuzzleHash = newP2Puzzlehash ?? didInfo.p2Puzzle.hash();
    final p2Solution = BaseWalletService.makeSolutionFromConditions([
      CreateCoinCondition(
        newInnerPuzzleHash,
        didInfo.coin.amount,
        memos: [targetP2PuzzleHash],
      ),
      ...additionalPayments.map((e) => e.toCreateCoinCondition()),
      ...puzzlesToAnnounce.map(CreatePuzzleAnnouncementCondition.new),
      ...createCoinAnnouncements,
      ...assertCoinAnnouncements,
      ...assertPuzzleAnnouncements,
    ]);

    final innerSolution = Program.list([
      Program.fromInt(1),
      p2Solution,
      if (revealBackupIds && didInfo.backupIds != null) ...[
        Program.nil,
        Program.nil,
        Program.nil,
        Program.list(didInfo.backupIds!),
      ],
    ]);
    final fullSolution = Program.list([
      didInfo.lineageProof.toProgram(),
      Program.fromInt(didInfo.coin.amount),
      innerSolution,
    ]);
    final coinSpend = CoinSpend(
      coin: didInfo.coin,
      puzzleReveal: didInfo.fullPuzzle,
      solution: fullSolution,
    );

    return SpendBundle(
      coinSpends: [coinSpend],
    );
  }

  Attestment createAttestment({
    required DidInfo attestmentMakerDidInfo,
    required DidRecord recoveringDidInfo,
    required PrivateKey attestmentMakerPrivateKey,
    required JacobianPoint newPublicKey,
    required Puzzlehash newInnerPuzzlehash,
  }) {
    final recoveringCoinId = recoveringDidInfo.coin.id;

    final messagePuzzle = makeRecoveryMessagePuzzle(
      recoveringCoinId,
      newInnerPuzzlehash,
      newPublicKey,
    );

    final innerMessage = messagePuzzle.hash();
    final innerPuzzle = attestmentMakerDidInfo.innerPuzzle;

    final p2Solution = BaseWalletService.makeSolutionFromConditions([
      CreateCoinCondition(
        innerPuzzle.hash(),
        attestmentMakerDidInfo.coin.amount,
      ),
      CreateCoinCondition(innerMessage, 0),
    ]);

    final innerSolution = makeRunInnerPuzzleModeInnerSolution(p2Solution);

    final fullPuzzle = DIDWalletService.makeFullPuzzle(
      innerPuzzle,
      attestmentMakerDidInfo.did,
    );

    final parentInfo = attestmentMakerDidInfo.lineageProof;
    final fullSolution = Program.list([
      parentInfo.toProgram(),
      Program.fromInt(attestmentMakerDidInfo.coin.amount),
      innerSolution,
    ]);

    final coinSpend = CoinSpend(
      coin: attestmentMakerDidInfo.coin,
      puzzleReveal: fullPuzzle,
      solution: fullSolution,
    );

    final messageSpend =
        createSpendForMessage(attestmentMakerDidInfo.coin.id, messagePuzzle);
    final messageSpendBundle = SpendBundle(coinSpends: [messageSpend]);

    final spendBundle = SpendBundle(coinSpends: [coinSpend])
        .signWithPrivateKey(attestmentMakerPrivateKey)
        .signedBundle;

    return Attestment(
      attestmentSpendBundle: spendBundle,
      messageSpendBundle: messageSpendBundle,
    );
  }

  static Program makeRecoveryMessagePuzzle(
    Bytes recoveringCoinId,
    Puzzlehash newPuzzlehash,
    JacobianPoint newPublicKey,
  ) {
    return Program.list([
      Program.fromBigInt(keywords['q']!),
      CreateCoinAnnouncementCondition(recoveringCoinId).toProgram(),
      Program.list([
        Program.fromInt(49),
        Program.fromAtom(newPublicKey.toBytes()),
        Program.fromAtom(newPuzzlehash),
      ]),
    ]);
  }

  static CoinSpend createSpendForMessage(
    Bytes attestmentMakerCoinId,
    Program messagePuzzle,
  ) {
    final coin = CoinPrototype(
      parentCoinInfo: attestmentMakerCoinId,
      puzzlehash: messagePuzzle.hash(),
      amount: 0,
    );
    final solution = Program.list([]);
    return CoinSpend(
      coin: coin,
      puzzleReveal: messagePuzzle,
      solution: solution,
    );
  }

  SpendBundle createGenerateDIDSpendBundle({
    int amount = defaultDidAmount,
    required List<CoinPrototype> standardCoins,
    required Puzzlehash targetPuzzleHash,
    required WalletKeychain keychain,
    DidMetadata? metadata,
    int fee = 0,
    Puzzlehash? changePuzzlehash,
    List<Bytes> backupIds = const [],
    int? nVerificationsRequired,
  }) {
    final originCoin = standardCoins[0];

    final launcherCoin = CoinPrototype(
      parentCoinInfo: originCoin.id,
      puzzlehash: singletonLauncherProgram.hash(),
      amount: amount,
    );

    final launcherId = launcherCoin.id;

    final walletVector = keychain.getWalletVectorOrThrow(targetPuzzleHash);

    final p2Puzzle = getPuzzleFromPk(walletVector.childPublicKey);

    final didInnerPuzzle = createInnerPuzzle(
      p2Puzzle: p2Puzzle,
      backupIdsHash:
          Program.list(backupIds.map(Program.fromAtom).toList()).hash(),
      launcherCoinId: launcherId,
      nVerificationsRequired: nVerificationsRequired ?? backupIds.length,
      metadataProgram: metadata?.toProgram(),
    );
    final didFullPuzzle = makeFullPuzzle(didInnerPuzzle, launcherCoin.id);

    final didPuzzlehash = didFullPuzzle.hash();

    final genesisLauncherSolution = Program.list([
      didPuzzlehash,
      Program.fromInt(amount),
      Bytes.zeros(0x80),
    ]);

    final announcementMessage = genesisLauncherSolution.hash();

    final announcements = [
      AssertCoinAnnouncementCondition(launcherId, announcementMessage)
    ];

    final standardSpendBundle = standardWalletService.createSpendBundle(
      payments: [Payment(amount, singletonLauncherProgram.hash())],
      coinsInput: standardCoins,
      changePuzzlehash: changePuzzlehash,
      keychain: keychain,
      fee: fee,
      originId: originCoin.id,
      coinAnnouncementsToAssert: announcements,
    );

    final launcherCoinsSpend = CoinSpend(
      coin: launcherCoin,
      puzzleReveal: singletonLauncherProgram,
      solution: genesisLauncherSolution,
    );

    final launcherSpendBundle = SpendBundle(coinSpends: [launcherCoinsSpend]);

    final eveCoin = CoinPrototype(
      parentCoinInfo: launcherCoin.id,
      puzzlehash: didPuzzlehash,
      amount: amount,
    );

    final eveSpendBundle = createEveSpendBundle(
      eveCoin: eveCoin,
      launcherCoin: launcherCoin,
      fullPuzzle: didFullPuzzle,
      innerPuzzle: didInnerPuzzle,
      keychain: keychain,
    );

    return eveSpendBundle + launcherSpendBundle + standardSpendBundle;
  }

  SpendBundle createEveSpendBundle({
    required CoinPrototype launcherCoin,
    required CoinPrototype eveCoin,
    required Program fullPuzzle,
    required Program innerPuzzle,
    required WalletKeychain keychain,
  }) {
    final uncurried = UncurriedDidInnerPuzzle.fromProgram(innerPuzzle);
    final p2PuzzleHash = uncurried.p2Puzzle.hash();
    final p2Solution = BaseWalletService.makeSolutionFromConditions([
      CreateCoinCondition(
        innerPuzzle.hash(),
        eveCoin.amount,
        memos: [
          p2PuzzleHash,
        ],
      ),
    ]);

    final innerSolution = Program.list([Program.fromInt(1), p2Solution]);

    final fullSolution = Program.list([
      LineageProof(
        parentCoinInfo: launcherCoin.parentCoinInfo,
        innerPuzzlehash: null,
        amount: launcherCoin.amount,
      ),
      Program.fromInt(eveCoin.amount),
      innerSolution,
    ]);

    final coinSpend = CoinSpend(
      coin: eveCoin,
      puzzleReveal: fullPuzzle,
      solution: fullSolution,
    );

    final walletVector = keychain.getWalletVectorOrThrow(p2PuzzleHash);

    return SpendBundle(coinSpends: [coinSpend])
        .signWithPrivateKey(walletVector.childPrivateKey)
        .signedBundle;
  }

  SpendBundle signDidSpend(
    SpendBundle spendBundle,
    WalletKeychain keychain,
  ) {
    for (final coinSpend in spendBundle.coinSpends) {
      final unCurriedNftPuzzle =
          UncurriedDidPuzzle.maybeFromProgram(coinSpend.puzzleReveal);
      if (unCurriedNftPuzzle != null) {
        final p2Puzzlehash = unCurriedNftPuzzle.innerPuzzle.p2Puzzle.hash();
        final privateKey =
            keychain.getWalletVector(p2Puzzlehash)!.childPrivateKey;
        return spendBundle.signWithPrivateKey(privateKey).signedBundle;
      }
    }
    throw Exception('No did spend found in spend bundle');
  }

  static Program createInnerPuzzle({
    required Program p2Puzzle,
    required Puzzlehash backupIdsHash,
    required Bytes launcherCoinId,
    required int nVerificationsRequired,
    required Program? metadataProgram,
  }) {
    final singletonStructure =
        SingletonService.makeSingletonStructureProgram(launcherCoinId);

    return constructInnerPuzzle(
      p2Puzzle: p2Puzzle,
      backupIdsHashProgram: Program.fromAtom(backupIdsHash),
      nVerificationsRequiredProgram: Program.fromInt(nVerificationsRequired),
      singletonStructure: singletonStructure,
      metadataProgram: metadataProgram ?? Program.nil,
    );
  }

  static Program constructInnerPuzzle({
    required Program p2Puzzle,
    required Program backupIdsHashProgram,
    required Program nVerificationsRequiredProgram,
    required Program singletonStructure,
    required Program metadataProgram,
  }) {
    return didInnerPuzzleProgram.curry([
      p2Puzzle,
      backupIdsHashProgram,
      nVerificationsRequiredProgram,
      singletonStructure,
      metadataProgram,
    ]);
  }

  static Puzzlehash calculateInnerPuzzleHash({
    required Puzzlehash p2Puzzlehash,
    required Program backupIdsHashProgram,
    required Program nVerificationsRequiredProgram,
    required Program singletonStructure,
    required Program metadataProgram,
  }) {
    return curryAndTreeHash(didInnerPuzzleProgram, [
      p2Puzzlehash,
      backupIdsHashProgram.hash(),
      nVerificationsRequiredProgram.hash(),
      singletonStructure.hash(),
      metadataProgram.hash(),
    ]);
  }

  static Program createInnerPuzzleForPk({
    required JacobianPoint publicKey,
    required Puzzlehash backupIdsHash,
    required Bytes launcherCoinId,
    required int nVerificationsRequired,
    required Program? metadataProgram,
  }) {
    final p2Puzzle = getPuzzleFromPk(publicKey);
    return createInnerPuzzle(
      p2Puzzle: p2Puzzle,
      backupIdsHash: backupIdsHash,
      launcherCoinId: launcherCoinId,
      nVerificationsRequired: nVerificationsRequired,
      metadataProgram: metadataProgram,
    );
  }

  static Program makeFullPuzzle(
    Program didInnerPuzzle,
    Bytes launcherCoinId,
  ) {
    final singletonStructure =
        SingletonService.makeSingletonStructureProgram(launcherCoinId);

    return singletonTopLayerV1Program
        .curry([singletonStructure, didInnerPuzzle]);
  }

  static Program makeRecoveryModeInnerSolution({
    required int newAmount,
    required Puzzlehash newInnerPuzzlehash,
    required List<LineageProof> recoveryInfos,
    required JacobianPoint newPublicKey,
    required List<Bytes> recoveryList,
    required Bytes recoveryId,
  }) {
    return Program.list([
      Program.fromInt(SpendMode.recovery.code),
      Program.fromInt(newAmount),
      Program.fromAtom(newInnerPuzzlehash),
      Program.list(recoveryInfos.map((i) => i.toProgram()).toList()),
      Program.fromAtom(newPublicKey.toBytes()),
      Program.list(recoveryList.map(Program.fromAtom).toList()),
      Program.fromAtom(recoveryId),
    ]);
  }

  static Program makeRunInnerPuzzleModeInnerSolution(Program p2Solution) {
    return Program.list([
      Program.fromInt(SpendMode.runInnerPuzzle.code),
      p2Solution,
    ]);
  }

  static List<T> extractP2ConditionsFromInnerSolution<T>(
    Program solution,
    ConditionChecker<T> conditionChecker,
    ConditionFromProgramConstructor<T> conditionFromProgramConstructor,
  ) {
    if (SpendMode.fromCode(solution.toList()[0].toInt()) !=
        SpendMode.runInnerPuzzle) {
      return [];
    }
    return BaseWalletService.extractConditionsFromSolution(
      solution.toList()[1],
      conditionChecker,
      conditionFromProgramConstructor,
    );
  }
}
