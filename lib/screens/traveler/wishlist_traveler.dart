import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/widgets/empty_list.dart';
import 'package:marhba_bik/widgets/items/wishlist_item.dart';

class WishlistTraveler extends StatefulWidget {
  const WishlistTraveler({super.key});

  @override
  State<WishlistTraveler> createState() => _WishlistTravelerState();
}

class _WishlistTravelerState extends State<WishlistTraveler> {
  late Future<Map<String, List<String>>> _wishlistData;

  @override
  void initState() {
    super.initState();
    _wishlistData = _fetchWishlistData();
  }

  Future<Map<String, List<String>>> _fetchWishlistData() async {
    return await FirestoreService()
        .getWishlistData(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<void> _refreshWishlist() async {
    setState(() {
      _wishlistData = _fetchWishlistData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 20),
              child: Text(
                'Favoris',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Color(0xff001939),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'KastelovAxiforma',
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshWishlist,
                child: FutureBuilder<Map<String, List<String>>>(
                  future: _wishlistData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const EmptyList(
                        type: 'wishlist',
                      );
                    }

                    final wishlistData = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: 20.0,
                          mainAxisSpacing: 20.0,
                          crossAxisCount: 2,
                        ),
                        itemBuilder: (context, index) {
                          final collectionName =
                              wishlistData.keys.elementAt(index);
                          final itemIds = wishlistData[collectionName] ?? [];
                          return CollectionCard(
                            collectionName: collectionName,
                            itemIds: itemIds,
                          );
                        },
                        itemCount: wishlistData.length,
                        shrinkWrap: true,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
