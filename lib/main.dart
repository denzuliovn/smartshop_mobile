import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smartshop_mobile/core/api/graphql_client.dart';
import 'package:smartshop_mobile/core/theme/theme.dart';
import 'package:smartshop_mobile/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final client = ref.watch(graphqlClientProvider);

    return GraphQLProvider(
      client: ValueNotifier(client),
      child: MaterialApp.router(
        title: 'SmartShop',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}