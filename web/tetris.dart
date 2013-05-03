library tetris;

import 'dart:html';
import 'dart:async';
import 'dart:math';

part "matrix.dart";

final CanvasElement canvas = query("#target") as CanvasElement;
final CanvasRenderingContext2D context = 
  canvas.getContext("2d") as CanvasRenderingContext2D;

final InputElement paintButton = query("#paint") as InputElement;
final InputElement clearButton = query("#clear") as InputElement;

final List<Matrix> blockPatterns = [
  new Matrix([
     [1, 1],
     [0, 1],
     [0, 1]
  ]),
  new Matrix([
    [1, 1],
    [1, 0],
    [1, 0]
  ]),
  new Matrix([
     [1, 1],
     [1, 1],
  ]),
  new Matrix([
    [1, 0],
    [1, 1],
    [1, 0]
  ]),
  new Matrix([
    [1, 0],
    [1, 1],
    [0, 1]
  ]),
  new Matrix([
    [0, 1],
    [1, 1],
    [1, 0]
  ]),
  new Matrix([
    [1],
    [1],
    [1],
    [1]
  ])
];

Matrix block;

int posX = 0, posY = 0;

int mapWidth = 10, mapHeight = 20;

Matrix map;

final Random random = new Random();

void main() {
  map = new Matrix(new List.generate(mapHeight,
          (i) => new List.generate(mapWidth,
                  (i) => 0, growable:true), growable:true));
  
  block = blockPatterns[random.nextInt(blockPatterns.length)];
  
  document.onKeyDown.listen((KeyboardEvent e) {
    onKeyDown(e.keyCode);
  });
  
  new Timer.periodic(new Duration(milliseconds: 200), paint);
}

void paint(Timer timer) {
  context.clearRect(0, 0, 200, 400);
  block.paint(posX, posY, "rgb(255, 0, 0)");
  map.paint(0, 0, "rgb(128, 128, 128)");
  
  if (map.isNotAccumulated(block, posX, posY + 1)) {
    posY = posY + 1;
  } else {
    map.merge(block, posX, posY);
    map.clearRows();
    posX = posY = 0;
    block = blockPatterns[random.nextInt(blockPatterns.length)];
  }
}

void onKeyDown(int keyCode) {
  switch (keyCode) {
    case 38:
      if (!map.isNotAccumulated(block.rotate(), posX, posY)) {
        return;
      }
      block = block.rotate();
      break;
    case 39:
      if (!map.isNotAccumulated(block, posX + 1, posY)) {
        return;
      }
      posX++;
      break;
    case 37:
      if (!map.isNotAccumulated(block, posX - 1, posY)) {
        return;
      }
      posX--;
      break;
    case 40:
      var y = posY;
//      while(map.isNotAccumulated(block, posX, y)) {
//        y++;
//      }
      posY = y + 1;
      break;
    default:
      return;
  }
  
  context.clearRect(0, 0, 200, 400);
  
  block.paint(posX, posY, "rgb(255, 0, 0)");
  map.paint(0, 0, "rgb(128, 128, 128)");
}