import 'package:chia_utils/chia_crypto_utils.dart';
import 'package:chia_utils/src/core/models/conditions/condition.dart';
import 'package:chia_utils/src/standard/exceptions/invalid_condition_cast_exception.dart';

class AssertMyCoinIdCondition implements Condition {
  static int conditionCode = 70;

  Puzzlehash coinId;

  AssertMyCoinIdCondition(this.coinId);

  factory AssertMyCoinIdCondition.fromProgram(Program program) {
    final programList = program.toList();
    if (!isThisCondition(program)) {
      throw InvalidConditionCastException(AssertMyCoinIdCondition);
    }
    return AssertMyCoinIdCondition(Puzzlehash(programList[1].atom));
  }

  @override
  Program get program {
    return Program.list([
      Program.fromInt(conditionCode),
      Program.fromBytes(coinId.bytes),
    ]);
  }

  static bool isThisCondition(Program condition) {
    final conditionParts = condition.toList();
    if (conditionParts.length != 2) {
      return false;
    }
    if (conditionParts[0].toInt() != conditionCode) {
      return false;
    }
    return true;
  }
}