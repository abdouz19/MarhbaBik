import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/components/custom_pageview.dart';
import 'package:marhba_bik/components/material_button_auth.dart';
import 'package:marhba_bik/models/destination.dart';
import 'package:marhba_bik/models/wilaya.dart';
import 'package:marhba_bik/screens/traveler/wilaya_screen.dart';
import 'package:marhba_bik/widgets/lists/destination_listview.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key, required this.destination});

  final Destination destination;

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  late Future<Wilaya?> _wilayaFuture;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _wilayaFuture =
        FirestoreService().fetchWilayaByName(widget.destination.wilaya);
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    String destinationId = widget.destination.name;
    bool isFavorited =
        await FirestoreService().isItemFavorited(destinationId, "destination");
    setState(() {
      _isFavorited = isFavorited;
    });
  }

  Future<void> _toggleFavoriteStatus() async {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    String destinationId = widget.destination.name;
    if (_isFavorited) {
      await FirestoreService().addToWishlist(destinationId, "destination");
    } else {
      await FirestoreService().removeFromWishlist(destinationId, "destination");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = widget.destination.otherPicturesUrls;
    String title = widget.destination.title;
    String description = widget.destination.description;
    String category = widget.destination.category;
    String region = widget.destination.region;
    String wilaya = widget.destination.wilaya;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: CustomPageView(
                imageUrls: images,
                height: 300.0,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color.fromARGB(255, 168, 168, 168),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Color.fromARGB(255, 168, 168, 168),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          MdiIcons.heart,
                          color: _isFavorited
                              ? Colors.red
                              : const Color.fromARGB(255, 168, 168, 168),
                        ),
                        onPressed: _toggleFavoriteStatus,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: const Color(0xff001939),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RatingBarIndicator(
                      rating:
                          calculateAverageRating(widget.destination.ratings),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20,
                      direction: Axis.horizontal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Place ${category} au coeur de ${_getRegionDisplayName(region)}, $wilaya.',
                      style: GoogleFonts.poppins(
                        color: const Color(0xff8E8E8E),
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xff001939),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Des paysages à couper le souffle',
                      style: TextStyle(
                        color: Color(0xff001939),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'KastelovAxiforma',
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    child: DestinationsList(
                      future:
                          FirestoreService().fetchDestinationsByWilaya(wilaya),
                      type: 'vertical',
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: MaterialButtonAuth(
                          label: 'Explore plus',
                          onPressed: () async {
                            Wilaya? wilaya = await _wilayaFuture;
                            if (wilaya != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      WilayaScreen(wilaya: wilaya),
                                ),
                              );
                            }
                          })),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double calculateAverageRating(List<int> ratings) {
  final totalRatings = ratings.fold(0, (sum, rating) => sum + rating);
  final averageRating = totalRatings / ratings.length;
  return averageRating;
}

String _getRegionDisplayName(String region) {
  switch (region) {
    case 'est':
      return "l'est";
    case 'ouest':
      return "l'ouest";
    case 'aures':
      return "les aures";
    case 'centre':
      return "le centre";
    case 'kabylie':
      return "la kabylie";
    case 'sahara':
      return "le sahara";
    default:
      return region;
  }
}
