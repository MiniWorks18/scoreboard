import 'dart:math';

import 'package:flutter/material.dart';
import '../widgets/player_tile.dart';
import '../widgets/score_dialog.dart';

// Fun player names and colours. Feel free to add more!
// Names should be themed around cute Australian native animals with a funny twist, like 'Hairless Wombat' or 'Sassy Quokka'.
const descriptiveLibrary = ['Swole', 'Chill', 'Bouncy', 'Sneaky', 'Tiny', 'Wavy', 'Sassy', 'Zesty', 'Sparkly', 'Stealthy', 'Puffy', 'Spicy', 'Feisty', 'Shiny', 'Hoppin', 'Jazzy', 'Gloopy', 'Twisty', 'Nifty', 'Kicky']
;
const animalLibrary = ['Koala', 'Pademelon', 'Wombat', 'Quokka', 'Platypus', 'Bandicoot', 'Wallaby', 'Froglet', 'Possum', 'Sugar Glider', 'Echidna', 'Kangaroo', 'Numbat', 'Quoll', 'Dingo', 'Tasmanian Devil', 'Frog', 'Kookaburra', 'Frogmouth'];


class ScoreboardScreen extends StatefulWidget {
  @override
  _ScoreboardScreenState createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {

  // add players in the constructor
  _ScoreboardScreenState() {
    for (int i = 0; i < 4; i++) {
      generatePlayerObject();
    }
  }


  List<Map<String, dynamic>> players = [];

  generatePlayerObject() {
    // Generate a random player name that isn't already in the players list
    String randomName;
    do {
      randomName = animalLibrary[Random().nextInt(animalLibrary.length)];
    } while (players.any((player) => player['name'] == randomName));

    // Generate a random background color that isn't already in the players list
    Color randomColor;
    do {
      randomColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    } while (players.any((player) => player['backgroundColor'] == randomColor));

    // Add the new player to the list
    players.add({
      'name': randomName,
      'score': 0,
      'history': [0],
      'backgroundColor': randomColor,
    });
  }

  void updateScore(int index, int delta) {
    setState(() {
      players[index]['score'] += delta;
      players[index]['history'].add(players[index]['score']);
    });
  }

  void showScoreDialog(int index) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScoreDialog(
          playerName: players[index]['name'],
          onScoreUpdate: (int delta) => updateScore(index, delta),
          onViewHistory: () => showHistory(index),
        );
      },
    );
  }

  void showHistory(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Score History: ${players[index]['name']}'),
          content: SingleChildScrollView(
            child: Column(
              children: players[index]['history']
                  .map<Widget>((score) => Text(score.toString()))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
// Edit the player's properties:
  // - name
  // - background color
  // - delete button
  void editPlayer(int index) {
    // Use ValueNotifier to track selected color
    ValueNotifier<Color> selectedColorNotifier = ValueNotifier<Color>(players[index]['backgroundColor']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController(text: players[index]['name']);

        // Available colors to choose from
        List<Color> colorOptions = [
          Colors.red, Colors.green, Colors.blue, Colors.orange,
          Colors.purple, Colors.yellow, Colors.pink, Colors.cyan,
          Colors.brown, Colors.teal, Colors.indigo, Colors.amber,
        ];

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit Player'),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    players.removeAt(index); // Delete the player
                  });
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (newName) {
                  setState(() {
                    players[index]['name'] = newName;
                  });
                },
              ),
              SizedBox(height: 16.0),
              // Color picker title
              Text('Select Background Color:'),
              SizedBox(height: 16.0),
              // Color picker using Wrap
              Wrap(
                spacing: 10.0, // Horizontal space between items
                runSpacing: 10.0, // Vertical space between rows
                children: List.generate(colorOptions.length, (i) {
                  return GestureDetector(
                    onTap: () {
                      // Update the selected color in the ValueNotifier
                      selectedColorNotifier.value = colorOptions[i];
                      // Also update the player's background color immediately
                      setState(() {
                        players[index]['backgroundColor'] = colorOptions[i];
                      });
                    },
                    child: ValueListenableBuilder<Color>(
                      valueListenable: selectedColorNotifier,
                      builder: (context, selectedColor, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // The ring (behind the circle) with gap
                            Positioned(
                              child: Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedColor == colorOptions[i]
                                        ? Colors.lightBlueAccent // Show ring if selected
                                        : Colors.transparent,
                                    width: 3.0,
                                  ),
                                ),
                              ),
                            ),
                            // The color circle
                            Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorOptions[i], // Update the circle color here
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }











  @override
  Widget build(BuildContext context) {
    String? winningPlayer;
    if (players.isNotEmpty) {
      winningPlayer = players.reduce((a, b) => a['score'] > b['score'] ? a : b)['name'];
    }

    // Dunno why, but we need to subtract 35 from the available height to make it work
    double availableHeight = MediaQuery.of(context).size.height - kToolbarHeight-95;

    return Scaffold(
      body: Column(
        children: [
          // Title Bar
          SafeArea(
            child:
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Winning Player
                  if (winningPlayer != null)
                    Text(
                      '🏆 $winningPlayer',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  // Add Player Button
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => generatePlayerObject());
                    },
                    tooltip: 'Add Player',
                  ),
                ],
              ),
            ),
          ),
          // Player List
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      // Calculate tile height based on the available space
                      double tileHeight = availableHeight / players.length;

                      return SizedBox(
                        height: tileHeight, // Dynamic height for each tile
                        child: PlayerTile(
                          name: players[index]['name'],
                          score: players[index]['score'],
                          backgroundColor: players[index]['backgroundColor'],
                          isWideLayout: players.length > 5,
                          onAdd: () => updateScore(index, 1),
                          onSubtract: () => updateScore(index, -1),
                          onTap: () => showScoreDialog(index),
                          onSettings: () => editPlayer(index),
                        ),
                      );
                    },
                    childCount: players.length,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }




}
