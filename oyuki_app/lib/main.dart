import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth_screens.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/store_page.dart';
import 'screens/product_page.dart';
import 'screens/search_screens.dart';
import 'screens/cart_screen.dart';
import 'screens/tracking_screens.dart';
import 'screens/profile_screens.dart';
import 'screens/wallet_screen.dart';
import 'screens/address_screen.dart';
import 'screens/cards_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme.dart';

void main() => runApp(const OyukiApp());

class OyukiApp extends StatelessWidget {
  const OyukiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Oyuki Marketplace',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme(),
          primaryColor: AppColors.green,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/get-started': (_) => const GetStartedScreen(),
          '/signup': (_) => const SignUpScreen(),
          '/login': (_) => const LoginScreen(),
          '/forgot': (_) => const ForgotPasswordScreen(),
          '/otp-forgot': (_) => const OtpForgotScreen(),
          '/reset': (_) => const ResetPasswordScreen(),
          '/otp-signup': (_) => const OtpSignUpScreen(),
          '/otp-filled': (_) => const OtpSignUpScreen(filled: true),
          '/home': (_) => const HomeScreen(),
          '/category': (_) => const CategoryScreen(),
          '/store': (_) => const StorePage(),
          '/product': (_) => const ProductPage(),
          '/search': (_) => const SearchScreen(),
          '/search-result': (_) => const SearchResultScreen(),
          '/cart': (_) => const CartScreen(),
          '/order-tracking': (_) => const OrderTrackingScreen(),
          '/live-tracking': (_) => const LiveTrackingScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/profile-edit': (_) => const ProfileEditScreen(),
          '/wallet': (_) => const WalletScreen(),
          '/addresses': (_) => const AddressScreen(),
          '/cards': (_) => const CardsScreen(),
        },
      );
}