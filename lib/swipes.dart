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
        onSlideUpdate: (region) async {
          print("Region $region");
          await Future.delayed(Duration(seconds: 1));
          return;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Swipe Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SwipeCards(
              matchEngine: _matchEngine,
              itemBuilder: (BuildContext context, int index) {
                final user = _swipeItems[index].content;
                return Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(user["image"],
                          height: 200, fit: BoxFit.cover),
                      const SizedBox(height: 16),
                      Text("${user['name']}, ${user['age']}",
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(user['bio'], textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
              onStackFinished: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("You've reached the end of the list")),
                );
              },
              itemChanged: (SwipeItem item, int index) {
                print("Item at index: $index changed");
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.red, size: 36),
                onPressed: () {
                  _matchEngine.currentItem?.nope();
                },
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green, size: 36),
                onPressed: () {
                  _matchEngine.currentItem?.like();
                },
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.swipe), label: "Swipe"),
          BottomNavigationBarItem(icon: Icon(Icons.video_call), label: "Matches"),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: "Leaderboard"),
        ],
        currentIndex: 0,
        onTap: _navigateToPage,
      ),
    );
  }
}




