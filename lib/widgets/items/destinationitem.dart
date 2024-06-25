import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/components/favorite_icon.dart';
import 'package:marhba_bik/models/destination.dart';
import 'package:marhba_bik/screens/traveler/destination_screen.dart';
import 'package:shimmer/shimmer.dart';

class SecondDestinationItem extends StatefulWidget {
  const SecondDestinationItem({
    super.key,
    required this.destination,
    this.imageHeight,
    this.imageWidth,
  });

  final Destination destination;
  final double? imageHeight;
  final double? imageWidth;

  @override
  State<SecondDestinationItem> createState() => _DestinationItemState();
}

class _DestinationItemState extends State<SecondDestinationItem> {
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    double imageHeight = widget.imageHeight ?? 200;
    double imageWidth = widget.imageWidth ?? 250;
    List<String> images = widget.destination.otherPicturesUrls;
    String title = "${widget.destination.name}, ${widget.destination.wilaya}";
    int maxLength = imageWidth > 200 ? 33 : 24;

    String displayedTitle = title.length > maxLength
        ? "${title.substring(0, maxLength - 3)}..."
        : title;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DestinationScreen(destination: widget.destination),
          ),
        );
      },
      child: SizedBox(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        imageUrl: images[0],
                        width: imageWidth,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: imageWidth,
                              height: imageHeight,
                              color: Colors.white,
                            ),
                          );
                        },
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        icon: HeartIcon(isFavorited: _isFavorited),
                        onPressed: () async {
                          setState(() {
                            _isFavorited = !_isFavorited;
                          });
                          if (_isFavorited) {
                            await FirestoreService().addToWishlist(
                                widget.destination.name, "destination");
                          } else {
                            await FirestoreService().removeFromWishlist(
                                widget.destination.name, "destination");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                displayedTitle,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff001939),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'KastelovAxiforma',
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _capitalizeFirstLetter(widget.destination.category),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff666666),
                  fontWeight: FontWeight.w300,
                  fontFamily: 'KastelovAxiforma',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
