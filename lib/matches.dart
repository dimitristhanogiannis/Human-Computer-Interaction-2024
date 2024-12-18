import 'package:camconnect/leaderboard.dart';
import 'package:camconnect/settings.dart';
import 'package:camconnect/swipes.dart';
import 'package:flutter/material.dart';
import 'package:camconnect/video_call_page.dart';

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
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        title: const Text(
          'Matches',
          style: TextStyle(
            color: Colors.deepPurple, // Deep purple title
            fontSize: 30, // Increased font size
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // White background for the app bar
        leading: IconButton(
          icon: const Icon(Icons.settings),
          color: Colors.deepPurple, // Deep purple color for settings button
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
            crossAxisCount: 2, // 2 matches per row
            crossAxisSpacing: 10.0, // Increased spacing between items
            mainAxisSpacing: 10.0, // Increased spacing between items
            childAspectRatio: 1.5, // Aspect ratio for the cards
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
      // Custom Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple, // Deep purple for selected item
        unselectedItemColor: Colors.deepPurple, // Deep purple for unselected items
        currentIndex: 1, // Camera icon (video call) is selected
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
              color: Colors.deepPurple, // Deep purple for heart icon
              size: 24,
            ),
            label: "", // No label for this item
          ),
          BottomNavigationBarItem(
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(50), // Capsule shape
              child: Container(
                height: 40,
                width: 80,
                color: Colors.deepPurple, // Deep purple background for camera icon
                child: const Center(
                  child: Icon(
                    Icons.video_call,
                    color: Colors.white, // White icon color for selected camera
                    size: 24,
                  ),
                ),
              ),
            ),
            label: "", // No label for this item
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.groups,
              color: Colors.deepPurple, // Deep purple for leaderboard icon
              size: 24,
            ),
            label: "", // No label for this item
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
        children: [
          // Name field above the image
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              width: double.infinity,
              color: Colors.deepPurple, // Deep purple background for the name field
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text color for name
                ),
                textAlign: TextAlign.center, // Move textAlign here
              ),
            ),
          ),

          // Photo with adjusted height
          Expanded(
            child: Container(
              height: 300, // Increase the height to 300 or any desired value
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Video Call and Delete Buttons
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
                    backgroundColor: Colors.deepPurple, // Deep purple field
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Icon(Icons.videocam, color: Colors.white), // White icon
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle delete
                    print('Deleted $name');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red background for delete button
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text(
                    "DELETE", // Text in all caps
                    style: TextStyle(color: Colors.white), // White text color
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