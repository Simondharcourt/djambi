import 'package:flame/extensions.dart';
import 'package:flame_svg/svg.dart';
import 'package:flutter/material.dart';

import '../../models/cell.dart';
import '../../models/common.dart';
import '../dimensions.dart';
import '../extensions.dart';
import '../settings.dart';
import '../theme.dart';

class BackgroundRenderer {
  GameTheme get _gameTheme => AppearanceSettings.instance.gameTheme;
  PieceTheme get _pieceTheme => AppearanceSettings.instance.pieceTheme;

  late final Svg _mazeImage;

  Future<void> onLoad() async {
    _mazeImage = await Utils.loadImage(Role.chief.name, _gameTheme.mazeForeColor);
  }

  void render(Canvas canvas) {
    _paintBackground(canvas);
    _drawMaze(canvas);
    if (AppearanceSettings.instance.drawLines) {
      _drawLines(canvas);
    }
    _writeIndexes(canvas);
  }

  void _paintBackground(Canvas canvas) {
    // paint margin background
    canvas.drawRect(Dimensions.boardSize.toRect(), _gameTheme.marginPaint);
    // paint cells background
    for (final cell in Cell.allCells()) {
      canvas.drawRect(
          Dimensions.cellOffset(cell) & Dimensions.cellSize,
          cell.isDark ? _gameTheme.darkCellPaint : _gameTheme.lightCellPaint
      );
    }
  }

  void _drawMaze(Canvas canvas) {
    canvas.drawRect(Dimensions.mazeOffset & Dimensions.cellSize, _gameTheme.mazePaint);
    if (_pieceTheme == PieceTheme.classic) {
      _drawChiefClassicImage(canvas);
    } else {
      _drawChiefSymbol(canvas);
    }
  }

  void _drawLines(Canvas canvas) {
    // margins
    canvas.drawLine(Offset.zero, Offset(Dimensions.boardSize.x, 0), _gameTheme.linePaint);
    canvas.drawLine(Offset.zero, Offset(0, Dimensions.boardSize.y), _gameTheme.linePaint);
    // draw 10 vertical/horizontal lines with board height/width
    for (int i = 0; i <= Constants.boardSize; i++) {
      final d = Dimensions.margin + i * Dimensions.cellSide;
      canvas.drawLine(Offset(d, 0), Offset(d, Dimensions.boardSize.y), _gameTheme.linePaint);
      canvas.drawLine(Offset(0, d), Offset(Dimensions.boardSize.x, d), _gameTheme.linePaint);
    }
  }

  void _writeIndexes(Canvas canvas) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void writeText(String text, Offset cellOffset, Vector2 cellSize) {
      textPainter.text = TextSpan(style: _gameTheme.marginTextStyle, text: text);
      textPainter.layout();
      final cellCenter = (cellSize - textPainter.size.toVector2()) / 2;
      textPainter.paint(canvas, cellOffset + cellCenter.toOffset());
    }

    for (int i = 0; i < Constants.boardSize; i++) {
      final d = Dimensions.margin + i * Dimensions.cellSide;
      writeText(Cell.cols[i], Offset(d, 0), Dimensions.marginColCell);
      writeText(Cell.rows[i], Offset(0, d), Dimensions.marginRowCell);
    }
  }

  void _drawChiefClassicImage(Canvas canvas) {
    final offset = Dimensions.mazeCentralOffset.toOffset();
    final vector = offset.toVector2() - Vector2.all(Dimensions.pieceRadius);
    _mazeImage.renderPosition(canvas, vector, Dimensions.pieceSize);
  }

  void _drawChiefSymbol(Canvas canvas) {
    final offset = Dimensions.mazeCentralOffset.toOffset();
    final style = _gameTheme.pieceSymbolStyle.copyWith(color: _gameTheme.mazeForeColor);
    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(style: style, text: Role.chief.name[0].toUpperCase());
    textPainter.layout();
    textPainter.paint(canvas, offset + textPainter.size.toOffset() / -2);
  }
}
