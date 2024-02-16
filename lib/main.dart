import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Splash Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GridScreen()),
            );
          },
          child: Text('Enter Grid Size'),
        ),
      ),
    );
  }
}

class GridScreen extends StatefulWidget {
  @override
  _GridScreenState createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  int m = 0;
  int n = 0;
  List<List<String>> grid = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grid Screen'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => m = int.tryParse(value) ?? 0,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Enter m'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (value) => n = int.tryParse(value) ?? 0,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Enter n'),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  grid = List.generate(m, (i) => List.filled(n, ''));
                });
              },
              child: Text('Create Grid'),
            ),
            if (grid.isNotEmpty)
              Column(
                children: [
                  Text('Enter Characters for Grid:'),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: m * n,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: n,
                    ),
                    itemBuilder: (context, index) {
                      return TextField(
                        onChanged: (value) {
                          final row = index ~/ n;
                          final col = index % n;
                          setState(() {
                            grid[row][col] = value.length > 0 ? value[0] : '';
                          });
                        },
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Cell ${index + 1}',
                        ),
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(grid),
                        ),
                      );
                    },
                    child: Text('Display Grid'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final List<List<String>> grid;

  SearchScreen(this.grid);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchText = '';
  List<List<bool>> highlightedGrid = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Screen'),
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                searchText = value;
                highlightGrid();
              });
            },
            decoration: InputDecoration(
              labelText: 'Enter Text to Search',
              border: OutlineInputBorder(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.grid.length * widget.grid[0].length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.grid[0].length,
              ),
              itemBuilder: (context, index) {
                final row = index ~/ widget.grid[0].length;
                final col = index % widget.grid[0].length;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    color: highlightedGrid[row][col] ? Colors.yellow : null,
                  ),
                  child: Center(
                    child: Text(widget.grid[row][col]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void highlightGrid() {
    setState(() {
      highlightedGrid = List.generate(
        widget.grid.length,
        (i) => List.generate(widget.grid[i].length, (j) => false),
      );

      for (int i = 0; i < widget.grid.length; i++) {
        for (int j = 0; j < widget.grid[i].length; j++) {
          if (checkForWord(i, j)) {
            highlightWord(i, j);
          }
        }
      }
    });
  }

  bool checkForWord(int row, int col) {
    if (widget.grid[row][col] != searchText[0]) {
      return false;
    }

    bool found = false;

    // Check East
    if (col + searchText.length <= widget.grid[0].length) {
      found = true;
      for (int i = 0; i < searchText.length; i++) {
        if (widget.grid[row][col + i] != searchText[i]) {
          found = false;
          break;
        }
      }
    }

    // Check South
    if (!found && row + searchText.length <= widget.grid.length) {
      found = true;
      for (int i = 0; i < searchText.length; i++) {
        if (widget.grid[row + i][col] != searchText[i]) {
          found = false;
          break;
        }
      }
    }

    // Check Southeast
    if (!found &&
        row + searchText.length <= widget.grid.length &&
        col + searchText.length <= widget.grid[0].length) {
      found = true;
      for (int i = 0; i < searchText.length; i++) {
        if (widget.grid[row + i][col + i] != searchText[i]) {
          found = false;
          break;
        }
      }
    }

    return found;
  }

  void highlightWord(int row, int col) {
    // Check East
    if (col + searchText.length <= widget.grid[0].length) {
      for (int i = 0; i < searchText.length; i++) {
        highlightedGrid[row][col + i] = true;
      }
    }

    // Check South
    if (row + searchText.length <= widget.grid.length) {
      for (int i = 0; i < searchText.length; i++) {
        highlightedGrid[row + i][col] = true;
      }
    }

    // Check Southeast
    if (row + searchText.length <= widget.grid.length &&
        col + searchText.length <= widget.grid[0].length) {
      for (int i = 0; i < searchText.length; i++) {
        highlightedGrid[row + i][col + i] = true;
      }
    }
  }
}
