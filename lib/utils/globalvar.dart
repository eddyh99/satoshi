library globalvar;

import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // Import foundation.dart for kReleaseMode

// Check if in debug mode or release mode
var urlapi = kReleaseMode
    ? "https://api.pnglobalinternational.com" // Release mode
    : "https://sandbox-api.pnglobalinternational.com"; // Debug mode

var urlbase = kReleaseMode
    ? "https://satoshisignal.app" // Release mode
    : "https://sandbox.satoshisignal.app"; // Debug mode
var formatter =
    NumberFormat.currency(locale: 'id_ID', symbol: "", decimalDigits: 0);
