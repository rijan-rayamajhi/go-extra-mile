import 'package:flutter/material.dart';

// App Constants - Centralized configuration values
// All constants must be compile-time constants (const keyword)

// String Constants
const String appName = 'Go Extra Mile';

//paddings
const double screenPadding = 16.0;

//radius
const double buttonRadius = 16;

//button height
const double buttonHeight = 48;

//button width
const double buttonWidth = double.infinity;


//spacing 
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

// Vehicle data
const List<Map<String, String>> vehicles = [
  { 'id' : '1','brandName': 'BMW', 'modelName': 'X5', 'vechile_type': 'four_wheeler' , 'image': vechileBrandImage1 },
  {'id' : '2','brandName': 'Royal Enfield', 'modelName': 'Clasic 350', 'vechile_type': 'two_wheeler' , 'image': vechileBrandImage2,}, 
  {'id' : '3','brandName': 'Mahindra', 'modelName': 'XUV 3XO', 'vechile_type': 'four_wheeler' , 'image': vechileBrandImage3},
];

