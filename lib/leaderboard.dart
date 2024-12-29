import 'package:camconnect/matches.dart';
import 'package:camconnect/settings.dart';
import 'package:camconnect/swipes.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboardData = [
    {
      "name": "Alex",
      "points": 1200,
      "image": "assets/user1.jpg",
      "isCurrentUser": false
    },
    {
      "name": "Jordan",
      "points": 1150,
      "image": "assets/user2.jpg",
      "isCurrentUser": false
    },
    {
      "name": "Taylor",
      "points": 1100,
      "image": "assets/user3.jpg",
      "isCurrentUser": false
    },
    {
      "name": "Morgan",
      "points": 1050,
      "image": "assets/user4.jpg",
      "isCurrentUser": false
    },
    {
      "name": "Chris",
      "points": 1020,
      "image": "assets/user5.jpg",
      "isCurrentUser": false
    },
    {
      "name": "Sam",
      "points": 980,
      "image": "assets/user6.jpg",
      "isCurrentUser": true
    },
    {
      "name": "Jamie",
      "points": 950,
      "image": "assets/user7.jpg",
      "isCurrentUser": false
    },
    {
      "name": "Pat",
      "points": 920,
      "image": "assets/user8.jpg",
      "isCurrentUser": false
    },
  ];

  static const Color deepPurple = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(
              fontSize: 30, color: deepPurple, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: leaderboardData.length,
        itemBuilder: (context, index) {
          final user = leaderboardData[index];
          return Card(
            color: user["isCurrentUser"] ? Colors.blue.shade100 : Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  // User name with more space
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Text(
                        user["name"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Slightly reduced font size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User image in the center
                  Expanded(
                    flex: 2,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(user["image"]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User score with more space
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Text(
                        '${user["points"]} pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Slightly reduced font size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: deepPurple,
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.favorite,
              size: 24,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.video_call,
              color: deepPurple,
              size: 24,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: 40,
                width: 80,
                color: deepPurple, // Only Leaderboard button gets purple field
                child: const Center(
                  child: Icon(
                    Icons.groups,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            label: "",
          ),
        ],
      ),
    );
  }
}
