import 'package:collection/collection.dart';

import 'cell.dart';
import 'common.dart';
import 'member.dart';
import 'party.dart';

class Parliament {
  late final List<Member> members;
  Member? getMemberAt(Cell cell) => members.firstWhereOrNull((m) => m.location == cell);
  bool isEmpty(Cell cell) => !members.any((m) => m.location == cell);

  late final List<Party> parties;
  Party getParty(Ideology ideology) => parties.firstWhere((p) => p.ideology == ideology);
  Party? getPartyInPower() => parties.firstWhereOrNull((p) => p.chief.location.isMaze && p.chief.isAlive);
  Iterable<Party> get activeParties => parties.where((p) => p.isActive);
  bool get isGameFinished => activeParties.length == 1;

  // make sure there is one actor or zero
  Member? getActor() => members.cast<Member?>()
      .singleWhere((m) => m!.manoeuvre != Manoeuvre.none, orElse: () => null);

  late Ideology _currentIdeology;
  late Party _currentParty;
  Party get currentParty => _currentParty;

  String get sign => "${currentParty.ideology.name[0]}:${members.map((m) => m.sign).join()}";

  Parliament() {
    // create members
    members = Ideology.values.map((id) => _recruitMembers(id)).flattened.toList();
    assert(members.length == 9 * 4);
    _setInitialPositions();
    // create parties
    parties = members.where((m) => m.role == Role.chief).map((m) => Party(m)).toList();
    assert(parties.length == 4);
    // other properties
    _currentIdeology = Ideology.first;
    _currentParty = getParty(_currentIdeology);
  }
  Parliament.copy(Parliament other) {
    // copy members
    members = other.members.map((m) => Member.copy(this, m)).toList();
    assert(members.length == 9 * 4);
    // copy parties
    parties = members.where((m) => m.role == Role.chief).map((m) => Party(m)).toList();
    assert(parties.length == 4);
    // other properties
    _currentIdeology = other._currentIdeology;
    _currentParty = getParty(other._currentParty.ideology);
  }

  Parliament makeCopy() => Parliament.copy(this);

  Iterable<Member> _recruitMembers(Ideology ideology) sync* {
    final roles = [
      [ Role.chief,    Role.assassin, Role.militant    ],
      [ Role.reporter, Role.diplomat, Role.militant    ],
      [ Role.militant, Role.militant, Role.necromobile ],
    ];

    // create members and place them around (0,0) point, so it is easier to rotate or flip
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final int id = (ideology.index * Constants.boardSize) + (r * 3) + c;
        yield Member.create(this, roles[r][c], ideology, id)
          ..location = Cell(c - 1, r - 1);
      }
    }
  }

  void _setInitialPositions() {
    void setInitPosition(Ideology ideology, Cell scale, Cell translation) {
      for (final m in members.where((m) => m.ideology == ideology)) {
        m.location = m.location * scale + translation;
      }
    }
    setInitPosition(Ideology.red,    const Cell( 1, -1), const Cell(1, 7));
    setInitPosition(Ideology.blue,   const Cell(-1, -1), const Cell(7, 7));
    setInitPosition(Ideology.yellow, const Cell(-1,  1), const Cell(7, 1));
    setInitPosition(Ideology.green,  const Cell( 1,  1), const Cell(1, 1));
  }

  Party _getNextParty() {
    final partyInPower = getPartyInPower();
    Party? party;
    // check if there is a party in power
    if (partyInPower == null) {
      // no party is in power, so just
      // find next ideology in turn but skip lost/dead parties
      do {
        _currentIdeology = _currentIdeology.next;
        party = getParty(_currentIdeology);
      } while (party.isLost);
      return party;
    }
    // else: there is a party in power
    // check if current is not the party in power
    if (currentParty != partyInPower) {
      return partyInPower;
    }
    // else: current ideology is in power, so
    // find next ideology in turn but skip lost/dead parties and
    // skip the party in power if there is more then 2 active parties
    do {
      _currentIdeology = _currentIdeology.next;
      party = getParty(_currentIdeology);
    } while (party.isLost || (activeParties.length > 2 && _currentIdeology == partyInPower.ideology));
    return party;
  }

  void _nextTurn() {
    _currentParty = _getNextParty();
  }

  void act(Member member, Cell cell) {
    if (isGameFinished) {
      return;
    }
    var actor = getActor();
    if (actor == null) {
      if (member.ideology != currentParty.ideology) {
        throw StateError("Selected member is not from current turn party");
      }
      actor = member;
    } else if (actor != member) {
      throw StateError("Current actor is not the selected member");
    }
    // do an action
    actor.act(cell);
    // if current manoeuvre is finished, move to next turn/player
    if (actor.manoeuvre == Manoeuvre.end) {
      actor.manoeuvre = Manoeuvre.none;
      _nextTurn();
    }
  }
}
