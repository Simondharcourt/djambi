import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';

import '../cell.dart';
import '../common.dart';
import '../member.dart';
import '../parliament.dart';
import 'evaluation.dart';

class Node {
  Node(this.parliament, this.depth);

  final Parliament parliament;
  bool get isManoeuvreCompleted => parliament.actor == null;

  final int depth;
  List<Node> subNodes = [];
  Node? _bestSubNode;
  Map<Ideology, int> _evaluations = {};

  Node get bestSubNode => _bestSubNode ?? this;

  void evaluate(StateEvaluator evaluator) {
    assert(subNodes.isEmpty, "evaluate should run on leaf nodes only");
    assert(parliament.actor == null, "As maneuver is finished, there should be no actor");
    _evaluations = { for (final p in parliament.parties) p.ideology: evaluator.evaluate(p) };
  }

  Iterable<Tuple2<Member, Cell>> availableActions() sync* {
    final Iterable<Member> members = isManoeuvreCompleted ? parliament.currentParty.aliveMembers : [parliament.actor!];
    for (final member in members) {
      for (final cell in member.cellsToAct()) {
        yield Tuple2(member, cell);
      }
    }
  }

  void calcMaxN() {
    assert(_evaluations.isEmpty, "evaluations is expected to be empty");
    assert(subNodes.isNotEmpty, "should run on NONE leaf nodes");
    int max = -999999999999999;
    Map<Ideology, int>? evaluations;
    Node? bestSub;
    for (Node sub in subNodes) {
      int nodeValue = sub._evaluations[parliament.currentParty.ideology]!;
      int subMax = sub._evaluations.values.map((v) => nodeValue - v).sum;
      if (subMax > max) {
        max = subMax;
        evaluations = sub._evaluations;
        bestSub = sub.isManoeuvreCompleted ? sub : sub.bestSubNode;
      }
    }
    _evaluations = evaluations!;
    _bestSubNode = bestSub;
  }
}

class Tree {
  Tree(Parliament parliament, this.maxDepth): _root = Node(parliament, 0);

  final Node _root;
  final int maxDepth;
  final StateEvaluator evaluator = const DefaultEvaluator();
  final Set<String> visitedNodes = {};

  Node get decision => _root.bestSubNode;

  void build() {
    visitedNodes.add(_root.parliament.sign);
    _createSubNodes(_root);
  }

  void _createSubNodes(Node node) {
    assert (node.depth <= maxDepth, "Exceed the maximum depth!");
    if (node.parliament.isGameFinished || node.depth == maxDepth) {
      node.evaluate(evaluator);
    } else {
      for (final action in node.availableActions()) {
        _doAction(node, action.item1, action.item2);
      }
      // calc max^n
      node.calcMaxN();
    }
  }

  void _doAction(Node node, Member member, Cell cell) {
    final copyParliament = node.parliament.makeCopy();
    copyParliament.act(member.id, cell);
    if (!visitedNodes.add(copyParliament.sign)) {
      // skip as the node is already visited before
      // print("skip: $member => $cell");
      return;
    }
    int depth = node.depth;
    if (copyParliament.actor == null) {
      depth++;
      // print("${'--- ' * depth} do action: $member => $cell");
    }
    final subNode = Node(copyParliament, depth);
    node.subNodes.add(subNode);
    _createSubNodes(subNode);
  }
}
