import 'package:camconnect/matches.dart';
import 'package:camconnect/settings.dart';
import 'package:camconnect/swipes.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboardData = [
    {"name": "Alex", "points": 1200, "image": "assets/user1.jpg", "isCurrentUser": false},
    {"name": "Jordan", "points": 1150, "image": "assets/user2.jpg", "isCurrentUser": false},
    {"name": "Taylor", "points": 1100, "image": "assets/user3.jpg", "isCurrentUser": false},
    {"name": "Morgan", "points": 1050, "image": "assets/user4.jpg", "isCurrentUser": false},
    {"name": "Chris", "points": 1020, "image": "assets/user5.jpg", "isCurrentUser": false},
    {"name": "Sam", "points": 980, "image": "assets/user6.jpg", "isCurrentUser": true},
    {"name": "Jamie", "points": 950, "image": "assets/user7.jpg", "isCurrentUser": false},
    {"name": "Pat", "points": 920, "image": "assets/user8.jpg", "isCurrentUser": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: leaderboardData.length,
        itemBuilder: (context, index) {
          final user = leaderboardData[index];
          return Card(
            color: user["isCurrentUser"] ? Colors.blue.shade100 : Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(user["image"]),
              ),
              title: Text(
                user["name"],
                style: TextStyle(
                  fontWeight: user["isCurrentUser"] ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: Text(
                '${user["points"]} pts',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Leaderboard tab selected
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SwipePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MatchesScreen()),
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
    );
  }
}


