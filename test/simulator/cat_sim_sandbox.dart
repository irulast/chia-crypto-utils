import "dart:convert";

import "package:chia_utils/chia_crypto_utils.dart";
import 'package:chia_utils/src/api/chia_full_node_interface.dart';
import 'package:chia_utils/src/api/full_node_http_rpc.dart';
import 'package:chia_utils/src/core/service/base_wallet.dart';

void main() {
  const fullNodeRpc = FullNodeHttpRpc('http://localhost:4000');
  final configurationProvider = ConfigurationProvider()
    ..setConfig(NetworkFactory.configId, {
      'yaml_file_path': 'lib/src/networks/chia/testnet0/config.yaml'
    }
  );

  final context = Context(configurationProvider);
  final blockcahinNetworkLoader = ChiaBlockchainNetworkLoader();
  context.registerFactory(NetworkFactory(blockcahinNetworkLoader.loadfromLocalFileSystem));
  final walletService = BaseWalletService(context);

  final privateKey = PrivateKey.fromHex('704b30d89b99982910190440f65976c59143b949193e6c302049629d7b4c43aa');


  final coinSpendsJson = '[{"coin": {"parent_coin_info": "0x6468acf73bd52b38ee43ab1462a03121672f5057bfd3f818abeb2eea66f34ecb", "puzzle_hash": "0x4ae66ab4c37d37982c88e3b048456a8b67ed7a646e8243bb45ff9f736ede8c55", "amount": 999999998000}, "puzzle_reveal": "0xff02ffff01ff02ffff01ff02ffff03ff0bffff01ff02ffff03ffff09ff05ffff1dff0bffff1effff0bff0bffff02ff06ffff04ff02ffff04ff17ff8080808080808080ffff01ff02ff17ff2f80ffff01ff088080ff0180ffff01ff04ffff04ff04ffff04ff05ffff04ffff02ff06ffff04ff02ffff04ff17ff80808080ff80808080ffff02ff17ff2f808080ff0180ffff04ffff01ff32ff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff06ffff04ff02ffff04ff09ff80808080ffff02ff06ffff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff018080ffff04ffff01b0a48554c5e4cb3122c103f9ee5b8807164ae2bbf9287cae39ad250156b13ee64f4cb52ee21aac849b1eb91bef0198ad5dff018080", "solution": "0xff80ffff01ffff33ffa005b5edf5086b2f9dc3c7ccf1e73df9702d0942c76c7e142059be1da061ea5835ff8203e880ffff33ffa0d225459472551fbe19dbe32d18e9a3b2cce863e93a7a6236145445322a624eb6ff8600e8d4a5044880ffff3cffa06a63d837fa1fb1052f46f522506b29b24012847943a5d573d695e1f666c039db8080ff8080"}, {"coin": {"parent_coin_info": "0x08c9deaebde797c0ba01fd5670830ea285946297c0f4d311ddf5ec81dee3f37b", "puzzle_hash": "0x05b5edf5086b2f9dc3c7ccf1e73df9702d0942c76c7e142059be1da061ea5835", "amount": 1000}, "puzzle_reveal": "0xff02ffff01ff02ffff01ff02ff5effff04ff02ffff04ffff04ff05ffff04ffff0bff2cff0580ffff04ff0bff80808080ffff04ffff02ff17ff2f80ffff04ff5fffff04ffff02ff2effff04ff02ffff04ff17ff80808080ffff04ffff0bff82027fff82057fff820b7f80ffff04ff81bfffff04ff82017fffff04ff8202ffffff04ff8205ffffff04ff820bffff80808080808080808080808080ffff04ffff01ffffffff81ca3dff46ff0233ffff3c04ff01ff0181cbffffff02ff02ffff03ff05ffff01ff02ff32ffff04ff02ffff04ff0dffff04ffff0bff22ffff0bff2cff3480ffff0bff22ffff0bff22ffff0bff2cff5c80ff0980ffff0bff22ff0bffff0bff2cff8080808080ff8080808080ffff010b80ff0180ffff02ffff03ff0bffff01ff02ffff03ffff09ffff02ff2effff04ff02ffff04ff13ff80808080ff820b9f80ffff01ff02ff26ffff04ff02ffff04ffff02ff13ffff04ff5fffff04ff17ffff04ff2fffff04ff81bfffff04ff82017fffff04ff1bff8080808080808080ffff04ff82017fff8080808080ffff01ff088080ff0180ffff01ff02ffff03ff17ffff01ff02ffff03ffff20ff81bf80ffff0182017fffff01ff088080ff0180ffff01ff088080ff018080ff0180ffff04ffff04ff05ff2780ffff04ffff10ff0bff5780ff778080ff02ffff03ff05ffff01ff02ffff03ffff09ffff02ffff03ffff09ff11ff7880ffff0159ff8080ff0180ffff01818f80ffff01ff02ff7affff04ff02ffff04ff0dffff04ff0bffff04ffff04ff81b9ff82017980ff808080808080ffff01ff02ff5affff04ff02ffff04ffff02ffff03ffff09ff11ff7880ffff01ff04ff78ffff04ffff02ff36ffff04ff02ffff04ff13ffff04ff29ffff04ffff0bff2cff5b80ffff04ff2bff80808080808080ff398080ffff01ff02ffff03ffff09ff11ff2480ffff01ff04ff24ffff04ffff0bff20ff2980ff398080ffff010980ff018080ff0180ffff04ffff02ffff03ffff09ff11ff7880ffff0159ff8080ff0180ffff04ffff02ff7affff04ff02ffff04ff0dffff04ff0bffff04ff17ff808080808080ff80808080808080ff0180ffff01ff04ff80ffff04ff80ff17808080ff0180ffffff02ffff03ff05ffff01ff04ff09ffff02ff26ffff04ff02ffff04ff0dffff04ff0bff808080808080ffff010b80ff0180ff0bff22ffff0bff2cff5880ffff0bff22ffff0bff22ffff0bff2cff5c80ff0580ffff0bff22ffff02ff32ffff04ff02ffff04ff07ffff04ffff0bff2cff2c80ff8080808080ffff0bff2cff8080808080ffff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff2effff04ff02ffff04ff09ff80808080ffff02ff2effff04ff02ffff04ff0dff8080808080ffff01ff0bff2cff058080ff0180ffff04ffff04ff28ffff04ff5fff808080ffff02ff7effff04ff02ffff04ffff04ffff04ff2fff0580ffff04ff5fff82017f8080ffff04ffff02ff7affff04ff02ffff04ff0bffff04ff05ffff01ff808080808080ffff04ff17ffff04ff81bfffff04ff82017fffff04ffff0bff8204ffffff02ff36ffff04ff02ffff04ff09ffff04ff820affffff04ffff0bff2cff2d80ffff04ff15ff80808080808080ff8216ff80ffff04ff8205ffffff04ff820bffff808080808080808080808080ff02ff2affff04ff02ffff04ff5fffff04ff3bffff04ffff02ffff03ff17ffff01ff09ff2dffff0bff27ffff02ff36ffff04ff02ffff04ff29ffff04ff57ffff04ffff0bff2cff81b980ffff04ff59ff80808080808080ff81b78080ff8080ff0180ffff04ff17ffff04ff05ffff04ff8202ffffff04ffff04ffff04ff24ffff04ffff0bff7cff2fff82017f80ff808080ffff04ffff04ff30ffff04ffff0bff81bfffff0bff7cff15ffff10ff82017fffff11ff8202dfff2b80ff8202ff808080ff808080ff138080ff80808080808080808080ff018080ffff04ffff01a072dec062874cd4d3aab892a0906688a1ae412b0109982e1797a170add88bdcdcffff04ffff01a0625c2184e97576f5df1be46c15b2b8771c79e4e6f0aa42d3bfecaebe733f4b8cffff04ffff01ff01ffff33ff80ff818fffff02ffff01ff02ffff01ff04ffff04ff04ffff04ff05ffff04ffff02ff06ffff04ff02ffff04ff82027fff80808080ff80808080ffff02ff82027fffff04ff0bffff04ff17ffff04ff2fffff04ff5fffff04ff81bfff82057f80808080808080ffff04ffff01ff31ff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff06ffff04ff02ffff04ff09ff80808080ffff02ff06ffff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff018080ffff04ffff01b0add4758d972b7c2bd84798749ee2094c0c9e52b5b6618c985d4a8e841bf464a4079efa01e372d2307b6c26e6d1cceae6ff018080ffffff02ffff01ff02ffff03ff2fffff01ff0880ffff01ff02ffff03ffff09ff2dff0280ff80ffff01ff088080ff018080ff0180ffff04ffff01a0e3b0c44298fc1c149afbf4c8996fb92400000000000000000000000000000001ff018080ff808080ffff33ffa061d991a08c7710e63d7b33a7bce71c35e2beae92ec2d6e4e73f145213f7c6c1eff8203e8ffffa061d991a08c7710e63d7b33a7bce71c35e2beae92ec2d6e4e73f145213f7c6c1e808080ff0180808080", "solution": "0xff80ff80ffa047b35ae2e40efb241d448d4d204c5863bf7f9a9bde8f592463e1d338c552d1d0ffffa008c9deaebde797c0ba01fd5670830ea285946297c0f4d311ddf5ec81dee3f37bffa005b5edf5086b2f9dc3c7ccf1e73df9702d0942c76c7e142059be1da061ea5835ff8203e880ffffa008c9deaebde797c0ba01fd5670830ea285946297c0f4d311ddf5ec81dee3f37bffa05b83e15d82e76a70da004e10f41de4079c1239bd1e83c1ff29f0ba26ccd3cb49ff8203e880ff80ff8080"}]';
  var l = jsonDecode(coinSpendsJson) as Iterable;
  final spends = List<CoinSpend>.from(l.map<CoinSpend>((dynamic model)=> CoinSpend.fromJson(model as Map<String, dynamic>)));
  final signatures = <JacobianPoint>[];
  for(final spend in spends) {
    final result = spend.puzzleReveal.run(spend.solution);

    final addsigmessage = walletService.getAddSigMeMessageFromResult(result.program, spend.coin);

    final synthSecretKey = calculateSyntheticPrivateKey(privateKey);
    final signature = AugSchemeMPL.sign(synthSecretKey, addsigmessage.toUint8List());
    signatures.add(signature);
  }
  final aggregate = AugSchemeMPL.aggregate(signatures);
  final spendBundle = SpendBundle(coinSpends: spends, aggregatedSignature: aggregate);
  
}