import 'package:flutter/material.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/models/wilaya.dart';
import 'package:marhba_bik/screens/traveler/recommanded_screen.dart';
import 'package:marhba_bik/screens/traveler/regions_screen.dart';
import 'package:marhba_bik/screens/traveler/wilaya_screen.dart';
import 'package:marhba_bik/widgets/lists/cars_listview.dart';
import 'package:marhba_bik/widgets/lists/destination_listview.dart';
import 'package:marhba_bik/widgets/lists/houses_listview.dart';
import 'package:marhba_bik/widgets/lists/trips_listview.dart';
import 'package:marhba_bik/widgets/lists/wilaya_listview.dart';
import 'package:outlined_text/outlined_text.dart';
import 'package:transparent_image/transparent_image.dart';

class HousesTraveler extends StatefulWidget {
  const HousesTraveler({super.key});

  @override
  State<StatefulWidget> createState() => _HousesTravelerScreenState();
}

class _HousesTravelerScreenState extends State<HousesTraveler> {
  late Future<Wilaya?> _wilayaJijel;
  late Future<Wilaya?> _wilayaOran;

  @override
  void initState() {
    super.initState();
    _wilayaJijel = FirestoreService().fetchWilayaByName('Jijel');
    _wilayaOran = FirestoreService().fetchWilayaByName('Oran');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 255,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Image.asset(
                    width: double.infinity,
                    'assets/images/explore_top.jpg',
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 65,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Visitez',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 29,
                            )),
                        OutlinedText(
                          text: const Text('l\'Algérie',
                              style: TextStyle(
                                color: Colors.transparent,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'KastelovAxiforma',
                                fontSize: 29,
                              )),
                          strokes: [
                            OutlinedTextStroke(color: Colors.white, width: 1),
                          ],
                        ),
                        const Text('Avec nous',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 29,
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Explorez l\'Algérie',
                  style: TextStyle(
                    color: Color(0xff001939),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'KastelovAxiforma',
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Découvrez la beauté et la diversité de nos wilayas',
                  style: TextStyle(
                    color: Color(0xff001939),
                    fontWeight: FontWeight.w300,
                    fontFamily: 'KastelovAxiforma',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 15),
                height: 200,
                child: WilayaList(
                  type: 'horizontal',
                  future: FirestoreService().fetchWilayas(),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Aventures inoubliables en Algérie',
                  style: TextStyle(
                    color: Color(0xff001939),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'KastelovAxiforma',
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Vivez des expériences uniques dans nos régions époustouflantes',
                  style: TextStyle(
                    color: Color(0xff001939),
                    fontWeight: FontWeight.w300,
                    fontFamily: 'KastelovAxiforma',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 15),
                height: 280,
                child: TripsListScreen(
                  tripsFuture: FirestoreService().fetchTrips(),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Stack(
                children: [
                  FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: const AssetImage('assets/images/explore_region.jpg'),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: 80,
                    bottom: 0,
                    left: 125,
                    right: 10,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Découvrez',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 32,
                            ),
                          ),
                          const Text(
                            'Nos diverses',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 32,
                            ),
                          ),
                          const Text(
                            'Régions',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Découvrez la beauté des paysages variés de l\'Algérie',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegionsScreen(),
                                    ));
                              },
                              child: const Text('Partez à l\'aventure'))
                        ]),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/marhbabik_full_logo_trimmed.png',
                      width: 150,
                      height: 60,
                      alignment: Alignment.topLeft,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      'Vous propose',
                      style: TextStyle(
                        color: Color(0xff001939),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'KastelovAxiforma',
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Des endroits à visiter',
                  style: TextStyle(
                    color: Color(0xff001939),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'KastelovAxiforma',
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Découvrez les trésors cachés de l\'Algérie et explorez les meilleurs endroits à visiter',
                  style: TextStyle(
                    color: Color(0xff001939),
                    fontWeight: FontWeight.w300,
                    fontFamily: 'KastelovAxiforma',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 15),
                height: 220,
                child: DestinationsList(
                  future: FirestoreService().fetchDestinations(),
                  type: '',
                  height: 160,
                  width: 200,
                ),
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Louez votre véhicule idéal en Algérie',
                  style: TextStyle(
                    color: Color(0xff001939),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'KastelovAxiforma',
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Explorez l\'Algérie en toute simplicité, trouvez le véhicule idéal pour votre voyage',
                  style: TextStyle(
                    color: Color(0xff001939),
                    fontWeight: FontWeight.w300,
                    fontFamily: 'KastelovAxiforma',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 15),
                height: 280,
                child: CarsListScreen(
                  carsFuture: FirestoreService().fetchCars(),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Stack(
                children: [
                  FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: const AssetImage('assets/images/explore_oran.jpg'),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: 100,
                    bottom: 0,
                    left: 50,
                    right: 60,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Laissez-vous',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 32,
                            ),
                          ),
                          const Text(
                            'charmer par',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 32,
                            ),
                          ),
                          const Text(
                            'Oran',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Oran, une symphonie de beauté, d\'histoire et de culture',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                Wilaya? wilaya = await _wilayaOran;
                                if (wilaya != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WilayaScreen(wilaya: wilaya),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Afficher plus'))
                        ]),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                margin:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                    gradient: LinearGradient(
                        colors: [Color(0xff7FADE9), Color(0xff3F75BB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: Column(
                  children: [
                    const Text(
                      'Révélez les secrets de Jijel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'KastelovAxiforma',
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        Wilaya? wilaya = await _wilayaJijel;
                        if (wilaya != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WilayaScreen(wilaya: wilaya),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        side: MaterialStateProperty.all(
                          const BorderSide(color: Colors.white),
                        ),
                      ),
                      child: const Text(
                        'Explorez encore plus',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontFamily: 'KastelovAxiforma',
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Trouvez votre location de rêve en Algérie',
                  style: TextStyle(
                    color: Color(0xff001939),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'KastelovAxiforma',
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Parcourez une variété de maisons pour votre escapade algérienne parfaite',
                  style: TextStyle(
                    color: Color(0xff001939),
                    fontWeight: FontWeight.w300,
                    fontFamily: 'KastelovAxiforma',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 15),
                height: 280,
                child: HousesListScreen(
                  housesFuture: FirestoreService().fetchHouses(),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Stack(
                children: [
                  FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: const AssetImage('assets/images/explore_june.jpg'),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: 100,
                    bottom: 0,
                    left: 50,
                    right: 40,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Idées de voyage',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 32,
                            ),
                          ),
                          const Text(
                            'pour juin',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Découvrez nos suggestions pour ce mois',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RecommandedScreen(
                                        type: 'recommended',
                                      ),
                                    ));
                              },
                              child: const Text('Voir plus'))
                        ]),
                  ),
                ],
              ),
              const SizedBox(
                height: 60,
              )
            ],
          )),
        ],
      ),
    );
  }
}
