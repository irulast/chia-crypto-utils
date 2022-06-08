import 'dart:math';

import 'package:chia_crypto_utils/chia_crypto_utils.dart';

class CoinSplittingService {
  CoinSplittingService(this.fullNode);
  CoinSplittingService.fromContext() : fullNode = ChiaFullNodeInterface.fromContext();
  final ChiaFullNodeInterface fullNode;
  final catWalletService = CatWalletService();

  

  Future<void> createAndPushFinalSplittingTransactions({
    required List<CatCoin> catCoins,
    required List<Coin> standardCoinsForFee,
    required WalletKeychain keychain,
    required int splitWidth,
    required int feePerCoin,
    required int desiredNumberOfCoins,
    required int desiredAmountPerCoin,
    required Puzzlehash changePuzzlehash,
  }) async {
    var numberOfCoinsCreated = 0;
    final additionIdsToLookFor = <Bytes>[];

    final transactionFutures = <Future>[];
    var isFinished = false;

    for (final catCoin in catCoins) {
      final payments = <Payment>[];
      for (var i = 0; i < 10; i++) {
        if (numberOfCoinsCreated >= desiredNumberOfCoins) {
          isFinished = true;
          break;
        }
        payments.add(Payment(desiredAmountPerCoin, keychain.puzzlehashes[i]));
        numberOfCoinsCreated++;
      }

      final lastPaymentAmount = catCoin.amount -
          payments.fold(0, (previousValue, payment) => previousValue + payment.amount);
      payments.add(Payment(lastPaymentAmount.toInt(), changePuzzlehash));

      final spendBundle = CatWalletService().createSpendBundle(
        payments: payments,
        catCoinsInput: [catCoin],
        keychain: keychain,
      );
      additionIdsToLookFor.add(spendBundle.additions.first.id);

      transactionFutures.add(fullNode.pushTransaction(spendBundle));
      if (isFinished) {
        break;
      }
    }
    await Future.wait<void>(transactionFutures);
    await waitForTransactions(additionIdsToLookFor);
  }

  Future<void> createAndPushSplittingTransactions({
    required List<CatCoin> catCoins,
    required List<Coin> standardCoinsForFee,
    required WalletKeychain keychain,
    required int splitWidth,
    required int feePerCoin,
  }) async {
    final transactionFutures = <Future>[];
    final additionIdsToLookFor = <Bytes>[];
    for (final catCoin in catCoins) {
      final payments = <Payment>[];
      for (var i = 0; i < splitWidth - 1; i++) {
        payments.add(Payment(catCoin.amount ~/ splitWidth, keychain.puzzlehashes[i]));
      }
      final lastPaymentAmount = catCoin.amount -
          payments.fold(0, (previousValue, payment) => previousValue + payment.amount);
      payments.add(Payment(lastPaymentAmount.toInt(), keychain.puzzlehashes[splitWidth - 1]));
      if (payments.toSet().length != payments.length) {
        print(payments.map((e) => e.puzzlehash).toList());
        throw Exception('duplicate output');
      }
      final spendBundle = CatWalletService().createSpendBundle(
        payments: payments,
        catCoinsInput: [catCoin],
        keychain: keychain,
        standardCoinsForFee: standardCoinsForFee,
        fee: splitWidth * feePerCoin,
      );
      additionIdsToLookFor.add(spendBundle.additions.first.id);
      transactionFutures.add(fullNode.pushTransaction(spendBundle));
    }
    await Future.wait<void>(transactionFutures);

    // wait for all spend bundles to be pushed
    await waitForTransactions(additionIdsToLookFor);
  }

  Future<void> waitForTransactions(List<Bytes> additionIdsToLookFor) async {
    final unfoundIds = Set<Bytes>.from(additionIdsToLookFor);

    while (unfoundIds.isNotEmpty) {
      final foundCoins = await fullNode.getCoinsByIds(unfoundIds.toList());
      final foundIds = foundCoins.map((c) => c.id).toSet();
      unfoundIds.removeWhere(foundIds.contains);

      await Future<void>.delayed(const Duration(seconds: 19));
      print('waiting for transactions to be included...');
    }
  }

  int calculateNumberOfNWidthSplitsRequired({
    required int desiredNumberOfCoins,
    required int initialSplitWidth,
  }) {
    late int numberOfBinarySplits;
    num smallestDifference = 10000000;

    for (var i = 0; i < 10; i++) {
      final resultingCoins = pow(initialSplitWidth, i).toInt();

      if (resultingCoins > desiredNumberOfCoins) {
        break;
      }

      final desiredNumberOfCoinsDigitsToCompare = desiredNumberOfCoins.toNDigits(3);

      final resultingCoinsDigitsToCompare = resultingCoins.toNDigits(3);

      var difference = desiredNumberOfCoinsDigitsToCompare - resultingCoinsDigitsToCompare;
      if (difference < 0 && resultingCoins.numberOfDigits > 1) {
        final resultingCoinsDigitsMinusOneToCompare =
            resultingCoins.toNDigits(resultingCoins.numberOfDigits - 1);

        difference = desiredNumberOfCoinsDigitsToCompare - resultingCoinsDigitsMinusOneToCompare;
      }

      if (difference >= 0 && difference < smallestDifference) {
        smallestDifference = difference;
        numberOfBinarySplits = i;
      }
    }

    return numberOfBinarySplits;
  }

  int calculateNumberOfDecaSplitsRequired(
    int resultingCoinsFromNWidthSplits,
    int desiredNumberOfCoins,
  ) {
    var numberOfDecaSplits = 0;
    while (resultingCoinsFromNWidthSplits * pow(10, numberOfDecaSplits) <= desiredNumberOfCoins) {
      numberOfDecaSplits++;
    }
    // want just under desired amount
    return numberOfDecaSplits - 1;
  }
}

extension ShortenIntToTwoDigits on num {
  num toNDigits(int nDigits) {
    final base10Upper = pow(10, nDigits);
    final base10Lower = pow(10, nDigits - 1);
    if (this > base10Upper) {
      var reduced = this;
      while (reduced > base10Upper) {
        reduced /= 10;
      }
      return reduced;
    }
    if (this < base10Lower) {
      var increased = this;
      while (increased < base10Lower) {
        increased *= 10;
      }
      return increased;
    }
    return this;
  }

  int get numberOfDigits => toString().replaceAll('.', '').length;
}
