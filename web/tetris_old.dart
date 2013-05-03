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

var blockPatterns = [
  [
     [1, 1],
     [0, 1],
     [0, 1]
   ],
   [
    [1, 1],
    [1, 0],
    [1, 0]
   ],
   [
     [1, 1],
     [1, 1],
   ],
   [
    [1, 0],
    [1, 1],
    [1, 0]
   ],
   [
    [1, 0],
    [1, 1],
    [0, 1]
   ],
   [
    [0, 1],
    [1, 1],
    [1, 0]
   ],
   [
    [1],
    [1],
    [1],
    [1]
   ]
];

List<List<int>> block;

int posX = 0, posY = 0;

int mapWidth = 10, mapHeight = 20;

List<List<int>> map;

final Random random = new Random();

void main() {
  map = new List.generate(mapHeight,
          (i) => new List.generate(mapWidth,
                  (i) => 0, growable:true), growable:true);
  
  block = blockPatterns[random.nextInt(blockPatterns.length)];
  
  document.onKeyDown.listen((KeyboardEvent e) {
    onKeyDown(e.keyCode);
  });
  
  new Timer.periodic(new Duration(milliseconds: 200), paint);
}

void paint(Timer timer) {
  context.clearRect(0, 0, 200, 400);
  paintMatrix(map, 0, 0, "rgb(128, 128, 128)");
  paintMatrix(block, posX, posY, "rgb(255, 0, 0)");
  
  if (isNotAccumulated(map, block, posX, posY + 1)) {
    posY = posY + 1;
  } else {
    mergeMatrix(map, block, posX, posY);
    clearRows(map);
    posX = posY = 0;
    block = blockPatterns[random.nextInt(blockPatterns.length)];
  }
}

void paintMatrix(List<List<int>> matrix, int offsetX, int offsetY, String color) {
  context.fillStyle = color;
  for (var y = 0; y < matrix.length; y++) {
    for (var x = 0; x < matrix[y].length; x++) {
      if (matrix[y][x] > 0) {
        context.fillRect((x + offsetX) * 20, (y + offsetY) * 20, 20, 20);
      }
    }
  }
}

bool isNotAccumulated(
  List<List<int>> map, List<List<int>> block, int offsetX, int offsetY) {
  
  if (offsetX < 0 || offsetY < 0 ||
      mapHeight < offsetY + block.length ||
      mapWidth < offsetX + block[0].length) {
    return false;
  }
  
  for (var y = 0; y < block.length; y++) {
    for (var x = 0; x < block[y].length; x++) {
      if (block[y][x] > 0 && map[y + offsetY][x + offsetX] > 0) {
        return false;
      }
    }
  }
  
  return true;
}

void mergeMatrix(
  List<List<int>> map, List<List<int>> block, int offsetX, int offsetY) {
  for (var y = 0; y < mapHeight; y++) {
    for (var x = 0; x < mapWidth; x++) {
      if (0 <= y - offsetY && y - offsetY < block.length &&
          0 <= x - offsetX && x - offsetX < block[y - offsetY].length &&
          block[y - offsetY][x - offsetX] > 0) {
        map[y][x]++;
      }
    }
  }
}

void onKeyDown(int keyCode) {
  switch (keyCode) {
    case 38:
      if (!isNotAccumulated(map, rotate(block), posX, posY)) {
        return;
      }
      block = rotate(block);
      break;
    case 39:
      if (!isNotAccumulated(map, block, posX + 1, posY)) {
        return;
      }
      posX++;
      break;
    case 37:
      if (!isNotAccumulated(map, block, posX - 1, posY)) {
        return;
      }
      posX--;
      break;
    case 40:
      var y = posY;
//      while(isNotAccumulated(map, block, posX, y)) {
//        y++;
//      }
      posY = y + 1;
      break;
    default:
      return;
  }
  
  context.clearRect(0, 0, 200, 400);
  paintMatrix(block, posX, posY, "rgb(255, 0, 0)");
  paintMatrix(map, 0, 0, "rgb(128, 128, 128)");
}

List<List<int>> rotate(List<List<int>> block) {
  return new List<List<int>>.generate(block[0].length, (y) {
    return new List<int>.generate(block.length, (x) => block[block.length - x - 1][y], growable:true);
  }, growable:true);
//  
//  var rotated = new List<List<int>>(block[0].length);
//  for (var x = 0; x < block[0].length; x++) {
//    rotated[x] = new List.filled(block.length, 0);
//    for (var y = 0; y < block.length; y++) {
//      rotated[x][block.length - y - 1] = block[y][x];
//    }
//  }
//  return rotated;
}

void clearRows(List<List<int>> map) {
  
  for (var y = 0; y < mapHeight; y++) {
    var full = true;
    for (var x = 0; x < mapWidth; x++) {
      if (map[y][x] <= 0) {
        full = false;
      }
    }
    if (full) {
      map.removeAt(y);
      var newRow = new List.filled(mapWidth, 0);
      map.insert(0, newRow);
    }
  }
}