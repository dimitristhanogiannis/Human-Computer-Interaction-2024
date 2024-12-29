import 'package:camconnect/leaderboard.dart';
import 'package:camconnect/matches.dart';
import 'package:camconnect/settings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipe_cards/swipe_cards.dart';

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

  // Listen for users matching preferences in Firestore
  void _listenForUsers() async {
    try {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!currentUserDoc.exists) {
        throw Exception('Current user document not found');
      }

      List<String> swipedUserIds = [
        ...currentUserDoc.data()?['swipes']['liked'] ?? [],
        ...currentUserDoc.data()?['swipes']['disliked'] ?? [],
      ];

      FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .listen((snapshot) {
        final filteredDocs = snapshot.docs.where((doc) =>
            doc.id != currentUserId &&
            !swipedUserIds.contains(doc.id) &&
            (userPreference == 'Both' || doc['sex'] == userPreference));

        final newSwipeItems = filteredDocs.map((doc) {
          final userData = doc.data();
          final userName = userData['name'] ?? 'Unknown'; // Handle null name
          return SwipeItem(
            content: userData,
            likeAction: () async {
              await _logSwipe(swipedUserId: doc.id, action: 'like');
              await _handleLike(doc.id, userName);
            },
            nopeAction: () async {
              await _logSwipe(swipedUserId: doc.id, action: 'dislike');
              print('Disliked $userName');
              setState(() {
                _swipeItems.removeWhere((item) => item.content['id'] == doc.id);
                _matchEngine = MatchEngine(swipeItems: _swipeItems);
              });
            },
          );
        }).toList();

        if (!mounted || _swipeItems.length == newSwipeItems.length) return;

        setState(() {
          _swipeItems.clear();
          _swipeItems.addAll(newSwipeItems);
          _matchEngine = MatchEngine(swipeItems: _swipeItems);
          isLoading = false;
        });
      });
    } catch (e) {
      print('Error in _listenForUsers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Log swipes to Firestore
  Future<void> _logSwipe({
    required String swipedUserId,
    required String action, // "like" or "dislike"
  }) async {
    try {
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

      // Update the current user's swipes field in the users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'swipes.$action': FieldValue.arrayUnion([swipedUserId]),
      });

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
      List likedUsers = likedUserDoc.data()?['swipes']['liked'] ?? [];
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
              ? const Center(child: Text('No users to swipe!'))
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
                                    "${user['name'] ?? 'Unknown'}, ${user['age'] ?? 'N/A'}",
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
        selectedItemColor: deepPurple,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 24),
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
