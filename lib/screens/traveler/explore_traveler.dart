import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/components/material_button_auth.dart';
import 'package:marhba_bik/models/wilaya.dart';
import 'package:marhba_bik/screens/traveler/regions_screen.dart';
import 'package:marhba_bik/screens/traveler/wilaya_screen.dart';
import 'package:marhba_bik/widgets/lists/destination_listview.dart';
import 'package:marhba_bik/widgets/items/region_item.dart';
import 'package:marhba_bik/widgets/lists/wilaya_listview.dart';

class ExploreTraveler extends StatefulWidget {
  const ExploreTraveler({super.key});

  @override
  State<ExploreTraveler> createState() => _ExploreTravelerState();
}

class _ExploreTravelerState extends State<ExploreTraveler> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Wilaya>>? _futureWilayas;
  List<Wilaya> _filteredWilayas = [];
  bool _isSearching = false;
  late Future<List<Wilaya>> futureSpecialWilayas;

  @override
  void initState() {
    super.initState();
    futureSpecialWilayas =
        FirestoreService().fetchSpecialWilayas(['10', '06', '31', '19']);
    _futureWilayas = FirestoreService().fetchWilayas();
    _futureWilayas?.then((wilayas) {
      setState(() {
        _filteredWilayas = wilayas;
      });
    });
    _searchController.addListener(() => _filterWilayas(_searchController.text));
  }

  void _filterWilayas(String query) {
    _futureWilayas?.then((wilayas) {
      setState(() {
        _filteredWilayas = wilayas.where((wilaya) {
          return wilaya.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
        _isSearching = query.isNotEmpty;
      });
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredWilayas = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/images/homepage_for_now.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      _buildSearchBar(),
                      const SizedBox(height: 20.0),
                      _buildPickRegionButton(),
                      const SizedBox(height: 40.0),
                      _buildSectionTitle('Partez à la découverte'),
                      const SizedBox(
                        height: 8,
                      ),
                      WilayaList(
                        type: 'vertical',
                        future: FirestoreService()
                            .fetchSpecialWilayas(['06', '10', '35']),
                      ),
                      _buildSeeAllButton(
                        onPressed: () {},
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildSectionTitle('Escapades à proximité'),
                      const SizedBox(
                        height: 8,
                      ),
                      DestinationsList(
                        future: FirestoreService().fetchSpecialDestinations(
                            ['Yema gouraya', 'Lac vert', "Makam al shahid"]),
                        type: 'vertical',
                      ),
                      _buildSeeAllButton(
                        onPressed: () {},
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildSectionTitle('Régions à ne pas manquer'),
                      const SizedBox(
                        height: 18,
                      ),
                      _buildSpecialWilayasGrid(),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isSearching) _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Stack(
      children: [
        Container(
          height: 50.0,
          padding: const EdgeInsets.only(left: 15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(color: const Color(0xFFC0C0C0), width: 1.0),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Où aller ? ',
              border: InputBorder.none,
              isDense: false,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff3F75BB),
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickRegionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: MaterialButtonAuth(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegionsScreen(),));
        },
        label: 'Choisissez une région',
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xff001939),
        fontWeight: FontWeight.bold,
        fontFamily: 'KastelovAxiforma',
        fontSize: 22,
      ),
    );
  }

  Widget _buildSpecialWilayasGrid() {
    Map<String, String> regions = {
      'aures':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Faures.jpg?alt=media&token=a5ee441e-8bfa-4e85-8e4c-473be608cd0d0',
      'center':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Fcenter.jpg?alt=media&token=545ba711-7bc2-4b49-9dd5-2e6fd152ef1a',
      'east':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Feast.jpg?alt=media&token=69dcfb64-822c-4d65-8d33-295010e9fa13',
      'kabylie':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Fkabylie.jpg?alt=media&token=1eb4f611-8d8f-4705-83d8-a416fcafca25',
      'sahara':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Fsahara.jpg?alt=media&token=c3e5bbf4-7569-4268-bcc0-036d9b7feb12',
      'west':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Fwest.jpg?alt=media&token=fe065a6e-d0bb-4e23-b3f9-520079d12f20'
    };

    return GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: regions.length,
        itemBuilder: (context, index) {
          String regionName = regions.keys.elementAt(index);
          String? imageUrl = regions[regionName];
          return RegionItem(name: regionName, imageUrl: imageUrl!);
        });
  }

  Widget _buildSearchResults() {
    return Positioned(
      top: 160.0,
      left: 20.0,
      right: 20.0,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 300.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeSearch,
                  ),
                ],
              ),
              Expanded(
                child: _filteredWilayas.isNotEmpty
                    ? ListView.builder(
                        itemCount: _filteredWilayas.length,
                        itemBuilder: (context, index) {
                          return WilayaTile(wilaya: _filteredWilayas[index]);
                        },
                      )
                    : Center(
                        child: Text(
                          'No results found for "${_searchController.text}"',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildSeeAllButton({required VoidCallback onPressed}) {
  return InkWell(
    onTap: onPressed,
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'See All',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xff3F75BB),
          fontSize: 18.0,
          fontFamily: 'KastelovAxiforma',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

class WilayaTile extends StatelessWidget {
  final Wilaya wilaya;

  const WilayaTile({super.key, required this.wilaya});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WilayaScreen(wilaya: wilaya)),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(wilaya.imageUrl),
        ),
        title: Text(wilaya.name),
        subtitle: Text(
          wilaya.regions.isEmpty
              ? 'Située en Algérie'
              : wilaya.regions.length == 1
                  ? 'Située dans la région de ${wilaya.regions[0]}'
                  : 'Située entre ${wilaya.regions.sublist(0, wilaya.regions.length - 1).join(', ')} et ${wilaya.regions.last}',
        ),
      ),
    );
  }
}
