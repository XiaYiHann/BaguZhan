import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/api_path_repository.dart';
import 'data/repositories/api_question_repository.dart';
import 'data/repositories/path_repository.dart';
import 'data/repositories/user_progress_repository.dart';
import 'presentation/pages/achievement_gallery_page.dart';
import 'presentation/pages/celebration_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/learning_path_map_page.dart';
import 'presentation/pages/learning_report_page.dart';
import 'presentation/pages/neo_components_showcase_page.dart';
import 'presentation/pages/path_category_page.dart'
    show PathCategoryPage, TechStackModel;
import 'presentation/pages/progress_dashboard_page.dart';
import 'presentation/pages/question_page.dart';
import 'presentation/pages/result_page.dart';
import 'presentation/pages/wrong_book_page.dart';
import 'presentation/providers/learning_path_provider.dart';
import 'presentation/providers/learning_progress_provider.dart';
import 'presentation/providers/question_provider.dart';
import 'presentation/providers/wrong_book_provider.dart';
import 'routes/page_transitions.dart';

void main() {
  runApp(const BaguzhanApp());
}

class BaguzhanApp extends StatelessWidget {
  const BaguzhanApp({super.key});

  String _getTopicIcon(String topic) {
    const icons = {
      'JavaScript': '⚡',
      'React': '⚛️',
      'Vue': '🌿',
    };
    return icons[topic] ?? '📚';
  }

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
        ChangeNotifierProvider(
          create: (_) => LearningPathProvider(ApiPathRepository()),
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
          if (settings.name == '/dashboard') {
            return DuoPageTransition(child: const ProgressDashboardPage());
          }
          if (settings.name == '/achievements') {
            return DuoPageTransition(child: const AchievementGalleryPage());
          }
          if (settings.name == '/celebration') {
            return DuoPageTransition(child: const CelebrationPage());
          }
          if (settings.name == '/components-showcase') {
            return DuoPageTransition(child: const NeoComponentsShowcasePage());
          }
          if (settings.name == '/path-categories') {
            final topic = settings.arguments as String? ?? 'JavaScript';
            final techStack = TechStackModel(
              id: topic.toLowerCase(),
              name: topic,
              icon: _getTopicIcon(topic),
              description: '$topic 学习路径',
            );
            return DuoPageTransition(
              child: PathCategoryPage(techStack: techStack),
            );
          }
          if (settings.name == '/path-map') {
            final args = settings.arguments as Map<String, dynamic>?;
            final techStack = args?['techStack'] as TechStackModel?;
            final categoryId = args?['categoryId'] as String?;
            if (techStack != null && categoryId != null) {
              return DuoPageTransition(
                child: LearningPathMapPage(
                  techStack: techStack,
                  categoryId: categoryId,
                ),
              );
            }
            return DuoPageTransition(child: const HomePage());
          }
          return DuoPageTransition(child: const HomePage());
        },
      ),
    );
  }
}
