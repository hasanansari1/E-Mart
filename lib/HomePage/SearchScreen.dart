// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart_user/color.dart';
import 'package:flutter/material.dart';
import '../Models/ProductModel.dart';
import '../Product/ProductDetails.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late FocusNode _focusNode;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<ProductModel> productItem = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // _focusNode.requestFocus();
    searchController.addListener(_onSearchInputChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchInputChange() {
    final newQuery = searchController.text;
    if (query != newQuery) {
      setState(() {
        query = newQuery;
        isSearching = newQuery.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: TextFormField(
          focusNode: _focusNode,
          controller: searchController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSecondary,
              size: 20,
            ),
            suffixIcon: query.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.clear,
                size: 20,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              onPressed: () {
                searchController.clear();
              },
            )
                : null,
            hintText: 'Search Product ...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
      body: isSearching
          ? StreamBuilder(
        stream:
        FirebaseFirestore.instance.collection("Products").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display shimmer effect during the waiting state
            return ListView.builder(
              shrinkWrap: true,
              itemCount: productItem.length,
              itemBuilder: (context, index) {
                return null;
              },
            );
          } else if (snapshot.hasError) {
            // Handle error, for example, show an error message
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No search results found ...",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          final data = snapshot.data!.docs;
          // print("Json Decode Data" + jsonEncode(data[0].data()));
          productItem =
              data.map((e) => ProductModel.fromSnapshot(e)).toList();

          if (query.isNotEmpty) {
            productItem = productItem.where((element) {
              final lowerCaseQuery = query.toLowerCase();
              return element.productName
                  .toLowerCase()
                  .contains(lowerCaseQuery) ||
                  element.category
                      .toLowerCase()
                      .contains(lowerCaseQuery) ||
                  element.brand.toLowerCase().contains(lowerCaseQuery);
            }).toList();
          }

          if (productItem.isEmpty) {
            return Center(
              child: Text(
                "No search results found ...",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            itemCount: productItem.length,
            itemBuilder: (context, index) {
              final product = productItem[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ProductDetails(product: product)));

                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 0.3,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Image.network(
                            product.images![0],
                            // fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      )
          : Center(
        child: Text(
          "Search for Products ...",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
