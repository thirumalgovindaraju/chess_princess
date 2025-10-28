// lib/presentation/providers/repositories_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../core/logger/app_logger.dart';

// Provider for Dio HTTP client
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.baseUrl = 'https://api.example.com'; // Update with your API base URL
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  // Add interceptors if needed
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add authorization headers or other request modifications
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ),
  );

  return dio;
});

// Provider for Connectivity
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

// Provider for AppLogger
final loggerProvider = Provider<AppLogger>((ref) {
  return AppLogger();
});

// Provider for LocalDataSource
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource(
    lessonsBox: Hive.box<String>('lessons'),
    drillsBox: Hive.box<String>('drills'),
    puzzlesBox: Hive.box<String>('puzzles'),
    resultsBox: Hive.box<String>('results'),
  );
});

// Main ProgressRepository Provider
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final connectivity = ref.watch(connectivityProvider);
  final localDataSource = ref.watch(localDataSourceProvider);
  final logger = ref.watch(loggerProvider);

  return ProgressRepositoryImpl(
    dio: dio,
    localDataSource: localDataSource,
    connectivity: connectivity,
    logger: logger,
  );
});