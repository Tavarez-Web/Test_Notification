import 'package:go_router/go_router.dart';
import 'package:test_notification/home_page.dart';
import '../../presentation/screens/details_screen.dart';

final appRouter = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => HomePage(),
  ),
  GoRoute(
      path: '/push-details/:messageId',
      builder: (context, state) {
      
        return DetailScreen(
          pushMessaheId: state.pathParameters['messageId'] ?? '404',
        );
      })
]);
