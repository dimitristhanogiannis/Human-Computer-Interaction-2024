import 'package:camconnect/leaderboard.dart';
import 'package:camconnect/settings.dart';
import 'package:camconnect/swipes.dart';
import 'package:flutter/material.dart';
import 'package:camconnect/video_call_page.dart';

class MatchesScreen extends StatelessWidget {
  final List<Map<String, String>> dummyMatches = [
    {"name": "Alex", "image": "https://via.placeholder.com/150"},
    {"name": "Jordan", "image": "https://via.placeholder.com/150"},
    {"name": "Taylor", "image": "https://via.placeholder.com/150"},
    {"name": "Morgan", "image": "https://via.placeholder.com/150"},
    {"name": "Chris", "image": "https://via.placeholder.com/150"},
    {"name": "Sam", "image": "https://via.placeholder.com/150"},
  ];

  @override
  Widget build(BuildContext context) {
    const Color deepPurple = Color(0xFF7B1FA2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Matches',
          style: TextStyle(
            color: deepPurple,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          color: deepPurple,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.8, // Adjusted aspect ratio to make the boxes taller
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
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: deepPurple,
        unselectedItemColor: deepPurple,
        currentIndex: 1,
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.favorite,
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
                color: deepPurple,
                child: const Center(
                  child: Icon(
                    Icons.video_call,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.groups,
              color: deepPurple,
              size: 24,
            ),
            label: "",
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
    const Color deepPurple = Color(0xFF7B1FA2);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              width: double.infinity,
              color: deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(image), // Updated to use network images
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallPage(
                          channelName: "channel",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Icon(Icons.videocam, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Deleted $name');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text(
                    "DELETE",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
