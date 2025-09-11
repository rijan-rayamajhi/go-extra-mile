import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';

class HomeFooterWidget extends StatefulWidget {
  const HomeFooterWidget({super.key});

  @override
  State<HomeFooterWidget> createState() => _HomeFooterWidgetState();
}

class _HomeFooterWidgetState extends State<HomeFooterWidget> {
  bool copied = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Future to get referral code from Firebase
  Future<String> _getReferralCode() async {
    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Fetch user document from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data()!;
      final referralCode = userData['referralCode'] as String?;

      if (referralCode == null || referralCode.isEmpty) {
        // Fallback: generate referral code from UID if not exists
        return currentUser.uid.substring(0, 7).toUpperCase();
      }

      return referralCode;
    } catch (e) {
      // Log error for debugging
      
      // Fallback: try to generate from current user UID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        return currentUser.uid.substring(0, 7).toUpperCase();
      }
      
      // Final fallback
      throw Exception('Failed to fetch referral code: $e');
    }
  }

  // Future to get total GEM coins from all users
  Future<String> _getTotalGemCoins() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('totalGemCoins', isGreaterThan: 0)
          .get();

      double total = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final gemCoins = (data['totalGemCoins'] as num?)?.toDouble() ?? 0;
        total += gemCoins;
      }

      return _formatNumber(total.toInt());
    } catch (e) {
      return '0';
    }
  }

  // Future to get total distance from all users
  Future<String> _getTotalDistance() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('totalDistance', isGreaterThan: 0)
          .get();

      double total = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final distance = (data['totalDistance'] as num?)?.toDouble() ?? 0;
        total += distance;
      }

      return _formatNumber(total.toInt());
    } catch (e) {
      return '0';
    }
  }

  // Future to get total rides from all users
  Future<String> _getTotalRides() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('totalRide', isGreaterThan: 0)
          .get();

      int total = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final rides = (data['totalRide'] as num?)?.toInt() ?? 0;
        total += rides;
      }

      return _formatNumber(total);
    } catch (e) {
      return '0';
    }
  }

  // Helper method to format numbers with commas
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _showInviteOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Invite Friends',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Gilroy',
              ),
            ),
            const SizedBox(height: 20),
            _InviteOption(
              icon: Icons.share,
              title: 'Share via App',
              subtitle: 'Share with any app',
              onTap: () => _shareReferralLink(),
            ),
            const SizedBox(height: 12),
            _InviteOption(
              icon: Icons.message,
              title: 'WhatsApp',
              subtitle: 'Share on WhatsApp',
              onTap: () => _shareViaWhatsApp(),
            ),
            const SizedBox(height: 12),
            _InviteOption(
              icon: Icons.copy,
              title: 'Copy Link',
              subtitle: 'Copy referral link',
              onTap: () => _copyReferralLink(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _shareReferralLink() async {
    final referralCode = await _getReferralCode();
    final shareText = _getShareText(referralCode);
    Share.share(shareText, subject: 'Join GEM - Earn Rewards Together!');
  }

  void _shareViaWhatsApp() async {
    final referralCode = await _getReferralCode();
    final shareText = _getShareText(referralCode);
    final whatsappUrl =
        'whatsapp://send?text=${Uri.encodeComponent(shareText)}';

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        _showErrorSnackBar('WhatsApp not installed');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open WhatsApp');
    }
  }

  void _copyReferralLink() async {
    final referralCode = await _getReferralCode();
    final shareText = _getShareText(referralCode);
    Clipboard.setData(ClipboardData(text: shareText));
    _showSuccessSnackBar('Referral link copied to clipboard!');
  }

  String _getShareText(String referralCode) {
    return '''🚀 Join GEM and start earning rewards!

Use my referral code: $referralCode

Download GEM app and earn up to 100 GEM Coins when you sign up!

#GEM #Rewards #Referral''';
  }

  void _showSuccessSnackBar(String message) {
    AppSnackBar.success(context, message);
  }

  void _showErrorSnackBar(String message) {
    AppSnackBar.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 36),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'So far our GEM Riders have',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Gilroy',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              // Stat Blocks
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FutureBuilder<String>(
                      future: _getTotalGemCoins(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _StatBlock(
                            label: 'GEM Coins',
                            value: '...',
                            subLabel: 'EARNED',
                            labelColor: Colors.blue,
                            subLabelColor: Color(0xFFBDBDBD),
                            valueFontSize: 24,
                            labelFontSize: 16,
                            subLabelFontSize: 12,
                            valueFontWeight: FontWeight.w700,
                          );
                        }
                        return _StatBlock(
                          label: 'GEM Coins',
                          value: snapshot.data ?? '0',
                          subLabel: 'EARNED',
                          labelColor: Colors.blue,
                          subLabelColor: Color(0xFFBDBDBD),
                          valueFontSize: 24,
                          labelFontSize: 16,
                          subLabelFontSize: 12,
                          valueFontWeight: FontWeight.w700,
                        );
                      },
                    ),
                    FutureBuilder<String>(
                      future: _getTotalDistance(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _StatBlock(
                            label: 'Distance',
                            value: '...',
                            subLabel: 'KMs',
                            labelColor: Colors.blue,
                            subLabelColor: Color(0xFFBDBDBD),
                            valueFontSize: 24,
                            labelFontSize: 16,
                            subLabelFontSize: 12,
                            valueFontWeight: FontWeight.w700,
                          );
                        }
                        return _StatBlock(
                          label: 'Distance',
                          value: snapshot.data ?? '0',
                          subLabel: 'KMs',
                          labelColor: Colors.blue,
                          subLabelColor: Color(0xFFBDBDBD),
                          valueFontSize: 24,
                          labelFontSize: 16,
                          subLabelFontSize: 12,
                          valueFontWeight: FontWeight.w700,
                        );
                      },
                    ),
                    FutureBuilder<String>(
                      future: _getTotalRides(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _StatBlock(
                            label: 'Rides',
                            value: '...',
                            subLabel: 'COMPLETED',
                            labelColor: Colors.blue,
                            valueFontSize: 24,
                            labelFontSize: 16,
                            valueFontWeight: FontWeight.w700,
                          );
                        }
                        return _StatBlock(
                          label: 'Rides',
                          value: snapshot.data ?? '0',
                          subLabel: 'COMPLETED',
                          labelColor: Colors.blue,
                          valueFontSize: 24,
                          labelFontSize: 16,
                          valueFontWeight: FontWeight.w700,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              // Refer and Earn Section
              const Text(
                'Refer and Earn',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  fontFamily: 'Gilroy',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 16,
                    fontFamily: 'Gilroy',
                  ),
                  children: [
                    TextSpan(text: 'Refer and Earn'),
                    TextSpan(
                      text: '100 GEM Coins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(text: ' , You win upto '),
                    TextSpan(
                      text: '100 GEM Coins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Referral Code Row with FutureBuilder
              FutureBuilder<String>(
                future: _getReferralCode(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Row(
                      children: [
                        const Text(
                          'Referral Code:',
                          style: TextStyle(
                            color: Color(0xFFBDBDBD),
                            fontSize: 16,
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ],
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Row(
                      children: [
                        const Text(
                          'Referral Code:',
                          style: TextStyle(
                            color: Color(0xFFBDBDBD),
                            fontSize: 16,
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Error loading',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ],
                    );
                  }
                  
                  final referralCode = snapshot.data ?? 'N/A';
                  return Row(
                    children: [
                      const Text(
                        'Referral Code:',
                        style: TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontSize: 16,
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        referralCode,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: referralCode),
                          );
                          setState(() {
                            copied = true;
                          });
                          Future.delayed(const Duration(seconds: 1), () {
                            if (mounted) setState(() => copied = false);
                          });
                        },
                        child: Icon(
                          copied ? Icons.check : Icons.copy,
                          color: copied ? Colors.green : Colors.blue,
                          size: 20,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              //Outline Button
              OutlinedButton(
                onPressed: _showInviteOptions,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Invite',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: Text(
                  'Made with ❤️ in India by Go Extra Mile.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Gilroy',
                    color: Colors.grey,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'App Version v0.0.4',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          // Illustration floating at top right
          Positioned(
            bottom: 32,
            right: 0,
            child: SizedBox(
              width: 140,
              height: 140,
              child: Image.asset('assets/images/undraw_share_1zw4.png'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final String? subLabel;
  final Color labelColor;
  final Color? subLabelColor;
  final double valueFontSize;
  final double labelFontSize;
  final double? subLabelFontSize;
  final FontWeight valueFontWeight;

  const _StatBlock({
    required this.label,
    required this.value,
    this.subLabel,
    required this.labelColor,
    this.subLabelColor,
    this.valueFontSize = 24,
    this.labelFontSize = 16,
    this.subLabelFontSize,
    this.valueFontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.w600,
              fontSize: labelFontSize,
              fontFamily: 'Gilroy',
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: valueFontWeight,
                  fontSize: valueFontSize,
                  color: Colors.black,
                  fontFamily: 'Gilroy',
                ),
              ),
              if (subLabel != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    subLabel!,
                    style: TextStyle(
                      color: subLabelColor ?? Color(0xFFBDBDBD),
                      fontWeight: FontWeight.w600,
                      fontSize: subLabelFontSize ?? 12,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InviteOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _InviteOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}
