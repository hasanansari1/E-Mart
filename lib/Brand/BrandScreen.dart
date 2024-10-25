import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart_user/Brand/BrandDisplay.dart';
import 'package:e_mart_user/color.dart';
import 'package:flutter/material.dart';
import '../HomePage/HomeScreen.dart';
import '../HomePage/SearchScreen.dart';
import '../Models/BrandModel.dart';
import '../Models/CategoryModel.dart';
import '../Product/ProductScreen.dart';

class BrandScreen extends StatefulWidget {
  final CategoryModel selectedcategory;

  const BrandScreen({super.key, required this.selectedcategory});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  CollectionReference brandRef =
      FirebaseFirestore.instance.collection('Brands');

  Future<List<BrandModel>> readBrand() async {
    QuerySnapshot response = await brandRef.get();
    return response.docs.map((e) => BrandModel.fromSnapshot(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          "${widget.selectedcategory.category}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchScreen()));
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<BrandModel>>(
          future: readBrand().then((value) => value
              .where((element) =>
                  element.category == widget.selectedcategory.category)
              .toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No data available'));
            }

            final brandDocs = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: brandDocs.map((brand) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BrandCard(brand: brand),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                    height: 20), // Add spacing between brand cards and products
                BrandProduct(selectedCategory: widget.selectedcategory.category)
              ],
            );
          },
        ),
      ),
    );
  }
}

class BrandCard extends StatelessWidget {
  final BrandModel brand;

  const BrandCard({
    Key? key,
    required this.brand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 90,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductScreen(
                  seletedBrand: brand,
                  products: const [],
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 40,
                backgroundImage: NetworkImage(brand.image),
              ),
              const SizedBox(height: 20),
              Text(
                brand.brand,
                maxLines: 1, // Ensures text stays in one line
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
