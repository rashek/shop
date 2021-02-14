import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_execption.dart';

class ProductsProvider with ChangeNotifier {
  final String authToken;
  final String userId;
  ProductsProvider(this.authToken, this.userId, this._items);

  List<Product> _items = [];
  //  = [
  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p2',
  //     title: 'Trousers',
  //     description: 'A nice pair of trousers.',
  //     price: 59.99,
  //     imageUrl:
  //         'https://www.capeunionmart.co.za/dw/image/v2/BDJC_PRD/on/demandware.static/-/Sites-master-catalog-capeunion/default/dw4e561d23/images/zoom/CUM/133820_0100_1.jpg?sw=800&sh=800',
  //   ),
  //   Product(
  //     id: 'p3',
  //     title: 'Yellow  Scarf',
  //     description: 'A nice yellow scarf.',
  //     price: 39.99,
  //     imageUrl:
  //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoD3Fa0GLATsF9-sqBAT3bslgcsIXzGemXqA&usqp=CAU',
  //   ),
  //   Product(
  //     id: 'p4',
  //     title: 'A Pan',
  //     description: 'A stainless cooking pan.',
  //     price: 199.99,
  //     imageUrl:
  //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQh0S_9Tw1VYWh_iY8i2plRz47iYfg9-7lVnQ&usqp=CAU',
  //   ),
  //   Product(
  //     id: 'p5',
  //     title: 'Blue Jeans',
  //     description: 'A Blue Jeans - it is pretty blue!',
  //     price: 129.99,
  //     imageUrl:
  //         'https://mp-media.reebonz.com/images/p-a1/reebonz-jm-icon-denim-blue-jeans-size-30-jm-icon-1-a17d7093-864c-448a-9643-3629092bfb1b.jpg;mode=pad;bgcolor=fff;404=404.jpg;width=402;height=500;quality=100',
  //   ),
  //   Product(
  //     id: 'p7',
  //     title: 'Watch',
  //     description: 'A red shirt - it is pretty classy!',
  //     price: 529.99,
  //     imageUrl:
  //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlMzAYDhIuReZFZW0R9nrCy9rLkK1GTdEwsw&usqp=CAU',
  //   ),
  //   Product(
  //     id: 'p8',
  //     title: 'Hoodie',
  //     description: 'A red hoodie - it is pretty red!',
  //     price: 79.99,
  //     imageUrl:
  //         'https://cdn.shopify.com/s/files/1/0073/9078/9713/products/Palm_Trees_Red_Hoodie1_1200x1200.png?v=1556738320',
  //   ),
  // ];

  // var _showFavoriteOnly = false;

  List<Product> get items {
    // if (_showFavoriteOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }
  // void showFavoriteOnly() {
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts() async {
    var url =
        'https://shopapp-2119b-default-rtdb.firebaseio.com/product.json?auth=$authToken';

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      // print(extractedData);
      final List<Product> loadedProduct = [];
      if (extractedData == null) {
        return;
      }
      url =
          'https://shopapp-2119b-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProduct;
      // print(loadedProduct);
      // notifyListeners();
      // print(json.decode(response.body));
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final url =
          'https://shopapp-2119b-default-rtdb.firebaseio.com/product.json?auth=$authToken';
      await http
          .post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
        }),
      )
          .then((res) {
        final newProduct = Product(
            id: json.decode(res.body)['name'],
            title: product.title,
            description: product.description,
            price: product.price,
            imageUrl: product.imageUrl);
        _items.add(newProduct);
        // _items.insert(0, newProduct); //to start the product at the beginig of the list
        notifyListeners();
      });
    } catch (error) {
      // print(error);
      throw error;
    }
  }

  Future<void> updateProduct(Product newProduct, String id) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      final url =
          'https://shopapp-2119b-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('sdasd');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shopapp-2119b-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((pro) => pro.id == id);
    var existingProduct = _items[existingProductIndex];
    // notifyListeners();
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Can not delete this product');
    }
    existingProduct = null;
  }
}
