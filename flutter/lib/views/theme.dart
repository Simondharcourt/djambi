import 'package:flutter/material.dart';

import '../models/common.dart';

enum PieceTheme {
  classic,
  characters,
}

abstract class BoardTheme {
  // margins
  Paint get marginPaint;
  TextStyle get marginTextStyle;
  // background
  Paint get lightCellPaint;
  Paint get darkCellPaint;
  bool get drawLines;
  Paint get linePaint;
  // maze
  Paint get mazePaint;
  Color get mazeForeColor;
  // pieces
  Color get pieceForeColor;
  Paint get pieceEdgePaint;
  TextStyle get pieceSymbolStyle;
  Paint get deadPaint;
  Paint get selectableMarkPaint;
  Paint get selectedMarkPaint;
  Paint get actionMarkPaint;
  Paint get movedMarkPaint;
  // parties
  Paint getPartyPaint(Ideology ideology);
}

class DefaultBoardTheme extends BoardTheme {
  @override
  Paint get marginPaint => Paint()..color = Colors.grey.shade600;

  @override
  TextStyle get marginTextStyle => const TextStyle(
      color: Colors.white, fontSize: 300, fontWeight: FontWeight.bold);

  @override
  Paint get lightCellPaint => Paint()..color = Colors.white;

  @override
  Paint get darkCellPaint => Paint()..color = Colors.grey.shade300;

  @override
  bool get drawLines => false;

  @override
  Paint get linePaint => Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke;

  @override
  Paint get mazePaint => Paint()..color = Colors.black;

  @override
  Color get mazeForeColor => Colors.grey.shade300;

  @override
  Color get pieceForeColor => Colors.black;

  @override
  Paint get pieceEdgePaint => Paint()
    ..color = pieceForeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 22;

  @override
  TextStyle get pieceSymbolStyle => TextStyle(
      color: pieceForeColor, fontSize: 500, fontWeight: FontWeight.bold);

  @override
  Paint get deadPaint => Paint()..color = Colors.grey.shade600;

  @override
  Paint get selectableMarkPaint => Paint()..color = Colors.grey.shade600;

  @override
  Paint get selectedMarkPaint => Paint()..color = Colors.purpleAccent.shade100;

  @override
  Paint get actionMarkPaint => Paint()..color = Colors.grey.shade600;

  @override
  Paint get movedMarkPaint => Paint()..color = Colors.brown.shade200;

  @override
  Paint getPartyPaint(Ideology ideology) {
    const partyColors = [
      Colors.red,       // Ideology.red
      Colors.blue,      // Ideology.blue
      Colors.orange,    // Ideology.yellow
      Colors.green,     // Ideology.green
    ];

    return Paint()..color = partyColors[ideology.index];
  }
}
