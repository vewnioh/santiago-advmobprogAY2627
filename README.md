# Vergel Adrian Santiago

# INF231

# CTAMOBL Advance Mobile Programming

A new Flutter project that focuses on advanced topics. Covering the mobile to web transaction.

# Lab Activity Instance

## Lab Activity 2: Discussion

In this activity, the application integrates remote REST API data by passing information across three decoupled layers: `ProductService` executes asynchronous HTTP requests, `Product` models deserialize raw JSON payloads into strongly-typed objects, and UI screens render the data dynamically using `FutureBuilder`. The codebase adheres to the MVVM / Service-Provider design pattern, enforcing a strict separation of concerns by isolating network operations from presentation widgets. Global state management is handled using `ThemeProvider` with `ChangeNotifier`, enabling descendant widgets to reactively rebuild whenever state updates occur across the widget tree. This structured architecture improves code maintainability, type safety, and scalability while ensuring seamless data flow between the backend endpoint and the mobile client interface.

## Lab Activity 3: Discussion

This activity extends the existing model-service-screen architecture with a second vertical slice — cart — that mirrors the product slice instead of introducing a parallel pattern. `CartService` isolates every cart-related network call (`getAllCarts`, `getCartByUserId`, `addToCart`, `updateCart`) behind plain async methods, `Cart` and `CartProduct` deserialize the JSON payloads returned by those calls into strongly-typed objects, and `CartScreen` is a `StatefulWidget` that owns a `Future<Cart?>` and renders it through `FutureBuilder`, exactly like `ProductScreen` does for products. No dedicated `CartProvider`/`ChangeNotifier` was introduced, since cart data is request-scoped screen state rather than cross-cutting app state — `ThemeProvider` remains the only piece of state shared globally via `provider`, keeping the state-management boundary consistent with Lab Activity 2.

The cart and product slices converge on a single shared widget, `ProductDetailScreen` (`detail_screen`). A `CartProduct` returned by the cart endpoints only carries a partial subset of a product's fields (id, title, price, quantity, discount, thumbnail), which isn't enough to satisfy `ProductDetailScreen`'s `Product` requirement. So tapping a cart item does not push a second, cart-specific detail screen — it calls the newly added `ProductService.getProductById(id)` to resolve the *full* `Product` record first, then pushes the exact same `ProductDetailScreen` that `ProductScreen`'s product cards already use. This keeps exactly one detail screen implementation in the app regardless of whether the user arrived from the catalog grid or from their cart.

The updated design pattern adds `models/cart.dart` and `services/cart_service.dart` alongside their product counterparts, and `screens/cart_screen.dart` alongside `product_screen.dart`, following the same models/ → services/ → screens/ layering. `HomeScreen`'s bottom navigation was updated from Shop/Chat/Profile to Shop/Cart/Profile, with the Chat tab converted into a `FloatingActionButton` that is hidden while the Cart tab is active (`floatingActionButton: _selectedIndex == _cartTabIndex ? null : FloatingActionButton(...)`), so the FAB never overlaps the cart's own bottom summary/checkout bar.

Reading the DummyJSON [Carts documentation](https://dummyjson.com/docs/carts) shows that `GET /carts` returns *every* cart in the system, while `GET /carts/user/{userId}` scopes the response to a single user's carts. Since this app has no authentication, a fixed `demoUserId` constant stands in for a logged-in user; `CartService.getCartByUserId(demoUserId)` calls that endpoint and renders only the first cart in the returned `carts` array, so `CartScreen` displays one user's cart rather than the entire carts table. Adding a product to that cart is done with `POST /carts/add`, passing `{ userId, products: [{ id, quantity }] }` — the product's `id` and a quantity of `1` are read straight off the `Product` object already loaded on `ProductDetailScreen` and forwarded to `CartService.addToCart`. Quantity changes inside `CartScreen` follow the same idea using `PUT /carts/{id}`, resending the cart's full product list with the tapped item's quantity incremented, decremented, or dropped once it reaches zero.

## Lab Activity 4: Discussion

When you log in, the app sends your username and password to the server, and whatever comes back gets turned into a simple user profile and saved right on the device, so the app remembers you the next time it opens instead of asking you to log in again. The profile screen just reads that saved information and displays it as your avatar, name, email, gender, and user ID, without needing to talk to the internet every time you view it. This adds a new piece to the app's design: alongside the existing product and cart features, there's now a dedicated part just for handling login, remembering your session, and showing your profile, but it still follows the same overall structure the rest of the app already uses. Because that saved login also stores your unique ID, the cart screen uses that same saved ID to know exactly whose cart to load, so it automatically shows only your items instead of a fixed or random account's cart. In short, logging in once quietly powers both your profile page and your personal cart from then on.

