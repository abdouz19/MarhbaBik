import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomPageView extends StatefulWidget {
  final List<XFile?>? images;
  final List<String>? imageUrls;
  final double height;
  final Map<String, dynamic>? offer;
  final Function? onDelete;
  final String? offerType;

  const CustomPageView({
    super.key,
    this.images,
    this.imageUrls,
    required this.height,
    this.offer,
    this.onDelete,
    this.offerType,
  }) : assert(images != null || imageUrls != null,
            'Either images or imageUrls must be provided');

  @override
  State<CustomPageView> createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> images = [];

    if (widget.images != null) {
      images = widget.images!.map((XFile? image) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: widget.height,
          child: image != null
              ? Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                  height: widget.height,
                )
              : Image(
                  image: const AssetImage('assets/images/me.jpeg'),
                  fit: BoxFit.cover,
                  height: widget.height,
                ),
        );
      }).toList();
    } else if (widget.imageUrls != null) {
      images = widget.imageUrls!.map((String imageUrl) {
        return Stack(
          children: [
            const Center(child: CircularProgressIndicator()),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: widget.height,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                height: widget.height,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ],
        );
      }).toList();
    }

    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            allowImplicitScrolling: true,
            controller: _controller,
            itemCount: images.length,
            itemBuilder: (BuildContext context, int index) {
              return images[index];
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => buildDot(index),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.white : Colors.grey,
      ),
    );
  }
}
