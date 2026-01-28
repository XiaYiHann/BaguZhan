import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/api_question_repository.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/question_page.dart';
import 'presentation/pages/result_page.dart';
import 'presentation/providers/question_provider.dart';

void main() {
  runApp(const BaguzhanApp());
}

class BaguzhanApp extends StatelessWidget {
  const BaguzhanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => QuestionProvider(ApiQuestionRepository()),
        ),
      ],
      child: MaterialApp(
        title: '八股斩',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/question') {
            final topic = settings.arguments as String? ?? 'JavaScript';
            return MaterialPageRoute(
              builder: (_) => QuestionPage(topic: topic),
            );
          }
          if (settings.name == '/result') {
            return MaterialPageRoute(builder: (_) => const ResultPage());
          }
          return MaterialPageRoute(builder: (_) => const HomePage());
        },
      ),
    );
  }
}
