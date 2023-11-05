abstract class Constants {
  static const int boardSize = 9;
  static const int mazeIndex = boardSize ~/ 2;
}

// order is important
enum Ideology {
  red,
  blue,
  yellow,
  green,
  ;

  Ideology get next => Ideology.values[(index + 1) % 4];
  Ideology get previous => Ideology.values[(index + 3) % 4];
}

enum TurnDirection {
  anticlockwise,
  clockwise,
  ;

  Ideology next(Ideology ideology) =>
      this == anticlockwise ? ideology.next : ideology.previous;
}

enum Role {
  chief,
  assassin,
  reporter,
  diplomat,
  necromobile,
  militant,
}

// represent which stage of the manoeuvre is finished
enum Manoeuvre {
  none,
  move,
  kill,
  exit,
  end,
}
