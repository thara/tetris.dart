part of tetris;

class Matrix {
  
  final List<List<int>> matrix;
  
  final int height;
  final int width;
  
  Matrix(List<List<int>> matrix)
    : this.matrix = matrix,
      this.height = matrix.length,
      this.width = matrix[0].length;
  
  void each(void f(int index, List<int> row)) {
    matrix.asMap().forEach(f);
  }
  
  int get(int y, int x) {
    if (0 <= y && y < matrix.length && 0 <= x && x < matrix[y].length) {
      return matrix[y][x];
    } else {
      return 0;
    }
  }
  
  void paint(int offsetX, int offsetY, String color) {
    context.fillStyle = color;
    matrix.asMap().forEach((int y, List<int> row) {
      row.asMap().forEach((int x, int val) {
        if (val > 0) {
          context.fillRect((x + offsetX) * 20, (y + offsetY) * 20, 20, 20);
        }
      });
    });
  }
  
  bool isNotAccumulated(Matrix block, int offsetX, int offsetY) {
    
    if (offsetX < 0 || offsetY < 0 ||
        height < offsetY + block.height ||
        width < offsetX + block.width) {
      return false;
    }
    
    var ok = true;
    block.each((int y, List<int> row) {
      row.asMap().forEach((int x, int val) {
        if (val > 0 && matrix[y + offsetY][x + offsetX] > 0) {
          ok = false;
        }
      });
    }); 
    return ok;
  }
  
  void merge(Matrix block, int offsetX, int offsetY) {
    matrix.asMap().forEach((int y, List<int> row) {
      row.asMap().forEach((int x, int val) {
        row[x] += block.get(y - offsetY, x - offsetX);
        
        if (block.get(y - offsetY, x - offsetX) > 0) {
          print("${y - offsetY}, ${x - offsetX}");
        }
      });
    });
  }
  
  void clearRows() {
    for (var y = 0; y < height; y++) {
      var full = true;
      for (var x = 0; x < width; x++) {
        if (matrix[y][x] <= 0) {
          full = false;
        }
      }
      if (full) {
        matrix.removeAt(y);
        var newRow = new List.filled(width, 0);
        matrix.insert(0, newRow);
      }
    }
  }
  
  Matrix rotate() {
    var block = matrix;
    return new Matrix(new List<List<int>>.generate(block[0].length, (y) {
      return new List<int>.generate(block.length, (x) => block[block.length - x - 1][y], growable:true);
    }, growable:true));
  }
}