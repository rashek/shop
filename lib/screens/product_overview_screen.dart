import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';

enum FilterOption {
  Favorite,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _showOnlyFavorites = false;
  @override
  Widget build(BuildContext context) {
    // final productsContainer = Provider.of<ProductsProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text('My Shop'),
          actions: [
            Consumer<Cart>(
              builder: (_, cart, badgeChild) =>
                  Badge(child: badgeChild, value: cart.itemCount.toString()),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              ),
            ),
            PopupMenuButton(
                onSelected: (FilterOption selectedValue) {
                  if (selectedValue == FilterOption.Favorite) {
                    setState(() {
                      _showOnlyFavorites = true;
                    });

                    // productsContainer.showFavoriteOnly();
                  } else {
                    // productsContainer.showAll();
                    setState(() {
                      _showOnlyFavorites = false;
                    });
                  }
                },
                icon: Icon(
                  Icons.more_vert,
                ),
                itemBuilder: (_) => [
                      PopupMenuItem(
                        child: Text('Only Favorites'),
                        value: FilterOption.Favorite,
                      ),
                      PopupMenuItem(
                        child: Text('Show All'),
                        value: FilterOption.All,
                      ),
                    ]),
          ],
        ),
        drawer: AppDrawer(),
        body: ProductsGrid(_showOnlyFavorites));
  }
}
