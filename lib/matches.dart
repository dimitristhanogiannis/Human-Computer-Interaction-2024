import 'package:camconnect/leaderboard.dart';
import 'package:camconnect/settings.dart';
import 'package:camconnect/swipes.dart';
import 'package:flutter/material.dart';

class MatchesScreen extends StatelessWidget {
  final List<Map<String, String>> dummyMatches = [
    {"name": "Alex", "image": "assets/user1.jpg"},
    {"name": "Jordan", "image": "assets/user2.jpg"},
    {"name": "Taylor", "image": "assets/user3.jpg"},
    {"name": "Morgan", "image": "assets/user4.jpg"},
    {"name": "Chris", "image": "assets/user5.jpg"},
    {"name": "Sam", "image": "assets/user6.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 matches per row
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.2, // Smaller cards
                ),
                itemCount: dummyMatches.length,
                itemBuilder: (context, index) {
                  return MatchCard(
                    name: dummyMatches[index]["name"]!,
                    image: dummyMatches[index]["image"]!,
                  );
                },
              ),
            ),
          ),
          BottomNavigationBar(
            currentIndex: 1, // Matches tab selected
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SwipePage()),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LeaderboardScreen()),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.swipe),
                label: 'Swipe',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.videocam),
                label: 'Matches',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard),
                label: 'Leaderboard',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final String name;
  final String image;

  const MatchCard({
    required this.name,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Name
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // Photo
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Video Call and Unmatch Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle video call
                    print('Video Call with $name');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Icon(Icons.videocam),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle unmatch
                    print('Unmatched $name');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text("Unmatch", style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



