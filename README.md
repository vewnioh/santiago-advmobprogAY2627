# Lab Act 1

Lab Activity 1 introduces the basic concepts of managing application state and user interactions within a mobile app. It explores how screen content updates dynamically when a user interacts with different elements on the device. By separating temporary screen actions from broader application data, the app can respond smoothly to user inputs. This foundational step helps in understanding how data changes are reflected visually on the screen in real-time. Overall, it establishes a solid starting point for building interactive and responsive mobile interfaces.

# Lab Act 2

Lab Activity 2 focuses on creating a visual product catalog and introducing custom appearance themes for the application. The app was expanded with multiple organized pages including home, product listing, item details, and settings screens. Visual features such as custom typography, graphics, and images were added to give the application a distinct and polished look. Users can also switch between light and dark visual themes to match their personal preference. This activity highlights the importance of consistent screen design, modular layout organization, and user customization.

# Lab Act 3

Lab Activity 3 expands the application by adding a full shopping cart experience for users. Users can browse items from the catalog, add them to their personal cart, adjust item quantities, or remove items as needed. The total price updates automatically as changes are made, keeping the order summary accurate at all times. Selecting an item inside the cart seamlessly takes the user back to view its complete details on the product page. This activity demonstrates how different sections of an app work together smoothly to deliver a unified shopping experience.

# Lab Act 4

Lab Activity 4 introduces user account sign-in, profile management, and smooth screen navigation across the app. A custom splash screen welcomes the user before presenting the sign-in interface to access their account. Once signed in, the app saves the user session so they remain logged in and can view their personal profile information. This user account setup connects directly with the shopping cart, ensuring that each user sees only their own saved cart items. Overall, this activity brings together user accounts, personal settings, item browsing, and cart management into a single complete application.

# Lab Act 5

Lab Activity 5 integrates Google Firebase Authentication into the Flutter application alongside the existing DummyJSON API service, enabling real-time cloud-based user authentication, registration, and profile management.

### Laboratory Discussion

#### 1. Workflow for DummyJSON and Firebase Implementation (From Sign In to Sign Up)
- **DummyJSON API Workflow**: Authentication relies on an external REST API endpoint (`https://dummyjson.com/auth/login`). Users log in using pre-existing mock usernames and passwords. The API returns a JSON response containing an access token and user attributes, which are cached locally in `SharedPreferences`. Since DummyJSON is a public testing API, registration is limited to client-side data handling without permanent server-side database storage.
- **Firebase Authentication Workflow**: Authentication utilizes the official `firebase_auth` SDK connected to a dedicated Google Firebase project (`advmobprog-firebase`).
  - **Sign Up**: Users fill out a comprehensive registration form (`signup_screen.dart`) containing their full name, age, contact number, username, email, and password. The app invokes `FirebaseAuth.instance.createUserWithEmailAndPassword()`, creating a permanent user record in Firebase Cloud Authentication and setting the user's display name.
  - **Sign In**: Users log in via `signInWithEmailAndPassword()`. Firebase verifies the credentials against the cloud database, manages security tokens, and triggers reactive auth state updates via `authStateChanges()`.

#### 2. Main Idea for the `UserService` Implementation
The `UserService` class serves as a unified abstraction layer (Service/Facade Pattern) separating raw authentication mechanisms from the UI widgets. Its primary objectives include:
- Encapsulating both HTTP REST API calls (DummyJSON) and native SDK calls (Firebase Auth) behind a clean, reusable Dart interface.
- Centralizing local session persistence (`SharedPreferences`) for user details, access tokens, and the active `loginType` (`firebase` vs `dummyjson`).
- Providing secure account management utilities including username updates (`updateUsername`), password changes (`resetPasswordFromCurrentPassword`), account deletion (`deleteAccount`), and session termination (`signOut`).

#### 3. Benefits of the Firebase Implementation on the Current Flutter Application
- **Real-Time Cloud Persistence**: User accounts created in the app are permanently stored in Google's secure cloud database, allowing users to sign in from any device.
- **Built-in Security & Validation**: Firebase automatically handles password hashing, email format verification, security rules, and token refresh handling without custom backend code.
- **Reactive State Management**: `authStateChanges()` provides real-time streams that notify the application immediately when a user logs in, logs out, or modifies their account state.
- **Self-Service Account Controls**: Enables users to update their profile username, change their password, or permanently delete their account with automatic re-authentication safeguards.
