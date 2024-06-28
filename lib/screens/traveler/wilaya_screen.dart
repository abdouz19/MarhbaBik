import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/components/custom_pageview.dart';
import 'package:marhba_bik/models/wilaya.dart';
import 'package:marhba_bik/widgets/lists/cars_listview.dart';
import 'package:marhba_bik/widgets/lists/destination_listview.dart';
import 'package:marhba_bik/widgets/lists/houses_listview.dart';
import 'package:marhba_bik/widgets/lists/trips_listview.dart';

class WilayaScreen extends StatefulWidget {
  final Wilaya wilaya;

  const WilayaScreen({super.key, required this.wilaya});

  @override
  _WilayaScreenState createState() => _WilayaScreenState();
}

class _WilayaScreenState extends State<WilayaScreen> {
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  void _fetchImages() async {
    FirestoreService firestoreService = FirestoreService();
    List<String> fetchedImages =
        await firestoreService.getDestinationImagesByWilaya(widget.wilaya.name);
    setState(() {
      images = [widget.wilaya.imageUrl, ...fetchedImages];
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.wilaya.name;
    String title = widget.wilaya.title;
    String description = widget.wilaya.description;
    List<String> regions = widget.wilaya.regions;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff001939),
              fontWeight: FontWeight.w700,
              fontFamily: 'KastelovAxiforma',
              fontSize: 22,
            ),
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 250,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: CustomPageView(
                    imageUrls: images,
                    height: 300.0,
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    labelColor: Color(0xff001939),
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Aperçu'),
                      Tab(text: 'Habitat'),
                      Tab(text: 'Voitures'),
                      Tab(text: 'Voyages'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              CustomScrollView(
                slivers: [
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
                            child: Text(
                              regions.isEmpty
                                  ? 'Située en Algérie'
                                  : regions.length == 1
                                      ? 'Située dans ${_getRegionDisplayName(regions[0])}'
                                      : 'Située entre ${_formatRegionList(regions)}',
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'À la découverte de la beauté de ${widget.wilaya.name}',
                              style: const TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'KastelovAxiforma',
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 15),
                            height: 300,
                            child: DestinationsList(
                              future: FirestoreService()
                                  .fetchDestinationsByWilaya(name),
                              type: 'horizontal',
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Explorez notre large sélection de voitures',
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
                            height: 280,
                            child: CarsListScreen(
                              carsFuture:
                                  FirestoreService().fetchCarsByWilaya(name),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Trouvez votre bien idéal',
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
                            height: 280,
                            child: HousesListScreen(
                              housesFuture:
                                  FirestoreService().fetchHousesByWilaya(name),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Partir à l\'aventure en $name',
                              style: const TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'KastelovAxiforma',
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.only(left: 15),
                              height: 280,
                              child: TripsListScreen(
                                tripsFuture:
                                    FirestoreService().fetchTripsByWilaya(name),
                              )),
                          const SizedBox(
                            height: 80,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                  child: HousesListScreen(
                housesFuture: FirestoreService().fetchHousesByWilaya(name),
                type: 'vertical',
              )),
              Center(
                  child: CarsListScreen(
                carsFuture: FirestoreService().fetchCarsByWilaya(name),
                type: 'vertical',
              )),
              Center(
                  child: TripsListScreen(
                tripsFuture: FirestoreService().fetchTripsByWilaya(name),
                type: 'vertical',
              )),
            ],
          ),
        ),
      ),
    );
  }
}

String formatRegionMessage(List<String> regions) {
  if (regions.isEmpty) {
    return 'Située en Algérie';
  } else if (regions.length == 1) {
    return 'Située dans ${_getRegionDisplayName(regions[0])}';
  } else {
    List<String> formattedRegions = [];
    List<String> specialRegions = ['centre', 'ouest', 'est'];

    // Check if there are special regions in the list
    bool hasSpecialRegion = false;
    String specialRegion = '';

    for (String region in specialRegions) {
      if (regions.contains(region)) {
        hasSpecialRegion = true;
        specialRegion = region;
        break;
      }
    }

    if (hasSpecialRegion) {
      // Move the special region to the front
      formattedRegions.add(_getRegionDisplayName(specialRegion));
      regions.remove(specialRegion);
    }

    // Add remaining regions
    formattedRegions
        .addAll(regions.map((region) => _getRegionDisplayName(region)));

    // Construct the final message
    String formattedList = formattedRegions.join(' et ');
    return 'Située entre $formattedList de l\'Algérie';
  }
}

String _getRegionDisplayName(String region) {
  switch (region) {
    case 'est':
      return "l'est de l'Algérie";
    case 'ouest':
      return "l'ouest de l'Algérie";
    case 'aures':
      return "les Aurès";
    case 'centre':
      return "le centre de l'Algérie";
    case 'kabylie':
      return "la Kabylie";
    case 'sahara':
      return "le Sahara";
    default:
      return region;
  }
}

String _formatRegionList(List<String> regions) {
  List<String> formattedRegions =
      regions.map((region) => _getRegionDisplayName(region)).toList();
  String lastRegion = formattedRegions.removeLast();
  String formattedList = formattedRegions.join(', ');
  return '$formattedList et $lastRegion';
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
