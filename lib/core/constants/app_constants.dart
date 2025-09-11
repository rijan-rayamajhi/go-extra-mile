import 'package:flutter/material.dart';

// App Constants - Centralized configuration values
// All constants must be compile-time constants (const keyword)

// String Constants
const String appName = 'Go Extra Mile';
const String appDescription = 'Ride & Earn';

// Responsive Design Constants
// These are base values that will be scaled using ResponsiveUtils

// Base paddings (will be scaled responsively)
const double baseScreenPadding = 16.0;
const double baseCardPadding = 12.0;
const double baseButtonPadding = 16.0;

// Base radius values (will be scaled responsively)
const double baseButtonRadius = 16.0;
const double baseCardRadius = 12.0;
const double baseInputRadius = 8.0;

// Base button dimensions (will be scaled responsively)
const double baseButtonHeight = 48.0;
const double baseButtonWidth = double.infinity;
const double baseIconButtonSize = 40.0;

// Base spacing values (will be scaled responsively)
const double baseSpacing = 16.0;
const double baseSmallSpacing = 8.0;
const double baseLargeSpacing = 24.0;

// Base font sizes (will be scaled responsively)
const double baseSmallFontSize = 12.0;
const double baseMediumFontSize = 14.0;
const double baseLargeFontSize = 16.0;
const double baseXLargeFontSize = 18.0;
const double baseXXLargeFontSize = 24.0;

// Base icon sizes (will be scaled responsively)
const double baseSmallIconSize = 16.0;
const double baseMediumIconSize = 24.0;
const double baseLargeIconSize = 32.0;
const double baseXLargeIconSize = 48.0;

// Legacy constants for backward compatibility (deprecated - use ResponsiveUtils instead)
@deprecated
const double screenPadding = 16.0;
@deprecated
const double buttonRadius = 16;
@deprecated
const double buttonHeight = 48;
@deprecated
const double buttonWidth = double.infinity;
@deprecated
const double spacing = 16;

// Memory marker colors for ride feature
const List<Color> memoryMarkerColors = [
  Colors.green,
  Colors.blue,
  Colors.purple,
  Colors.orange,
  Colors.pink,
];

//random text 
const randomText = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";

//vechile brand image 
const String vechileBrandImage1 = 'https://mapandfire.com/wp-content/uploads/2022/12/bmw-brand-logo.jpg';
const String vechileBrandImage2 = 'https://i.pinimg.com/564x/45/f6/60/45f660eb3d6896a9f7b6f6538bd5e36f.jpg';
const String vechileBrandImage3 = 'https://i.pinimg.com/736x/f2/2c/55/f22c552e14c6386c2ae424575db195d2.jpg';
const String vechileBrandImage4 = 'https://logomakerr.ai/blog/wp-content/uploads/2022/10/tesla-logo.jpg';
const String vechileBrandImage5 = 'https://cdn.olaelectric.com/sites/evdp/pages/news_room/press_kit/branding/branding-featured.webp';


// Vehicle data
const List<Map<String, String>> vehicles = [
  { 'id' : '1','brandName': 'BMW', 'modelName': 'X5', 'vechile_type': 'four_wheeler' , 'image': vechileBrandImage1 },
  {'id' : '2','brandName': 'Royal Enfield', 'modelName': 'Clasic 350', 'vechile_type': 'two_wheeler' , 'image': vechileBrandImage2,}, 
  {'id' : '3','brandName': 'Mahindra', 'modelName': 'XUV 3XO', 'vechile_type': 'four_wheeler' , 'image': vechileBrandImage3},
];

// Vehicle brands data
const List<Map<String, dynamic>> vehicleBrands = [
  {
    "id": "1",
    "name": "BMW",
    "logoUrl": vechileBrandImage1,
    "vehicleType": "four_wheeler",
    "models": [
      "BMW 3 Series",
      "BMW 5 Series",
      "BMW 7 Series",
      "BMW X1",
      "BMW X3",
      "BMW X5",
      "BMW X7",
      "BMW Z4",
      "BMW M3",
      "BMW i4",
    ],
  },
  {
    "id": "2",
    "name": "Royal Enfield",
    "logoUrl": vechileBrandImage2,
    "vehicleType": "two_wheeler",
    "models": [
      "Classic 350",
      "Bullet 350",
      "Hunter 350",
      "Meteor 350",
      "Interceptor 650",
      "Continental GT 650",
      "Himalayan 450",
      "Scram 411",
      "Shotgun 650",
      "Super Meteor 650",
    ],
  },
  {
    "id": "3",
    "name": "Mahindra",
    "logoUrl": vechileBrandImage3,
    "vehicleType": "four_wheeler",
    "models": [
      "Scorpio-N",
      "Scorpio Classic",
      "Bolero",
      "Bolero Neo",
      "Thar",
      "XUV300",
      "XUV400 EV",
      "XUV700",
      "Marazzo",
      "Alturas G4",
    ],
  },
  {
    "id": "4",
    "name": "Tesla",
    "logoUrl": vechileBrandImage4,
    "vehicleType": "four_wheeler_electric",
    "models": [
      "Model S",
      "Model 3",
      "Model X",
      "Model Y",
      "Cybertruck",
      "Roadster (2nd Gen)",
      "Semi",
      "Model S Plaid",
      "Model X Plaid",
      "Model 3 Performance",
    ],
  },
  {
    "id": "5",
    "name": "Ola Electric",
    "logoUrl": vechileBrandImage5,
    "vehicleType": "two_wheeler_electric",
    "models": [
      "S1 X",
      "S1 X+",
      "S1 Air",
      "S1 Pro",
      "S1",
      "S1 Gen 2",
      "S1 X (2kWh)",
      "S1 X (3kWh)",
      "S1 X (4kWh)",
      "Diamondhead (Upcoming)",
    ],
  },
];

