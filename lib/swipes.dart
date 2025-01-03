import 'package:camconnect/leaderboard.dart';
import 'package:camconnect/matches.dart';
import 'package:camconnect/settings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'dart:math';

class SwipePage extends StatefulWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String userPreference = '';
  String userGender = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  // Load user preferences and fetch users
  Future<void> _loadUserPreferences() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userPreference = userDoc.data()?['preference'] ?? 'Both';
          userGender = userDoc.data()?['sex'] ?? 'Other';
        });
        _listenForUsers();
      }
    } catch (e) {
      print('Error loading user preferences: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Parse location strings
  List<double> parseLocation(String location) {
    try {
      if (location == "Location not provided" ||
          location == "Location not selected") {
        return [0.0, 0.0]; // Default coordinates
      }

      final cleanedLocation = location.replaceAll(RegExp(r'[°\[\]]'), '');
      final parts = cleanedLocation.split(',');

      if (parts.length == 2) {
        String latPart = parts[0].trim();
        double latitude = double.parse(latPart.split(' ')[0]);
        if (latPart.contains('S')) latitude = -latitude;

        String lonPart = parts[1].trim();
        double longitude = double.parse(lonPart.split(' ')[0]);
        if (lonPart.contains('W')) longitude = -longitude;

        return [latitude, longitude];
      }
    } catch (e) {
      print('Error parsing location string: $e');
    }
    return [0.0, 0.0];
  }

  // Calculate distance using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in km
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  // Listen for users, calculate rank, and sort
  void _listenForUsers() async {
    try {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!currentUserDoc.exists) {
        print("Current user document not found.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      final currentUserData = currentUserDoc.data();
      final currentUserLocation = currentUserData?['location'];
      final currentUserUseLocation = currentUserData?['useLocation'] ?? false;

      List<double> currentUserCoords = [0.0, 0.0];
      if (currentUserUseLocation && currentUserLocation != null) {
        if (currentUserLocation is String) {
          currentUserCoords = parseLocation(currentUserLocation);
        } else if (currentUserLocation is GeoPoint) {
          currentUserCoords = [
            currentUserLocation.latitude.toDouble(),
            currentUserLocation.longitude.toDouble()
          ];
        }
      }

      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      print('Total users fetched: ${snapshot.docs.length}');

      final swipedUserIds = [
        ...currentUserData?['like'] ?? [],
        ...currentUserData?['dislike'] ?? [],
      ];
      print('Swiped users: $swipedUserIds');

      List<Map<String, dynamic>> users = snapshot.docs.where((doc) {
        final userData = doc.data();
        final shouldInclude = doc.id != currentUserId &&
            !swipedUserIds.contains(doc.id) &&
            (userPreference == 'Both' ||
                (userData['sex'] ?? '') == userPreference);
        print('User ${doc.id} included: $shouldInclude');
        return shouldInclude;
      }).map((doc) {
        final userData = doc.data();
        userData['id'] = doc.id;
        return userData;
      }).toList();

      print('Filtered users count: ${users.length}');

      const double alpha = 4.0; // Ensure alpha is double
      const double defaultDistance = 1000.0; // Default distance as double

      List<Map<String, dynamic>> rankedUsers = users.map((user) {
        double distance = defaultDistance;

        final userLocation = user['location'];
        if (user['useLocation'] == true && userLocation != null) {
          if (userLocation is String) {
            final userCoords = parseLocation(userLocation);
            distance = calculateDistance(
              currentUserCoords[0],
              currentUserCoords[1],
              userCoords[0],
              userCoords[1],
            );
          } else if (userLocation is GeoPoint) {
            distance = calculateDistance(
              currentUserCoords[0],
              currentUserCoords[1],
              userLocation.latitude.toDouble(),
              userLocation.longitude.toDouble(),
            );
          }
        }

        double score = (user['score'] ?? 0).toDouble(); // Cast score to double
        user['rankScore'] = score - alpha * distance;

        print(
            'User ${user['id']} - Distance: $distance, Score: $score, Rank: ${user['rankScore']}');

        return user;
      }).toList();

      rankedUsers.sort((a, b) => b['rankScore'].compareTo(a['rankScore']));

      if (!mounted) return;

      setState(() {
        isLoading = false;

        if (rankedUsers.isEmpty) {
          _swipeItems.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No users available to swipe!")),
          );
        } else {
          _swipeItems.clear();
          _swipeItems.addAll(rankedUsers.map((user) {
            final String userName =
                "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
            return SwipeItem(
              content: user,
              likeAction: () async {
                await _logSwipe(swipedUserId: user['id'], action: 'like');
                await _handleLike(
                    user['id'], userName.isNotEmpty ? userName : 'Unknown');
              },
              nopeAction: () async {
                await _logSwipe(swipedUserId: user['id'], action: 'dislike');
                setState(() {
                  _swipeItems
                      .removeWhere((item) => item.content['id'] == user['id']);
                  _matchEngine = MatchEngine(swipeItems: _swipeItems);
                });
              },
            );
          }).toList());
          _matchEngine = MatchEngine(swipeItems: _swipeItems);
        }
      });
    } catch (e) {
      print('Error in _listenForUsers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update score for a user
  Future<void> _updateScore(String userId, int delta) async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await userDocRef.update({
        'score': FieldValue.increment(delta),
      });
    } catch (e) {
      print('Error updating score for $userId: $e');
    }
  }

  // Log swipes to Firestore
  Future<void> _logSwipe({
    required String swipedUserId,
    required String action, // "like" or "dislike"
  }) async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        print('Error: User document does not exist.');
        return;
      }

      final currentUserData = userDoc.data() ?? {};

      // Prevent conflicting swipes
      if ((action == 'like' &&
              currentUserData['dislike']?.contains(swipedUserId) == true) ||
          (action == 'dislike' &&
              currentUserData['like']?.contains(swipedUserId) == true)) {
        print('Conflict detected: User already swiped in opposite direction');
        return;
      }

      // Ensure the 'like' or 'dislike' array exists before adding to it
      if (!currentUserData.containsKey(action)) {
        await userDocRef.update({action: []});
      }

      print('Starting _logSwipe: $action on $swipedUserId');
      String docId = '${currentUserId}_$swipedUserId';

      // Add swipe to the swipes collection
      await FirebaseFirestore.instance.collection('swipes').doc(docId).set({
        'swiperId': currentUserId,
        'swipedId': swipedUserId,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Swipe logged in swipes collection: $docId');

      // Update the current user's like or dislike field in the users collection
      await userDocRef.update({
        action: FieldValue.arrayUnion([swipedUserId]),
      });

      // Update the score for the swiped user
      if (action == 'like') {
        await _updateScore(swipedUserId, 10);
      } else if (action == 'dislike') {
        await _updateScore(swipedUserId, -5);
      }

      print('User collection updated: added $swipedUserId to $action');
    } catch (e) {
      print('Error in _logSwipe: $e');
    }
  }

  // Handle like action
  Future<void> _handleLike(String likedUserId, String likedUserName) async {
    try {
      // Step 1: Add currentUserId to likedUserId's likesReceived
      await FirebaseFirestore.instance
          .collection('users')
          .doc(likedUserId)
          .update({
        'likesReceived': FieldValue.arrayUnion([currentUserId]),
      });

      // Step 2: Fetch likedUserId's document to check mutual like
      final likedUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(likedUserId)
          .get();

      if (!likedUserDoc.exists) {
        print('Error: likedUserId document does not exist.');
        return;
      }

      // Check if likedUserId has also liked currentUserId
      List likedUsers = likedUserDoc.data()?['like'] ?? [];
      if (likedUsers.contains(currentUserId)) {
        // Step 3: Mutual like found! Add each other to matches
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .update({
          'matches': FieldValue.arrayUnion([likedUserId]),
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(likedUserId)
            .update({
          'matches': FieldValue.arrayUnion([currentUserId]),
        });

        // Increase score for both users on match
        await _updateScore(currentUserId, 5);
        await _updateScore(likedUserId, 5);

        // Notify user of the match
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("It's a match with $likedUserName!"),
        ));

        print('Match registered between $currentUserId and $likedUserId');
      } else {
        print('$likedUserId has not liked $currentUserId yet.');
      }

      // Step 4: Always remove swiped user from the swipe list
      setState(() {
        _swipeItems.removeWhere((item) => item.content['id'] == likedUserId);
        _matchEngine = MatchEngine(swipeItems: _swipeItems);
      });
    } catch (e) {
      print('Error in _handleLike: $e');
    }
  }

  // Navigation updates
  void _navigateToPage(int index) {
    if (index == 1) {
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
  }

  @override
  Widget build(BuildContext context) {
    const Color deepPurple = Color(0xFF7B1FA2);
    const Color white = Colors.white;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Meet new people",
          style: TextStyle(
            color: deepPurple,
            fontSize: 30,
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _swipeItems.isEmpty
              ? const Center(
                  child: Text('No users to swipe!')) // Initial empty state
              : Column(
                  children: [
                    Expanded(
                      child: SwipeCards(
                        matchEngine: _matchEngine,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, dynamic>? user = _swipeItems[index]
                              .content as Map<String, dynamic>?;

                          if (user == null) {
                            return const SizedBox();
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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
                                  child: Image.network(
                                    user["profilePhoto"] ??
                                        'https://via.placeholder.com/150',
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: deepPurple,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}, ${user['age'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: white,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: deepPurple,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    user['bio'] ?? 'No bio available',
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
                              content:
                                  Text("You've reached the end of the list!"),
                            ),
                          );

                          // This is optional, depending on your desired behavior
                          setState(() {
                            _swipeItems.clear();
                          });
                        },
                      ),
                    ),
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
                            child:
                                const Icon(Icons.clear, color: white, size: 48),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(28),
                              backgroundColor: deepPurple,
                            ),
                            onPressed: () => _matchEngine.currentItem?.like(),
                            child:
                                const Icon(Icons.check, color: white, size: 48),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: deepPurple,
        items: [
          BottomNavigationBarItem(
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: 40,
                width: 80,
                color:
                    deepPurple, // Added deep purple background with rounded edges
                child: const Center(
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            label: "",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.video_call, size: 24),
            label: "",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.groups, size: 24),
            label: "",
          ),
        ],
        currentIndex: 0,
        onTap: _navigateToPage,
      ),
    );
  }
}
