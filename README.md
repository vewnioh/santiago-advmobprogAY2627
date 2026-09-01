# Lab Act 1

Lab Activity 1 focuses on understanding fundamental state management concepts in Flutter, specifically distinguishing between ephemeral (local) state and app (global) state. Ephemeral state is managed within a single widget using `StatefulWidget` and `setState()` for transient UI updates like toggle switches or form field inputs. In contrast, app state handles data that needs to be shared across multiple screens or throughout the entire lifecycle of the application. By implementing basic reactive UI controls and stateful elements, this activity demonstrates how state changes trigger UI rebuilds in Flutter. Mastering state management ensures that application state remains predictable, organized, and scalable as app complexity grows.

# Lab Act 2

Lab Activity 2 introduces a structured product catalog along with dynamic light and dark mode custom theming. Data models and dedicated service layers were established to handle product information, while custom visual assets such as fonts, images, and SVG graphics were integrated into the app. The UI was expanded with dedicated screens including a Home Screen, Product Screen, Product Detail Screen, and Settings Screen. Reusable widgets like custom text components and a theme provider were implemented to maintain visual consistency across all views. This activity emphasizes modular UI development, responsive component layout, and persistent aesthetic customization.

# Lab Act 3

Lab Activity 3 builds upon the product catalog by introducing full shopping cart functionality and centralized cart state management. A dedicated `Cart` model and `CartService` were implemented to enable users to add items, modify quantities, remove items, and calculate total order prices dynamically. The cart UI was created with `CartScreen`, seamlessly integrating item selection from both the Home Screen and Product Detail Screen. Global state synchronization guarantees that updates in the cart are immediately reflected throughout the entire application layout. This activity demonstrates how service-oriented state architectures streamline complex multi-screen e-commerce workflows.

# Lab Act 4

Lab Activity 4 introduces user account authentication, profile management, and comprehensive session-based screen navigation. A `User` data model and `UserService` were developed to manage user credentials, registration, and active authentication sessions. Brand new user interface screens were built, including a customized Splash Screen, Sign-In Screen, and Profile Screen. The navigation architecture was enhanced to seamlessly transition users from authentication entry points into the core app dashboard upon successful login. Overall, this activity unifies authentication, profile persistence, cart state, and catalog features into a cohesive, production-ready mobile application flow.
