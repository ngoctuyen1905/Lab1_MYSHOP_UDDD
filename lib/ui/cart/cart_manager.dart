import '../../models/cart_item.dart';
import 'package:flutter/foundation.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';

class CartManager with ChangeNotifier {
  late Map < String, CartItem> _item = {
    'p1': CartItem (
      id:'c1',
      title: 'Red Shirt',
      price: 29.99,
      quantity: 2,
    ),
  };
  int get productCount {
    return _item.length;
  }
  List<CartItem> get products{
    return _item.values.toList();
  }
  Iterable<MapEntry<String,CartItem>> get productEntries {
    return {..._item}.entries;
  }
  double get totalAmount {
    var total = 0.0;
    _item.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }
  void addItem(Product product){
    if( _item.containsKey(product.id)){
      // change quantity ...
      _item.update(
        product.id!,
          (existingCartItem) => existingCartItem.copyWith(
            quantity: existingCartItem.quantity + 1,
          ),
      );
    } else{
      _item.putIfAbsent(product.id!,
              () => CartItem(
                  id: 'c${DateTime.now().toIso8601String()}',
                  title: product.title,
                  quantity: 1,
                  price: product.price,
              ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId){
    _item.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId){
    if(!_item.containsKey(productId)){
      return;
    }
    if(_item[productId]?.quantity as num > 1){
      _item.update(
          productId,
              (existingCartItem) => existingCartItem.copyWith(
                quantity: existingCartItem.quantity - 1,
              ),
      );
    } else {
      _item.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _item = {};
    notifyListeners();
  }
}