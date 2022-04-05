import 'dart:convert';

import 'package:chia_utils/chia_crypto_utils.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  // serialized spendbundle from CAT-admin-tool
  const spendBundleSerializedHex = '000000024c51ae3b978a03024fa4f1b53a5b9bf30c9edafc9d47e72a9cc41b58768373bd2668d136b5b5bab998ca966b05750172c0d853f0dd37f2653e0ff9ba37b3377e000000d18c2c2bccff02ffff01ff02ffff01ff02ffff03ff0bffff01ff02ffff03ffff09ff05ffff1dff0bffff1effff0bff0bffff02ff06ffff04ff02ffff04ff17ff8080808080808080ffff01ff02ff17ff2f80ffff01ff088080ff0180ffff01ff04ffff04ff04ffff04ff05ffff04ffff02ff06ffff04ff02ffff04ff17ff80808080ff80808080ffff02ff17ff2f808080ff0180ffff04ffff01ff32ff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff06ffff04ff02ffff04ff09ff80808080ffff02ff06ffff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff018080ffff04ffff01b0a1a7af6fae2dd8f6b6b80cac601f25ea116ece416b3af96303a1858c18d4c3d8738e6135385d3125ddaf1c18cc6e702dff018080ff80ffff01ffff33ffa01c2121e077ca2d57e3a447718fa42c3064bdf13bc7bf07bb3f39d084beb8c23eff82271080ffff33ffa0bee26c7bd6ff40acde47ceca5338b0d1cb098d3d7c939ba2e00489f3edd5fbd1ff8600d18c2c04bc80ffff3cffa06872470ed8253f2a910134f839de55391e49f8fa3af9c6aff1289a0633617afe8080ff80807f4f681abcc8e76b9f816a9cecf2baf23178b01882a74fced57c1428beceec331c2121e077ca2d57e3a447718fa42c3064bdf13bc7bf07bb3f39d084beb8c23e0000000000002710ff02ffff01ff02ffff01ff02ff5effff04ff02ffff04ffff04ff05ffff04ffff0bff2cff0580ffff04ff0bff80808080ffff04ffff02ff17ff2f80ffff04ff5fffff04ffff02ff2effff04ff02ffff04ff17ff80808080ffff04ffff0bff82027fff82057fff820b7f80ffff04ff81bfffff04ff82017fffff04ff8202ffffff04ff8205ffffff04ff820bffff80808080808080808080808080ffff04ffff01ffffffff81ca3dff46ff0233ffff3c04ff01ff0181cbffffff02ff02ffff03ff05ffff01ff02ff32ffff04ff02ffff04ff0dffff04ffff0bff22ffff0bff2cff3480ffff0bff22ffff0bff22ffff0bff2cff5c80ff0980ffff0bff22ff0bffff0bff2cff8080808080ff8080808080ffff010b80ff0180ffff02ffff03ff0bffff01ff02ffff03ffff09ffff02ff2effff04ff02ffff04ff13ff80808080ff820b9f80ffff01ff02ff26ffff04ff02ffff04ffff02ff13ffff04ff5fffff04ff17ffff04ff2fffff04ff81bfffff04ff82017fffff04ff1bff8080808080808080ffff04ff82017fff8080808080ffff01ff088080ff0180ffff01ff02ffff03ff17ffff01ff02ffff03ffff20ff81bf80ffff0182017fffff01ff088080ff0180ffff01ff088080ff018080ff0180ffff04ffff04ff05ff2780ffff04ffff10ff0bff5780ff778080ff02ffff03ff05ffff01ff02ffff03ffff09ffff02ffff03ffff09ff11ff7880ffff0159ff8080ff0180ffff01818f80ffff01ff02ff7affff04ff02ffff04ff0dffff04ff0bffff04ffff04ff81b9ff82017980ff808080808080ffff01ff02ff5affff04ff02ffff04ffff02ffff03ffff09ff11ff7880ffff01ff04ff78ffff04ffff02ff36ffff04ff02ffff04ff13ffff04ff29ffff04ffff0bff2cff5b80ffff04ff2bff80808080808080ff398080ffff01ff02ffff03ffff09ff11ff2480ffff01ff04ff24ffff04ffff0bff20ff2980ff398080ffff010980ff018080ff0180ffff04ffff02ffff03ffff09ff11ff7880ffff0159ff8080ff0180ffff04ffff02ff7affff04ff02ffff04ff0dffff04ff0bffff04ff17ff808080808080ff80808080808080ff0180ffff01ff04ff80ffff04ff80ff17808080ff0180ffffff02ffff03ff05ffff01ff04ff09ffff02ff26ffff04ff02ffff04ff0dffff04ff0bff808080808080ffff010b80ff0180ff0bff22ffff0bff2cff5880ffff0bff22ffff0bff22ffff0bff2cff5c80ff0580ffff0bff22ffff02ff32ffff04ff02ffff04ff07ffff04ffff0bff2cff2c80ff8080808080ffff0bff2cff8080808080ffff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff2effff04ff02ffff04ff09ff80808080ffff02ff2effff04ff02ffff04ff0dff8080808080ffff01ff0bff2cff058080ff0180ffff04ffff04ff28ffff04ff5fff808080ffff02ff7effff04ff02ffff04ffff04ffff04ff2fff0580ffff04ff5fff82017f8080ffff04ffff02ff7affff04ff02ffff04ff0bffff04ff05ffff01ff808080808080ffff04ff17ffff04ff81bfffff04ff82017fffff04ffff0bff8204ffffff02ff36ffff04ff02ffff04ff09ffff04ff820affffff04ffff0bff2cff2d80ffff04ff15ff80808080808080ff8216ff80ffff04ff8205ffffff04ff820bffff808080808080808080808080ff02ff2affff04ff02ffff04ff5fffff04ff3bffff04ffff02ffff03ff17ffff01ff09ff2dffff0bff27ffff02ff36ffff04ff02ffff04ff29ffff04ff57ffff04ffff0bff2cff81b980ffff04ff59ff80808080808080ff81b78080ff8080ff0180ffff04ff17ffff04ff05ffff04ff8202ffffff04ffff04ffff04ff24ffff04ffff0bff7cff2fff82017f80ff808080ffff04ffff04ff30ffff04ffff0bff81bfffff0bff7cff15ffff10ff82017fffff11ff8202dfff2b80ff8202ff808080ff808080ff138080ff80808080808080808080ff018080ffff04ffff01a072dec062874cd4d3aab892a0906688a1ae412b0109982e1797a170add88bdcdcffff04ffff01a0625c2184e97576f5df1be46c15b2b8771c79e4e6f0aa42d3bfecaebe733f4b8cffff04ffff01ff01ffff33ff80ff818fffff02ffff01ff02ffff01ff04ffff04ff04ffff04ff05ffff04ffff02ff06ffff04ff02ffff04ff82027fff80808080ff80808080ffff02ff82027fffff04ff0bffff04ff17ffff04ff2fffff04ff5fffff04ff81bfff82057f80808080808080ffff04ffff01ff31ff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff06ffff04ff02ffff04ff09ff80808080ffff02ff06ffff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff018080ffff04ffff01b0add4758d972b7c2bd84798749ee2094c0c9e52b5b6618c985d4a8e841bf464a4079efa01e372d2307b6c26e6d1cceae6ff018080ffffff02ffff01ff02ffff03ff2fffff01ff0880ffff01ff02ffff03ffff09ff2dff0280ff80ffff01ff088080ff018080ff0180ffff04ffff01a026081b15441311d9a207a078b650a05766975814fd5aa6935a759ddaf2a05af0ff018080ff808080ffff33ffa00b7a3d5e723e0b046fd51f95cabf2d3e2616f05d9d1833e8166052b43d9454adff822710ffffa00b7a3d5e723e0b046fd51f95cabf2d3e2616f05d9d1833e8166052b43d9454ad808080ff0180808080ff80ff80ffa0691e1d0bcf9ac53e2c50578c98f96aa3fca155e867dd20f18f3b1830541488f3ffffa07f4f681abcc8e76b9f816a9cecf2baf23178b01882a74fced57c1428beceec33ffa01c2121e077ca2d57e3a447718fa42c3064bdf13bc7bf07bb3f39d084beb8c23eff82271080ffffa07f4f681abcc8e76b9f816a9cecf2baf23178b01882a74fced57c1428beceec33ffa0b0d05bdb7ed1b96763a8cec0a67ad6c76f129da3417f2ea220a62a9858f45e83ff82271080ff80ff8080aeddfb01b15e715d5e467b008a4001d92addaf746d934722b6a2e19685826d29ae4b196027a6e4a6f29817ce7e36e56b01a00ba2f077db8da53c03e6e1d4f206f1ddbe03322e00438b24ab75870ac7627af2f8eed311e0b9de3a56edbcf29fde';
  // json of spendBundle from CAT-admin-tool
  const spendBundleJson = '{"aggregated_signature": "aeddfb01b15e715d5e467b008a4001d92addaf746d934722b6a2e19685826d29ae4b196027a6e4a6f29817ce7e36e56b01a00ba2f077db8da53c03e6e1d4f206f1ddbe03322e00438b24ab75870ac7627af2f8eed311e0b9de3a56edbcf29fde", "coin_solutions": [{"coin": {"parent_coin_info": "0x4c51ae3b978a03024fa4f1b53a5b9bf30c9edafc9d47e72a9cc41b58768373bd", "puzzle_hash": "0x2668d136b5b5bab998ca966b05750172c0d853f0dd37f2653e0ff9ba37b3377e", "amount": 899999869900}, "puzzle_reveal": "0xff02ffff01ff02ffff01ff02ffff03ff0bffff01ff02ffff03ffff09ff05ffff1dff0bffff1effff0bff0bffff02ff06ffff04ff02ffff04ff17ff8080808080808080ffff01ff02ff17ff2f80ffff01ff088080ff0180ffff01ff04ffff04ff04ffff04ff05ffff04ffff02ff06ffff04ff02ffff04ff17ff80808080ff80808080ffff02ff17ff2f808080ff0180ffff04ffff01ff32ff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff06ffff04ff02ffff04ff09ff80808080ffff02ff06ffff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff018080ffff04ffff01b0a1a7af6fae2dd8f6b6b80cac601f25ea116ece416b3af96303a1858c18d4c3d8738e6135385d3125ddaf1c18cc6e702dff018080", "solution": "0xff80ffff01ffff33ffa01c2121e077ca2d57e3a447718fa42c3064bdf13bc7bf07bb3f39d084beb8c23eff82271080ffff33ffa0bee26c7bd6ff40acde47ceca5338b0d1cb098d3d7c939ba2e00489f3edd5fbd1ff8600d18c2c04bc80ffff3cffa06872470ed8253f2a910134f839de55391e49f8fa3af9c6aff1289a0633617afe8080ff8080"}, {"coin": {"parent_coin_info": "0x7f4f681abcc8e76b9f816a9cecf2baf23178b01882a74fced57c1428beceec33", "puzzle_hash": "0x1c2121e077ca2d57e3a447718fa42c3064bdf13bc7bf07bb3f39d084beb8c23e", "amount": 10000}, "puzzle_reveal": "0xff02ffff01ff02ffff01ff02ff5effff04ff02ffff04ffff04ff05ffff04ffff0bff2cff0580ffff04ff0bff80808080ffff04ffff02ff17ff2f80ffff04ff5fffff04ffff02ff2effff04ff02ffff04ff17ff80808080ffff04ffff0bff82027fff82057fff820b7f80ffff04ff81bfffff04ff82017fffff04ff8202ffffff04ff8205ffffff04ff820bffff80808080808080808080808080ffff04ffff01ffffffff81ca3dff46ff0233ffff3c04ff01ff0181cbffffff02ff02ffff03ff05ffff01ff02ff32ffff04ff02ffff04ff0dffff04ffff0bff22ffff0bff2cff3480ffff0bff22ffff0bff22ffff0bff2cff5c80ff0980ffff0bff22ff0bffff0bff2cff8080808080ff8080808080ffff010b80ff0180ffff02ffff03ff0bffff01ff02ffff03ffff09ffff02ff2effff04ff02ffff04ff13ff80808080ff820b9f80ffff01ff02ff26ffff04ff02ffff04ffff02ff13ffff04ff5fffff04ff17ffff04ff2fffff04ff81bfffff04ff82017fffff04ff1bff8080808080808080ffff04ff82017fff8080808080ffff01ff088080ff0180ffff01ff02ffff03ff17ffff01ff02ffff03ffff20ff81bf80ffff0182017fffff01ff088080ff0180ffff01ff088080ff018080ff0180ffff04ffff04ff05ff2780ffff04ffff10ff0bff5780ff778080ff02ffff03ff05ffff01ff02ffff03ffff09ffff02ffff03ffff09ff11ff7880ffff0159ff8080ff0180ffff01818f80ffff01ff02ff7affff04ff02ffff04ff0dffff04ff0bffff04ffff04ff81b9ff82017980ff808080808080ffff01ff02ff5affff04ff02ffff04ffff02ffff03ffff09ff11ff7880ffff01ff04ff78ffff04ffff02ff36ffff04ff02ffff04ff13ffff04ff29ffff04ffff0bff2cff5b80ffff04ff2bff80808080808080ff398080ffff01ff02ffff03ffff09ff11ff2480ffff01ff04ff24ffff04ffff0bff20ff2980ff398080ffff010980ff018080ff0180ffff04ffff02ffff03ffff09ff11ff7880ffff0159ff8080ff0180ffff04ffff02ff7affff04ff02ffff04ff0dffff04ff0bffff04ff17ff808080808080ff80808080808080ff0180ffff01ff04ff80ffff04ff80ff17808080ff0180ffffff02ffff03ff05ffff01ff04ff09ffff02ff26ffff04ff02ffff04ff0dffff04ff0bff808080808080ffff010b80ff0180ff0bff22ffff0bff2cff5880ffff0bff22ffff0bff22ffff0bff2cff5c80ff0580ffff0bff22ffff02ff32ffff04ff02ffff04ff07ffff04ffff0bff2cff2c80ff8080808080ffff0bff2cff8080808080ffff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff2effff04ff02ffff04ff09ff80808080ffff02ff2effff04ff02ffff04ff0dff8080808080ffff01ff0bff2cff058080ff0180ffff04ffff04ff28ffff04ff5fff808080ffff02ff7effff04ff02ffff04ffff04ffff04ff2fff0580ffff04ff5fff82017f8080ffff04ffff02ff7affff04ff02ffff04ff0bffff04ff05ffff01ff808080808080ffff04ff17ffff04ff81bfffff04ff82017fffff04ffff0bff8204ffffff02ff36ffff04ff02ffff04ff09ffff04ff820affffff04ffff0bff2cff2d80ffff04ff15ff80808080808080ff8216ff80ffff04ff8205ffffff04ff820bffff808080808080808080808080ff02ff2affff04ff02ffff04ff5fffff04ff3bffff04ffff02ffff03ff17ffff01ff09ff2dffff0bff27ffff02ff36ffff04ff02ffff04ff29ffff04ff57ffff04ffff0bff2cff81b980ffff04ff59ff80808080808080ff81b78080ff8080ff0180ffff04ff17ffff04ff05ffff04ff8202ffffff04ffff04ffff04ff24ffff04ffff0bff7cff2fff82017f80ff808080ffff04ffff04ff30ffff04ffff0bff81bfffff0bff7cff15ffff10ff82017fffff11ff8202dfff2b80ff8202ff808080ff808080ff138080ff80808080808080808080ff018080ffff04ffff01a072dec062874cd4d3aab892a0906688a1ae412b0109982e1797a170add88bdcdcffff04ffff01a0625c2184e97576f5df1be46c15b2b8771c79e4e6f0aa42d3bfecaebe733f4b8cffff04ffff01ff01ffff33ff80ff818fffff02ffff01ff02ffff01ff04ffff04ff04ffff04ff05ffff04ffff02ff06ffff04ff02ffff04ff82027fff80808080ff80808080ffff02ff82027fffff04ff0bffff04ff17ffff04ff2fffff04ff5fffff04ff81bfff82057f80808080808080ffff04ffff01ff31ff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff06ffff04ff02ffff04ff09ff80808080ffff02ff06ffff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff018080ffff04ffff01b0add4758d972b7c2bd84798749ee2094c0c9e52b5b6618c985d4a8e841bf464a4079efa01e372d2307b6c26e6d1cceae6ff018080ffffff02ffff01ff02ffff03ff2fffff01ff0880ffff01ff02ffff03ffff09ff2dff0280ff80ffff01ff088080ff018080ff0180ffff04ffff01a026081b15441311d9a207a078b650a05766975814fd5aa6935a759ddaf2a05af0ff018080ff808080ffff33ffa00b7a3d5e723e0b046fd51f95cabf2d3e2616f05d9d1833e8166052b43d9454adff822710ffffa00b7a3d5e723e0b046fd51f95cabf2d3e2616f05d9d1833e8166052b43d9454ad808080ff0180808080", "solution": "0xff80ff80ffa0691e1d0bcf9ac53e2c50578c98f96aa3fca155e867dd20f18f3b1830541488f3ffffa07f4f681abcc8e76b9f816a9cecf2baf23178b01882a74fced57c1428beceec33ffa01c2121e077ca2d57e3a447718fa42c3064bdf13bc7bf07bb3f39d084beb8c23eff82271080ffffa07f4f681abcc8e76b9f816a9cecf2baf23178b01882a74fced57c1428beceec33ffa0b0d05bdb7ed1b96763a8cec0a67ad6c76f129da3417f2ea220a62a9858f45e83ff82271080ff80ff8080"}]}';
  final spendBundle = SpendBundle.fromJson(jsonDecode(spendBundleJson) as Map<String, dynamic>);
  
  test('should correctly serialize SpendBundle', () {
    expect(spendBundle.toBytes().toHex(), equals(spendBundleSerializedHex));
  });
}