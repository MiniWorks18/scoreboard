import 'package:flutter/material.dart';

class PlayerTile extends StatelessWidget {
  final String name;
  final int score;
  final Color backgroundColor;
  final bool isWideLayout;
  final VoidCallback onAdd;
  final VoidCallback onSubtract;
  final VoidCallback onTap;
  final VoidCallback onSettings;

  const PlayerTile({
    Key? key,
    required this.name,
    required this.score,
    required this.backgroundColor,
    required this.isWideLayout,
    required this.onAdd,
    required this.onSubtract,
    required this.onTap,
    required this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      color: backgroundColor,
      child: InkWell(
        child: LayoutBuilder(
          builder: (context, outerConstraints) {
            List<Widget> children = [
              // Player Name
              Padding(
                padding: const EdgeInsets.fromLTRB(6.0, 0, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onSettings,
                    style: TextButton.styleFrom(
                      fixedSize: const Size(150, 50),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              // Score and Buttons
              Expanded(
                child: LayoutBuilder(
                  builder: (context, innerConstraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      // Ensures taps on transparent areas are detected
                      onTapUp: (details) {
                        final rowWidth = innerConstraints.maxWidth; // Width of the inner Row
                        final tapPosition = details.localPosition.dx;

                        if (tapPosition < rowWidth / 2) {
                          onSubtract(); // Left half: subtract
                        } else {
                          onAdd(); // Right half: add
                        }
                      },
                      child: Row(
                        children: [
                          // Minus Icon with ripple effect
                          Expanded(
                            child: InkWell(
                              onTap: onSubtract,
                              splashColor: Colors.white.withOpacity(0.3), // Ripple color
                              borderRadius: BorderRadius.circular(50), // Optional: round the ripple
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    '−',
                                    style: const TextStyle(
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Score
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: GestureDetector(
                                  onTap: onTap, // Separate action for score tap
                                  child: Text(
                                    '$score',
                                    style: const TextStyle(
                                      fontSize: 100.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Plus Icon with ripple effect
                          Expanded(
                            child: InkWell(
                              onTap: onAdd,
                              splashColor: Colors.white.withOpacity(0.3), // Ripple color
                              borderRadius: BorderRadius.circular(50), // Optional: round the ripple
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    '+',
                                    style: const TextStyle(
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ];

            return isWideLayout
                ? Row(
              children: children,
            )
                : Column(
              children: children,
            );
          },
        ),
      ),
    );
  }
}
