import 'package:camconnect/leaderboard.dart';
import 'package:camconnect/settings.dart';
import 'package:camconnect/swipes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camconnect/video_call_page.dart';
import 'dart:async';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> matches = [];
  bool isLoading = true;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _matchesSubscription;

  @override
  void initState() {
    super.initState();
    _listenToMatches();
  }

// Listen to changes in the user's matches list in Firestore
  void _listenToMatches() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists) {
        List<dynamic> matchIds = snapshot.data()!['matches'] ?? [];
        if (matchIds.isEmpty) {
          setState(() {
            matches = [];
            isLoading = false;
          });
          return;
        }

        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: matchIds)
            .get();

        final matchData = querySnapshot.docs.map((doc) {
          return {
            'name': doc['username'] ?? 'Unknown',
            'image': doc['profilePhoto'] ?? '',
            'id': doc.id,
          };
        }).toList();

        setState(() {
          matches = matchData;
          isLoading = false;
        });
      }
    }, onError: (error) {
      print('Error listening to matches: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _matchesSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  Future<void> _deleteMatch(String matchId) async {
    try {
      final currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);
      final matchUserRef =
          FirebaseFirestore.instance.collection('users').doc(matchId);

      // Update Firestore for both users
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Remove match and add to dislikes
        transaction.update(currentUserRef, {
          'matches': FieldValue.arrayRemove([matchId]),
          'dislike': FieldValue.arrayUnion([matchId]),
          'like': FieldValue.arrayRemove([matchId]),
        });
        transaction.update(matchUserRef, {
          'matches': FieldValue.arrayRemove([currentUserId]),
          'dislike': FieldValue.arrayUnion([currentUserId]),
          'like': FieldValue.arrayRemove([currentUserId]),
        });
      });

      // Update local state
      setState(() {
        matches.removeWhere((match) => match['id'] == matchId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match removed successfully')),
      );
    } catch (e) {
      print('Error deleting match: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting match: $e')),
      );
    }
  }

  Future<void> _startVideoCall(String matchName) async {
    try {
      // Make POST request to create channel
      final response = await http.post(
        Uri.parse('http://dimkar12.pythonanywhere.com/create_channel'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCallPage(
                channelName: data['channel_name'],
                token: data['token'],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to create channel: ${data['error']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : matches.isEmpty
              ? const Center(child: Text('No matches yet!'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      return MatchCard(
                        name: matches[index]['name'],
                        image: matches[index]['image'],
                        onDelete: () => _deleteMatch(matches[index]['id']),
                        onVideoCall: () =>
                            _startVideoCall(matches[index]['name']),
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
          const BottomNavigationBarItem(
            icon: Icon(
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
          const BottomNavigationBarItem(
            icon: Icon(
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
  final VoidCallback onDelete;
  final VoidCallback onVideoCall;

  const MatchCard({
    required this.name,
    required this.image,
    required this.onDelete,
    required this.onVideoCall,
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
                  image: image.isNotEmpty
                      ? NetworkImage(image)
                      : const AssetImage('assets/placeholder.jpg')
                          as ImageProvider,
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
                  onPressed: onVideoCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Icon(Icons.videocam, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: onDelete,
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
