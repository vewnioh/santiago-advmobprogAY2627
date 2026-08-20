// Import flutter_dotenv package to access environment variables loaded from .env
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Reads and stores the base API host URL from the environment configuration
var host = dotenv.env['HOST'];

// Enhancement 3: Fixed demo user id used to scope the single-user cart (no auth system exists in this app)
const int demoUserId = 1;
