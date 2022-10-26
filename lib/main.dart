import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/ui/orders/orders_screen.dart';
import '/ui/products/edit_product_screen.dart';

import 'package:provider/provider.dart';

import 'ui/screens.dart';

Future <void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: ((context) => AuthManager())
        ),
        ChangeNotifierProxyProvider<AuthManager,ProductManager>(
          create: (ctx) => ProductManager(),
          update: (ctx, authManager, productsManager) {
            productsManager!.authToken = authManager.authToken;
            return productsManager;
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartManager(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OrdersManager(),
        ),
      ],
      child: Consumer<AuthManager>(
          builder: (context, authManager, child) {
            return MaterialApp(
              title: 'My Shop',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                fontFamily: 'Lato',
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.purple,
                ).copyWith(
                  secondary: Colors.deepOrange,
                ),
              ),
              home:authManager.isAuth ? const ProductsOverviewScreen() : FutureBuilder(
                future: authManager.tryAutoLogin(),
                builder: ((context, snapshot){
                  return snapshot.connectionState == ConnectionState.waiting ? const SplashScreen() : const AuthScreen();
                }),
              ),
              routes: {
                CartScreen.routeName: (ctx) => const CartScreen(),
                OrderScreen.routeName: (ctx) => const OrderScreen(),
                UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
              },
              onGenerateRoute: (settings) {
                if (settings.name == ProductDetailScreen.routeName) {
                  final productId = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (ctx) {
                      return ProductDetailScreen(
                        ctx.read<ProductManager>().findById(productId),
                      );
                    },
                  );
                }

                if (settings.name == EditProductScreen.routeName) {
                  final productId = settings.arguments as String?;
                  return MaterialPageRoute(
                    builder: (ctx) {
                      return EditProductScreen(
                        productId != null
                            ? ctx.read<ProductManager>().findById(productId)
                            : null,
                      );
                    },
                  );
                }

                return null;
              },
            );
          }
      ),
    );
  }
}
