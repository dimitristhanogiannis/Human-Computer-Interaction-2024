import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camconnect/matches.dart';
import 'package:camconnect/settings.dart';
import 'package:camconnect/swipes.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  static const Color deepPurple = Color(0xFF7B1FA2);

  Future<List<Map<String, dynamic>>> fetchLeaderboardData() async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    // Get all users from Firestore and order by score
    final querySnapshot =
        await firestore.collection('users').orderBy('score', descending: true).get();

    // For each user, add 10 points for every like in likesReceived attribute
    for (var doc in querySnapshot.docs) {
      final userData = doc.data();
      final likesReceived = userData['likesReceived'] ?? [];
      final currentScore = userData['score'] ?? 0;

      // Ensure likesReceived is a list (in case it's not initialized)
      if (likesReceived is List) {
        // Calculate points based on likesReceived length
        int calculatedPoints = likesReceived.length * 10;

        // Only update score if it's different from the calculated points
        if (currentScore != calculatedPoints) {
          // Update the Firestore document with new points
          await firestore.collection('users').doc(doc.id).update({
            'score': calculatedPoints, // Set score based on likesReceived
          });
        }
      }
    }

    // Return leaderboard data to be displayed
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "name": "${data['firstName']} ${data['lastName']}",
        "points": data['score'], // Display the updated score
        "image": data['profilePhoto'] ?? 'assets/default_profile.png',
        "isCurrentUser": doc.id == auth.currentUser?.uid,
      };
    }).toList();
  }

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLeaderboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No leaderboard data available.'));
          }

          final leaderboardData = snapshot.data!;
          return ListView.builder(
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
                          backgroundImage: NetworkImage(user["image"]),
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
