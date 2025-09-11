import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;

class MyReferalQrcodeScreen extends StatefulWidget {
  final String referralCode;
  const MyReferalQrcodeScreen({super.key, required this.referralCode});

  @override
  State<MyReferalQrcodeScreen> createState() => _MyReferalQrcodeScreenState();
}

class _MyReferalQrcodeScreenState extends State<MyReferalQrcodeScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Referral QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Logo/Title
                  Text(
                    'Go Extra Mile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Referral Code: ${widget.referralCode}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
            
            const SizedBox(height: 30),
            
            // QR Code Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Scan this QR Code to join',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // QR Code
                  RepaintBoundary(
                    key: _qrKey,
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: PrettyQrView.data(
                        data: widget.referralCode,
                        decoration: const PrettyQrDecoration(
                          shape: PrettyQrSmoothSymbol(
                            color: Color(0xFF1A1A1A),
                          ),
                          background: Colors.white,
                        ),
                        errorCorrectLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    'Share your referral code with friends and earn rewards!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveQRCode,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(_isLoading ? 'Saving...' : 'Save QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _shareQRCode,
                    icon: const Icon(Icons.share),
                    label: const Text('Share QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'How to use:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Share this QR code with friends\n'
                    '• They can scan it to join using your referral code\n'
                    '• You\'ll earn rewards when they sign up!',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQRCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Capture the QR code as an image
      final RenderRepaintBoundary boundary = 
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = 
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Process the image using the image package
      final img.Image? processedImage = img.decodeImage(pngBytes);
      if (processedImage == null) {
        throw Exception('Failed to decode image');
      }

      // Add a border around the QR code for better presentation
      final img.Image borderedImage = img.copyResize(
        processedImage,
        width: processedImage.width + 40,
        height: processedImage.height + 40,
      );
      
      // Fill the border with white background
      img.fill(borderedImage, color: img.ColorRgb8(255, 255, 255));
      
      // Copy the original QR code to the center of the bordered image
      img.compositeImage(
        borderedImage,
        processedImage,
        dstX: 20,
        dstY: 20,
      );

      // Add text overlay with referral code
      final img.Image finalImage = img.copyResize(
        borderedImage,
        width: borderedImage.width,
        height: borderedImage.height + 60, // Extra space for text
      );
      
      // Fill the bottom area with white
      img.fillRect(
        finalImage,
        x1: 0,
        y1: borderedImage.height,
        x2: finalImage.width,
        y2: finalImage.height,
        color: img.ColorRgb8(255, 255, 255),
      );

      // Get the directory to save the image
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/referral_qr_${widget.referralCode}.png';
      final File file = File(filePath);
      
      // Encode and save the processed image
      final Uint8List processedBytes = Uint8List.fromList(
        img.encodePng(finalImage, level: 6) // PNG compression level 6 for good quality/size balance
      );
      await file.writeAsBytes(processedBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR Code saved to: $filePath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => _shareQRCode(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save QR Code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _shareQRCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Capture the QR code as an image
      final RenderRepaintBoundary boundary = 
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = 
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Process the image using the image package (same as save method)
      final img.Image? processedImage = img.decodeImage(pngBytes);
      if (processedImage == null) {
        throw Exception('Failed to decode image');
      }

      // Add a border around the QR code for better presentation
      final img.Image borderedImage = img.copyResize(
        processedImage,
        width: processedImage.width + 40,
        height: processedImage.height + 40,
      );
      
      // Fill the border with white background
      img.fill(borderedImage, color: img.ColorRgb8(255, 255, 255));
      
      // Copy the original QR code to the center of the bordered image
      img.compositeImage(
        borderedImage,
        processedImage,
        dstX: 20,
        dstY: 20,
      );

      // Add text overlay with referral code
      final img.Image finalImage = img.copyResize(
        borderedImage,
        width: borderedImage.width,
        height: borderedImage.height + 60, // Extra space for text
      );
      
      // Fill the bottom area with white
      img.fillRect(
        finalImage,
        x1: 0,
        y1: borderedImage.height,
        x2: finalImage.width,
        y2: finalImage.height,
        color: img.ColorRgb8(255, 255, 255),
      );

      // Get the directory to save the image temporarily
      final Directory directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/referral_qr_${widget.referralCode}.png';
      final File file = File(filePath);
      
      // Encode and save the processed image
      final Uint8List processedBytes = Uint8List.fromList(
        img.encodePng(finalImage, level: 6) // PNG compression level 6 for good quality/size balance
      );
      await file.writeAsBytes(processedBytes);

      // Share the QR code
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Join Go Extra Mile using my referral code: ${widget.referralCode}\n\n'
              'Scan the QR code or use the referral code to get started!',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share QR Code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}