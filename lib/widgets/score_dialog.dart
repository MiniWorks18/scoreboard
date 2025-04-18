import 'package:flutter/material.dart';

class ScoreDialog extends StatelessWidget {
  final String playerName;
  final ValueChanged<int> onScoreUpdate;
  final VoidCallback onViewHistory;

  const ScoreDialog({
    required this.playerName,
    required this.onScoreUpdate,
    required this.onViewHistory,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> number = ValueNotifier<int>(0);

    void updateNumber(String value) {
      // Update the number only if it's a valid integer
      number.value = int.tryParse(value) ?? 0;
    }

    return AlertDialog(
      title: Text('Adjust $playerName\'s Score'),
      insetPadding: EdgeInsets.all(10),
      contentPadding: EdgeInsets.all(10),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9, // Make dialog 80% of screen width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => number.value -= 10,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromRGBO(227, 88, 88, 1),
                        ),
                      ),
                      child: Text('-10', style: TextStyle(color: Colors.white, fontSize: 25)),
                    ),
                    TextButton(
                    onPressed: () => number.value -= 5 ,
                    style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(250, 140, 140, 1),
                    ),
                    ),
                    child: Text('-5', style: TextStyle(color: Colors.white, fontSize: 25)),
                    ),
                    TextButton(
                    onPressed: () => number.value += 5,
                    style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(143, 217, 83, 1),
                    ),
                    ),
                    child: Text('+5', style: TextStyle(color: Colors.white, fontSize: 25)),
                    ),
                    TextButton(
                    onPressed: () => number.value += 10,
                    style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(101, 160, 53, 1),
                    ),
                    ),
                    child: Text('+10', style: TextStyle(color: Colors.white, fontSize: 25)),
                    ),
                  ],
                ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 32),
                  onPressed: () => number.value -= 1,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child:
                  ValueListenableBuilder<int>(
                    valueListenable: number,
                    builder: (context, value, child) {
                      return TextField(
                        style: TextStyle(fontSize: 60),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true
                        ),
                        onChanged: updateNumber, // Update ValueNotifier on change
                        controller: TextEditingController(
                          text: value.toString(),
                        )..selection = TextSelection.collapsed(
                          offset: value.toString().length,
                        ), // Keep cursor at the end
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 32),
                  onPressed: () => number.value += 1,
                ),

              ]
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: onViewHistory,
                ),
                Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromRGBO(145, 145, 145, 1.0),
                    ),
                  ),
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    onScoreUpdate(number.value);
                    Navigator.of(context).pop();
                  },
                  child: Text('Apply'),
                ),

              ]
            )
          ],
        ),
      ),
    );
  }
}
