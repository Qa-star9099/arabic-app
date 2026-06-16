import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  void _signInWithGoogle() {
    ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.welcome);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              
              // App Logo / Illustration here
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.graduationCap, size: 60, color: AppColors.emerald),
                ),
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                'Xush kelibsiz',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Arab tilini o\'rganishni boshlash uchun\nhisobingizga kiring',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 16,
                  color: Color(0x99FFFFFF), // white 60%
                  height: 1.5,
                ),
              ),
              const Spacer(),
              
              if (authState.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Xatolik yuz berdi: ${authState.error}',
                    style: const TextStyle(color: Colors.redAccent, fontFamily: 'Geist'),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Google Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _signInWithGoogle,
                  icon: isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black))
                      : const FaIcon(FontAwesomeIcons.google, color: Colors.black, size: 20),
                  label: Text(
                    isLoading ? 'Kirilmoqda...' : 'Google orqali kirish',
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

