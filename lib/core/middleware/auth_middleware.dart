import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ats/core/constants/app_constants.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Check Firebase Auth directly for synchronous check
    final firebaseUser = FirebaseAuth.instance.currentUser;
    
    // List of public auth routes that don't require authentication
    final publicRoutes = [
      AppConstants.routeLogin,
      AppConstants.routeSignUp,
      AppConstants.routeAdminLogin,
      AppConstants.routeAdminSignUp,
    ];
    
    if (firebaseUser == null) {
      // Not authenticated - allow only public auth routes
      if (publicRoutes.contains(route)) {
        return null; // Allow access to auth routes
      }
      // Redirect to login for protected routes
      return const RouteSettings(name: AppConstants.routeLogin);
    } else {
      // Authenticated - redirect away from auth routes
      // The actual role-based redirect will be handled by the route or AdminMiddleware
      if (publicRoutes.contains(route)) {
        // User is logged in but trying to access auth routes
        // Redirect to candidate dashboard (default)
        // AdminMiddleware will handle admin-specific routes
        return const RouteSettings(name: AppConstants.routeCandidateDashboard);
      }
    }
    
    return null; // Allow access to protected routes
  }
}

