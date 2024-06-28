import 'package:flutter/material.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/models/wilaya.dart';
import 'package:marhba_bik/screens/traveler/explore_traveler.dart';
import 'package:marhba_bik/widgets/items/region_item.dart';

class RegionsScreen extends StatefulWidget {
  const RegionsScreen({super.key});

  @override
  State<RegionsScreen> createState() => _RegionsScreenState();
}

class _RegionsScreenState extends State<RegionsScreen> {
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
                    'assets/images/explore_oran.jpg',
                    fit: BoxFit.cover,
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
                      _buildSpecialWilayasGrid()
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

  Widget _buildSpecialWilayasGrid() {
    Map<String, String> regions = {
      'aures':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Faures.jpg?alt=media&token=a5ee441e-8bfa-4e85-8e4c-473be608cd0d0',
      'centre':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Fcentre.jpg?alt=media&token=19f32ea2-e199-4169-9597-18a12b498f46',
      'est':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Fest.jpg?alt=media&token=77f7c3a4-699d-4d53-936b-372b8106f1f4',
      'kabylie':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Fkabylie.jpg?alt=media&token=1eb4f611-8d8f-4705-83d8-a416fcafca25',
      'sahara':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Fsahara.jpg?alt=media&token=c3e5bbf4-7569-4268-bcc0-036d9b7feb12',
      'ouest':
          'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/regions%2Fouest.jpg?alt=media&token=780fa557-de90-40c6-a075-83a9d5ecae2d'
    };

    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: regions.length,
        itemBuilder: (context, index) {
          String regionName = regions.keys.elementAt(index);
          String? imageUrl = regions[regionName];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: RegionItem(
              name: regionName,
              imageUrl: imageUrl!,
              width: double.infinity,
            ),
          );
        });
  }
}
