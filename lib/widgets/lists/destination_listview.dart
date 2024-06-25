import 'package:flutter/material.dart';
import 'package:marhba_bik/models/destination.dart';
import 'package:marhba_bik/widgets/items/destination_item.dart';
import 'package:marhba_bik/widgets/items/destinationitem.dart';
import 'package:shimmer/shimmer.dart';

class DestinationsList extends StatelessWidget {
  const DestinationsList({
    Key? key,
    required this.future,
    required this.type,
    this.height = 280,
    this.width = 280,
  }) : super(key: key);

  final Future<List<Destination>>? future;
  final String type;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return type == 'vertical' ? _buildVerticalList() : _buildHorizontalList();
  }

  Widget _buildVerticalList() {
    return FutureBuilder<List<Destination>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerList();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading destinations'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No destinations available'));
        }

        final destinations = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: destinations.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return DestinationItem(destination: destinations[index]);
          },
        );
      },
    );
  }

  Widget _buildHorizontalList() {
    return FutureBuilder<List<Destination>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerHorizontalList();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading destinations'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No destinations available'));
        }

        final destinations = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: destinations.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SecondDestinationItem(
                destination: destinations[index],
                imageHeight: height,
                imageWidth: width,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) => _buildShimmerListItem(),
      ),
    );
  }

  Widget _buildShimmerHorizontalList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => _buildShimmerHorizontalItem(),
      ),
    );
  }

  Widget _buildShimmerListItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 3),
                Container(
                  height: 20.0,
                  width: 100.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 5),
                Container(
                  height: 15.0,
                  width: 150.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerHorizontalItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 15.0,
            width: 150.0,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
