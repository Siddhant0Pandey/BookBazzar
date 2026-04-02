// lib/screens/splash_screen.dart
// Shows logo while app initialises — replaces cold-start blank screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    // Navigate after init completes
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  Future<void> _navigate() async {
    // Wait for provider to finish loading (it started init() in main)
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    if (provider.isRegistered) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/register');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w900,
                      letterSpacing: -0.5),
                    children: [
                      TextSpan(text: 'Book',
                        style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'Bazzar',
                        style: TextStyle(color: Color(0xFFFFA726))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Offline Inventory & Credit Tracker',
                  style: TextStyle(
                    color: Colors.white60, fontSize: 13,
                    fontWeight: FontWeight.w400)),
                const SizedBox(height: 60),
                const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white54, strokeWidth: 2.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
