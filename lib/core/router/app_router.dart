import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/crop_detail/crop_detail_screen.dart';
import '../../features/home/advisory_detail_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/product_detail/product_detail_screen.dart';
import '../../features/video_player/video_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      // Declarative Deep Link: /crop/:id (e.g. /crop/wheat, /crop/paddy, /crop/mustard)
      GoRoute(
        path: '/crop/:id',
        name: 'crop_detail',
        builder: (context, state) {
          final cropId = state.pathParameters['id'] ?? '';
          return CropDetailScreen(cropId: cropId);
        },
      ),
      // Declarative Deep Link: /product/:id (e.g. /product/coragen, /product/tilt)
      GoRoute(
        path: '/product/:id',
        name: 'product_detail',
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          return ProductDetailScreen(productId: productId);
        },
      ),
      // Declarative Deep Link: /advisory/:id (e.g. /advisory/weather_alert_rain)
      GoRoute(
        path: '/advisory/:id',
        name: 'advisory_detail',
        builder: (context, state) {
          final advisoryId = state.pathParameters['id'] ?? '';
          return AdvisoryDetailScreen(advisoryId: advisoryId);
        },
      ),
      // Declarative Deep Link: /video/:id (e.g. /video/wheat_high_yield_masterclass)
      GoRoute(
        path: '/video/:id',
        name: 'video_player',
        builder: (context, state) {
          final videoId = state.pathParameters['id'] ?? '';
          return VideoScreen(videoId: videoId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image_outlined, size: 48),
            const SizedBox(height: 12),
            Text('No page found for ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
