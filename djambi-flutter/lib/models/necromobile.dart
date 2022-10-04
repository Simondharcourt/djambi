import 'common.dart';
import 'member.dart';

class Necromobile extends Member {
  Necromobile(super.parliament, super.ideology);

  @override
  Role get role => Role.necromobile;

  @override
  Iterable<Cell> canMoveTo() => super.canMoveTo().where((cell) {
        final member = parliament.getMemberAt(cell);
        // empty non maze cell or dead member
        return (member == null && !cell.isMaze) || (member != null && member.isDead);
      });
}
