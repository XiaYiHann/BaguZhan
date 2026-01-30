import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/api_question_repository.dart';
import 'data/repositories/user_progress_repository.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/learning_report_page.dart';
import 'presentation/pages/question_page.dart';
import 'presentation/pages/result_page.dart';
import 'presentation/pages/wrong_book_page.dart';
import 'presentation/providers/learning_progress_provider.dart';
import 'presentation/providers/question_provider.dart';
import 'presentation/providers/wrong_book_provider.dart';
import 'routes/page_transitions.dart';

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
          create: (_) => QuestionProvider(
            ApiQuestionRepository(),
            userProgressRepository: ApiUserProgressRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WrongBookProvider(ApiUserProgressRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => LearningProgressProvider(ApiUserProgressRepository()),
        ),
      ],
      child: MaterialApp(
        title: '八股斩',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/question') {
            final topic = settings.arguments as String? ?? 'JavaScript';
            return DuoPageTransition(
              child: QuestionPage(topic: topic),
            );
          }
          if (settings.name == '/result') {
            return DuoPageTransition(child: const ResultPage());
          }
          if (settings.name == '/wrong-book') {
            return DuoPageTransition(child: const WrongBookPage());
          }
          if (settings.name == '/learning-report') {
            return DuoPageTransition(
              child: const LearningReportPage(),
            );
          }
          return DuoPageTransition(child: const HomePage());
        },
      ),
    );
  }
}
