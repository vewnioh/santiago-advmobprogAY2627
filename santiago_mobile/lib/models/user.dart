// Main data model representing an authenticated user account
class User {
  // Unique numeric identifier for the user
  final int id;

  // Login username
  final String username;

  // User's email address
  final String email;

  // User's given name
  final String firstName;

  // User's family name
  final String lastName;

  // User's gender
  final String gender;

  // Profile avatar image URL
  final String image;

  // Session access token returned by the login endpoint
  final String accessToken;

  // Session refresh token returned by the login endpoint
  final String refreshToken;

  // Constructor initializing all required user fields
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.accessToken,
    required this.refreshToken,
  });

  // Factory constructor deserializing JSON map data into a strongly-typed User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      gender: json['gender'] ?? '',
      image: json['image'] ?? '',
      // DummyJSON's login response uses 'accessToken'; fall back to a generic 'token' key
      accessToken: json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  // Serializes this User instance back into a JSON-compatible map for SharedPreferences storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  // Convenience getter combining first and last name for display
  String get fullName => '$firstName $lastName'.trim();
}
