import 'package:camconnect/leaderboard.dart';
import 'package:camconnect/matches.dart';
import 'package:camconnect/settings.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;

  final List<Map<String, dynamic>> _dummyUsers = [
    {"name": "John", "age": 25, "bio": "Love hiking and outdoor adventures!", "image": "assets/john.jpg"},
    {"name": "Emily", "age": 22, "bio": "Avid reader and coffee lover.", "image": "assets/emily.jpg"},
    {"name": "Michael", "age": 28, "bio": "Tech enthusiast and gamer.", "image": "assets/michael.jpg"},
  ];

  @override
  void initState() {
    super.initState();
    for (var user in _dummyUsers) {
      _swipeItems.add(SwipeItem(
        content: user,
        likeAction: () {
          print("Liked ${user['name']}");
        },
        nopeAction: () {
          print("Disliked ${user['name']}");
        },
      ));
    }
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  void _navigateToPage(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MatchesScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeaderboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color deepPurple = Color(0xFF7B1FA2);
    const Color white = Colors.white;

    return Scaffold(
      backgroundColor: white, // Entire app background is white
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Meet new people",
          style: TextStyle(
            color: deepPurple,
            fontSize: 30, // Bigger size for the logo
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings, color: deepPurple),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SwipeCards(
              matchEngine: _matchEngine,
              itemBuilder: (BuildContext context, int index) {
                final user = _swipeItems[index].content;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          user["image"],
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Deep purple box for name and age
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: deepPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${user['name']}, ${user['age']}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                      ),
                      // Deep purple box for bio
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: deepPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user['bio'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onStackFinished: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("You've reached the end of the list!"),
                  ),
                );
              },
            ),
          ),
          // Larger Yes/No Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(28),
                    backgroundColor: deepPurple,
                  ),
                  onPressed: () => _matchEngine.currentItem?.nope(),
                  child: const Icon(Icons.clear, color: white, size: 48),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(28),
                    backgroundColor: deepPurple,
                  ),
                  onPressed: () => _matchEngine.currentItem?.like(),
                  child: const Icon(Icons.check, color: white, size: 48),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: deepPurple, // Deep purple for selected items
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(50), // Capsule shape
              child: Container(
                height: 40,
                width: 80,
                color: deepPurple,
                child: const Center(
                  child: Icon(
                    Icons.favorite,
                    color: white,
                    size: 24,
                  ),
                ),
              ),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.video_call,
              color: deepPurple, // Camera icon in deep purple
              size: 24,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.groups,
              color: deepPurple, // Leaderboard icon in deep purple
              size: 24,
            ),
            label: "",
          ),
        ],
        currentIndex: 0,
        onTap: _navigateToPage,
      ),
    );
  }
}
