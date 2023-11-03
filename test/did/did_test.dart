import 'dart:convert';

import 'package:chia_crypto_utils/chia_crypto_utils.dart';
import 'package:chia_crypto_utils/src/core/exceptions/keychain_mismatch_exception.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../util/test_data.dart';

void main() {
  final ownerKeychain = WalletKeychain.fromCoreSecret(
    KeychainCoreSecret.fromMnemonicString(
      'muffin ancient quote solve famous armor morning drive diary fetch refuse loyal man giraffe episode drift course resemble tenant resist reopen raise liquid vocal',
    ),
  );
  final otherKeychain = WalletKeychain.fromCoreSecret(
    KeychainCoreSecret.generate(),
  );
  final otherCoin = CoinPrototype(
    parentCoinInfo: TestData.standardCoin.parentCoinInfo,
    puzzlehash: singletonLauncherProgram.hash(),
    amount: 1000,
  );

  final parentSpend = CoinSpend.fromJson(
    jsonDecode(
      '{"coin":{"parent_coin_info":"0x0e92e487f6704b9d6163f4297dd6ef8bf816bea57b7ee570e1c2f524b93b5ea0","puzzle_hash":"0xc7266c9efa4f5a1c8ede1edb85333066b8925855bf2a5eef2b12051a1f2483ff","amount":1},"puzzle_reveal":"0xff02ffff01ff02ffff01ff02ffff03ffff18ff2fff3480ffff01ff04ffff04ff20ffff04ff2fff808080ffff04ffff02ff3effff04ff02ffff04ff05ffff04ffff02ff2affff04ff02ffff04ff27ffff04ffff02ffff03ff77ffff01ff02ff36ffff04ff02ffff04ff09ffff04ff57ffff04ffff02ff2effff04ff02ffff04ff05ff80808080ff808080808080ffff011d80ff0180ffff04ffff02ffff03ff77ffff0181b7ffff015780ff0180ff808080808080ffff04ff77ff808080808080ffff02ff3affff04ff02ffff04ff05ffff04ffff02ff0bff5f80ffff01ff8080808080808080ffff01ff088080ff0180ffff04ffff01ffffffff4947ff0233ffff0401ff0102ffffff20ff02ffff03ff05ffff01ff02ff32ffff04ff02ffff04ff0dffff04ffff0bff3cffff0bff34ff2480ffff0bff3cffff0bff3cffff0bff34ff2c80ff0980ffff0bff3cff0bffff0bff34ff8080808080ff8080808080ffff010b80ff0180ffff02ffff03ffff22ffff09ffff0dff0580ff2280ffff09ffff0dff0b80ff2280ffff15ff17ffff0181ff8080ffff01ff0bff05ff0bff1780ffff01ff088080ff0180ff02ffff03ff0bffff01ff02ffff03ffff02ff26ffff04ff02ffff04ff13ff80808080ffff01ff02ffff03ffff20ff1780ffff01ff02ffff03ffff09ff81b3ffff01818f80ffff01ff02ff3affff04ff02ffff04ff05ffff04ff1bffff04ff34ff808080808080ffff01ff04ffff04ff23ffff04ffff02ff36ffff04ff02ffff04ff09ffff04ff53ffff04ffff02ff2effff04ff02ffff04ff05ff80808080ff808080808080ff738080ffff02ff3affff04ff02ffff04ff05ffff04ff1bffff04ff34ff8080808080808080ff0180ffff01ff088080ff0180ffff01ff04ff13ffff02ff3affff04ff02ffff04ff05ffff04ff1bffff04ff17ff8080808080808080ff0180ffff01ff02ffff03ff17ff80ffff01ff088080ff018080ff0180ffffff02ffff03ffff09ff09ff3880ffff01ff02ffff03ffff18ff2dffff010180ffff01ff0101ff8080ff0180ff8080ff0180ff0bff3cffff0bff34ff2880ffff0bff3cffff0bff3cffff0bff34ff2c80ff0580ffff0bff3cffff02ff32ffff04ff02ffff04ff07ffff04ffff0bff34ff3480ff8080808080ffff0bff34ff8080808080ffff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff2effff04ff02ffff04ff09ff80808080ffff02ff2effff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff02ffff03ffff21ff17ffff09ff0bff158080ffff01ff04ff30ffff04ff0bff808080ffff01ff088080ff0180ff018080ffff04ffff01ffa07faa3253bfddd1e0decb0906b2dc6247bbc4cf608f58345d173adb63e8b47c9fffa0a65e09283d824961b85c91fbcddc00baff09bf887016ea7548d01e03a5457ef1a0eff07522495060c066f66f32acc2a77e3a3e737aca8baea4d1a64ea4cdc13da9ffff04ffff01ff02ffff01ff02ffff01ff02ffff03ff81bfffff01ff02ff05ff82017f80ffff01ff02ffff03ffff22ffff09ffff02ff7effff04ff02ffff04ff8217ffff80808080ff0b80ffff15ff17ff808080ffff01ff04ffff04ff28ffff04ff82017fff808080ffff04ffff04ff34ffff04ff8202ffffff04ff82017fffff04ffff04ff8202ffff8080ff8080808080ffff04ffff04ff38ffff04ff822fffff808080ffff02ff26ffff04ff02ffff04ff2fffff04ff17ffff04ff8217ffffff04ff822fffffff04ff8202ffffff04ff8205ffffff04ff820bffffff01ff8080808080808080808080808080ffff01ff088080ff018080ff0180ffff04ffff01ffffffff313dff4946ffff0233ff3c04ffffff0101ff02ff02ffff03ff05ffff01ff02ff3affff04ff02ffff04ff0dffff04ffff0bff2affff0bff22ff3c80ffff0bff2affff0bff2affff0bff22ff3280ff0980ffff0bff2aff0bffff0bff22ff8080808080ff8080808080ffff010b80ff0180ffffff02ffff03ff17ffff01ff02ffff03ff82013fffff01ff04ffff04ff30ffff04ffff0bffff0bffff02ff36ffff04ff02ffff04ff05ffff04ff27ffff04ff82023fffff04ff82053fffff04ff820b3fff8080808080808080ffff02ff7effff04ff02ffff04ffff02ff2effff04ff02ffff04ff2fffff04ff5fffff04ff82017fff808080808080ff8080808080ff2f80ff808080ffff02ff26ffff04ff02ffff04ff05ffff04ff0bffff04ff37ffff04ff2fffff04ff5fffff04ff8201bfffff04ff82017fffff04ffff10ff8202ffffff010180ff808080808080808080808080ffff01ff02ff26ffff04ff02ffff04ff05ffff04ff37ffff04ff2fffff04ff5fffff04ff8201bfffff04ff82017fffff04ff8202ffff8080808080808080808080ff0180ffff01ff02ffff03ffff15ff8202ffffff11ff0bffff01018080ffff01ff04ffff04ff20ffff04ff82017fffff04ff5fff80808080ff8080ffff01ff088080ff018080ff0180ff0bff17ffff02ff5effff04ff02ffff04ff09ffff04ff2fffff04ffff02ff7effff04ff02ffff04ffff04ff09ffff04ff0bff1d8080ff80808080ff808080808080ff5f80ffff04ffff0101ffff04ffff04ff2cffff04ff05ff808080ffff04ffff04ff20ffff04ff17ffff04ff0bff80808080ff80808080ffff0bff2affff0bff22ff2480ffff0bff2affff0bff2affff0bff22ff3280ff0580ffff0bff2affff02ff3affff04ff02ffff04ff07ffff04ffff0bff22ff2280ff8080808080ffff0bff22ff8080808080ff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff7effff04ff02ffff04ff09ff80808080ffff02ff7effff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff018080ffff04ffff01ff02ffff01ff02ffff01ff02ffff03ff0bffff01ff02ffff03ffff09ff05ffff1dff0bffff1effff0bff0bffff02ff06ffff04ff02ffff04ff17ff8080808080808080ffff01ff02ff17ff2f80ffff01ff088080ff0180ffff01ff04ffff04ff04ffff04ff05ffff04ffff02ff06ffff04ff02ffff04ff17ff80808080ff80808080ffff02ff17ff2f808080ff0180ffff04ffff01ff32ff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff06ffff04ff02ffff04ff09ff80808080ffff02ff06ffff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff018080ffff04ffff01b0827242197d20d0d2aa34467b26280dfe5ea703cddcca5541d1aa2db0648d3b7ca5f3fe4129c04a852244f66b396d1946ff018080ffff04ffff01a04bf5122f344554c53bde2ebb8cd2b7e3d1600ad631c385a5d7cce23c7785459affff04ffff0180ffff04ffff01ffa07faa3253bfddd1e0decb0906b2dc6247bbc4cf608f58345d173adb63e8b47c9fffa0a65e09283d824961b85c91fbcddc00baff09bf887016ea7548d01e03a5457ef1a0eff07522495060c066f66f32acc2a77e3a3e737aca8baea4d1a64ea4cdc13da9ffff04ffff0180ff01808080808080ff01808080","solution":"0xffffa01c26e1cc154bcb79e520ec4503cc78626e510f5aa61bfe86688360601decaf66ffa0a5fd6b30bc4cf336276683166a5e3a6872baebadfcc8fe42090dd0cd1dd3f031ff0180ff01ffff01ffff80ffff01ffff33ffa0079dac55b1a698eb0999f78989d01504e056089cbca9aad51f6506d08fbd1102ff01ffffa093f85a774c21cb516ac2532923cc8313413b04914caca20c445ee5d5b720f690808080ff80808080"}',
    ) as Map<String, dynamic>,
  );
  final coin = CoinPrototype.fromJson(
    jsonDecode(
      '{"parent_coin_info":"0xfa404d21cb67035fa3b77d010f3c0425a9c4b2dd6565b730a8da454d5a3a9b0b","puzzle_hash":"0xc25da1b57d364ba9eae03b0d7b78f99a031a2e3a08adf20a43abfe75a0bb0aa2","amount":1}',
    ) as Map<String, dynamic>,
  );
  final didRecord = DidRecord.fromParentCoinSpend(parentSpend, coin);

  test('should fail with keychan mismatch', () {
    expect(
      () => didRecord!.toDidInfoOrThrow(otherKeychain),
      throwsA(isA<KeychainMismatchException>()),
    );
  });
  test('should fail with coin mismatch', () {
    expect(
      () => DidRecord.fromParentCoinSpend(parentSpend, otherCoin)!
          .toDidInfoOrThrow(ownerKeychain),
      throwsA(isA<KeychainMismatchException>()),
    );
  });

  test('should return normally with correct keychain', () {
    expect(
      () => didRecord!.toDidInfoOrThrow(ownerKeychain),
      returnsNormally,
    );
  });

  test('should correctly construct DID record from parent spend asynchronously',
      () async {
    final didRecordAsync =
        await DidRecord.fromParentCoinSpendAsync(parentSpend, coin);

    expect(
      didRecordAsync!.toDidInfoOrThrow(ownerKeychain),
      equals(didRecord!.toDidInfoOrThrow(ownerKeychain)),
    );
  });

  test('should return normally async', () async {
    final didInfoAsync = await didRecord!.toDidInfoAsync(ownerKeychain);
    final didInfo = didRecord.toDidInfo(ownerKeychain);

    expect(
      didInfoAsync!.innerPuzzle,
      equals(didInfo!.innerPuzzle),
    );
  });
}
