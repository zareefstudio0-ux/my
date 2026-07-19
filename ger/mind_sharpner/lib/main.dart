import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async'; // Added for Timer
import 'dart:math' as math;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:streak_plus/streak_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MainApp());
}

// ==================== SERVICES ====================

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  final AudioPlayer _tapPlayer = AudioPlayer();
  final AudioPlayer _selectPlayer = AudioPlayer();
  final AudioPlayer _winPlayer = AudioPlayer();
  final AudioPlayer _losePlayer = AudioPlayer();
  final AudioPlayer _startPlayer = AudioPlayer();

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _hapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    // Pre-set volume
    _tapPlayer.setVolume(0.5);
    _selectPlayer.setVolume(0.5);
    _winPlayer.setVolume(0.7);
    _losePlayer.setVolume(0.6);
    _startPlayer.setVolume(0.6);
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
  }

  Future<void> setHapticsEnabled(bool value) async {
    _hapticsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics_enabled', value);
  }

  Future<void> _playSound(AudioPlayer player, String asset) async {
    if (_soundEnabled) {
      try {
        await player.stop();
        await player.play(AssetSource(asset), mode: PlayerMode.lowLatency);
      } catch (_) {}
    }
  }

  Future<void> playTap() async {
    if (_hapticsEnabled) HapticFeedback.lightImpact();
    await _playSound(_tapPlayer, 'sounds/tap.wav');
  }

  Future<void> playWin() async {
    if (_hapticsEnabled) HapticFeedback.heavyImpact();
    await _playSound(_winPlayer, 'sounds/win.wav');
  }

  Future<void> playLose() async {
    if (_hapticsEnabled) HapticFeedback.mediumImpact();
    await _playSound(_losePlayer, 'sounds/lose.wav');
  }

  Future<void> playSelect() async {
    if (_hapticsEnabled) HapticFeedback.mediumImpact();
    await _playSound(_selectPlayer, 'sounds/select.wav');
  }

  Future<void> playStart() async {
    if (_hapticsEnabled) HapticFeedback.mediumImpact();
    await _playSound(_startPlayer, 'sounds/start.wav');
  }

  Future<void> playError() async {
    if (_hapticsEnabled) HapticFeedback.vibrate();
    await _playSound(_losePlayer, 'sounds/lose.wav');
  }
}

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  bool _animationsEnabled = true;
  bool _darkMode = true;

  bool get animationsEnabled => _animationsEnabled;
  bool get darkMode => _darkMode;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _animationsEnabled = prefs.getBool('animations_enabled') ?? true;
    _darkMode = prefs.getBool('dark_mode') ?? true;
  }

  Future<void> setAnimationsEnabled(bool value) async {
    _animationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('animations_enabled', value);
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }
}

class SharedPreferencesStorage implements StreakStorage {
  @override
  Future<void> save(StreakModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('streak_data', jsonEncode(model.toMap()));
  }

  @override
  Future<StreakModel?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('streak_data');
    if (json == null) return null;
    return StreakModel.fromMap(jsonDecode(json));
  }

  @override
  Future<void> clear() async =>
      (await SharedPreferences.getInstance()).remove('streak_data');
}

class StatsManager {
  static final StatsManager _instance = StatsManager._internal();
  factory StatsManager() => _instance;
  StatsManager._internal();

  Map<String, int> _stats = {
    'total_games': 0,
    'tic_tac_wins': 0,
    'tic_tac_losses': 0,
    'tic_tac_draws': 0,
    'best_streak': 0,
    'current_streak': 0,
    'total_wins': 0,
  };

  late final StreakPlus _streak;

  Map<String, int> get stats => _stats;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _stats = {
      'total_games': prefs.getInt('total_games') ?? 0,
      'tic_tac_wins': prefs.getInt('tic_tac_wins') ?? 0,
      'tic_tac_losses': prefs.getInt('tic_tac_losses') ?? 0,
      'tic_tac_draws': prefs.getInt('tic_tac_draws') ?? 0,
      'best_streak': prefs.getInt('best_streak') ?? 0,
      'current_streak': prefs.getInt('current_streak') ?? 0,
      'total_wins': prefs.getInt('total_wins') ?? 0,
    };

    _streak = StreakPlus(storage: SharedPreferencesStorage());
    await _streak.init();
    _updateStreaks();
  }

  void _updateStreaks() {
    _stats['current_streak'] = _streak.currentStreak;
    _stats['best_streak'] = _streak.longestStreak;
    // Change identity to trigger UI refresh in IndexedStack
    _stats = Map<String, int>.from(_stats);
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in _stats.entries) {
      await prefs.setInt(entry.key, entry.value);
    }
  }

  Future<void> recordGamePlayed() async {
    _stats['total_games'] = (_stats['total_games'] ?? 0) + 1;
    await _streak.logEvent(DateTime.now());
    _updateStreaks();
    await _saveStats();
  }

  Future<void> recordTicTacWin() async {
    _stats['tic_tac_wins'] = (_stats['tic_tac_wins'] ?? 0) + 1;
    _stats['total_wins'] = (_stats['total_wins'] ?? 0) + 1;
    await recordGamePlayed();
  }

  Future<void> recordTicTacLoss() async {
    _stats['tic_tac_losses'] = (_stats['tic_tac_losses'] ?? 0) + 1;
    await recordGamePlayed();
  }

  Future<void> recordTicTacDraw() async {
    _stats['tic_tac_draws'] = (_stats['tic_tac_draws'] ?? 0) + 1;
    await recordGamePlayed();
  }

  Future<void> resetStats() async {
    _stats = {
      'total_games': 0,
      'tic_tac_wins': 0,
      'tic_tac_losses': 0,
      'tic_tac_draws': 0,
      'best_streak': 0,
      'current_streak': 0,
      'total_wins': 0,
    };
    await SharedPreferencesStorage().clear();
    await _streak.init();
    _updateStreaks();
    await _saveStats();
  }
}

class GameStateManager {
  static final GameStateManager _instance = GameStateManager._internal();
  factory GameStateManager() => _instance;
  GameStateManager._internal();

  Future<void> saveGameState({
    required String gameType,
    required List<int> board,
    required bool isPlayerTurn,
    required int gridSize,
    required String difficulty,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'current_game',
      jsonEncode({
        'gameType': gameType,
        'board': board,
        'isPlayerTurn': isPlayerTurn,
        'gridSize': gridSize,
        'difficulty': difficulty,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<Map<String, dynamic>?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('current_game');
    if (saved != null) {
      return jsonDecode(saved);
    }
    return null;
  }

  Future<void> clearGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_game');
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.unlocked = false,
  });

  Map<String, dynamic> toJson() => {'id': id, 'unlocked': unlocked};

  factory Achievement.fromJson(String id, Map<String, dynamic> json) {
    final achievement = _allAchievements.firstWhere((a) => a.id == id);
    achievement.unlocked = json['unlocked'] ?? false;
    return achievement;
  }
}

final List<Achievement> _allAchievements = [
  Achievement(
    id: 'first_game',
    title: 'First Steps',
    description: 'Play your first game',
    icon: Icons.star,
    color: const Color(0xFFFFE600),
  ),
  Achievement(
    id: 'first_win',
    title: 'First Victory',
    description: 'Win your first Tic Tac Toe game',
    icon: Icons.emoji_events,
    color: const Color(0xFFFFD700),
  ),
  Achievement(
    id: 'wins_5',
    title: 'Rising Star',
    description: 'Win 5 Tic Tac Toe games',
    icon: Icons.star,
    color: const Color(0xFF00E5FF),
  ),
  Achievement(
    id: 'wins_10',
    title: 'Sharpshooter',
    description: 'Win 10 Tic Tac Toe games',
    icon: Icons.gps_fixed,
    color: const Color(0xFF00BCD4),
  ),
  Achievement(
    id: 'wins_25',
    title: 'Champion',
    description: 'Win 25 Tic Tac Toe games',
    icon: Icons.military_tech,
    color: const Color(0xFFB100FF),
  ),
  Achievement(
    id: 'wins_50',
    title: 'Grandmaster',
    description: 'Win 50 Tic Tac Toe games',
    icon: Icons.workspace_premium,
    color: const Color(0xFFFF6D00),
  ),
  Achievement(
    id: 'unstoppable',
    title: 'Unstoppable',
    description: 'Play 5 games in a row',
    icon: Icons.local_fire_department,
    color: const Color(0xFFFF4500),
  ),
  Achievement(
    id: 'streak_10',
    title: 'On Fire',
    description: 'Play 10 games in a row',
    icon: Icons.whatshot,
    color: const Color(0xFFFF007F),
  ),
  Achievement(
    id: 'streak_25',
    title: 'Marathon Runner',
    description: 'Play 25 games in a row',
    icon: Icons.bolt,
    color: const Color(0xFFFFAB00),
  ),
  Achievement(
    id: 'first_draw',
    title: 'Stalemate',
    description: 'Get your first draw',
    icon: Icons.handshake,
    color: const Color(0xFFFFE600),
  ),
  Achievement(
    id: 'draws_10',
    title: 'Diplomat',
    description: 'Reach 10 draws',
    icon: Icons.balance,
    color: const Color(0xFF00FFFF),
  ),
  Achievement(
    id: 'first_loss',
    title: 'Learning Curve',
    description: 'Lose your first game — it\'s part of the journey',
    icon: Icons.school,
    color: const Color(0xFF9E9E9E),
  ),
  Achievement(
    id: 'losses_10',
    title: 'Never Give Up',
    description: 'Lose 10 games and keep playing',
    icon: Icons.fitness_center,
    color: const Color(0xFF795548),
  ),
  Achievement(
    id: 'games_10',
    title: 'Getting Started',
    description: 'Play 10 games',
    icon: Icons.games,
    color: const Color(0xFF00E5FF),
  ),
  Achievement(
    id: 'games_50',
    title: 'Dedicated Player',
    description: 'Play 50 games',
    icon: Icons.sports_esports,
    color: const Color(0xFFFF007F),
  ),
  Achievement(
    id: 'games_100',
    title: 'Veteran',
    description: 'Play 100 games',
    icon: Icons.shield,
    color: const Color(0xFFB100FF),
  ),
  Achievement(
    id: 'games_250',
    title: 'Legend',
    description: 'Play 250 games',
    icon: Icons.diamond,
    color: const Color(0xFF00E676),
  ),
  Achievement(
    id: 'perfect_3x3',
    title: 'Quick Thinker',
    description: 'Win a 3x3 game on Hard difficulty',
    icon: Icons.flash_on,
    color: const Color(0xFFFFD600),
  ),
  Achievement(
    id: 'big_board_win',
    title: 'Big Brain',
    description: 'Win a game on 7x7 or larger board',
    icon: Icons.psychology,
    color: const Color(0xFF7C4DFF),
  ),
];

class AchievementManager {
  static final AchievementManager _instance = AchievementManager._internal();
  factory AchievementManager() => _instance;
  AchievementManager._internal();

  List<Achievement> _achievements = List.from(_allAchievements);

  List<Achievement> get achievements => _achievements;
  int get unlockedCount => _achievements.where((a) => a.unlocked).length;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('achievements');
    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);
      for (var item in decoded) {
        final id = item['id'] as String;
        final achievement = _achievements.firstWhere((a) => a.id == id);
        achievement.unlocked = item['unlocked'] ?? false;
      }
    }
  }

  Future<bool> unlockAchievement(String id) async {
    final achievement = _achievements.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('Achievement not found'),
    );

    if (!achievement.unlocked) {
      achievement.unlocked = true;
      // Change identity to trigger UI refresh
      _achievements = List<Achievement>.from(_achievements);
      await _saveAchievements();
      return true;
    }
    return false;
  }

  Future<void> checkAndUnlockAchievements({
    String? difficulty,
    int? gridSize,
  }) async {
    final stats = StatsManager().stats;

    if (stats['total_games']! >= 1) {
      await unlockAchievement('first_game');
    }

    if (stats['tic_tac_wins']! >= 1) {
      await unlockAchievement('first_win');
    }

    if (stats['tic_tac_wins']! >= 5) {
      await unlockAchievement('wins_5');
    }

    if (stats['tic_tac_wins']! >= 10) {
      await unlockAchievement('wins_10');
    }

    if (stats['tic_tac_wins']! >= 25) {
      await unlockAchievement('wins_25');
    }

    if (stats['tic_tac_wins']! >= 50) {
      await unlockAchievement('wins_50');
    }

    if (stats['best_streak']! >= 5) {
      await unlockAchievement('unstoppable');
    }

    if (stats['best_streak']! >= 10) {
      await unlockAchievement('streak_10');
    }

    if (stats['best_streak']! >= 25) {
      await unlockAchievement('streak_25');
    }

    if (stats['tic_tac_draws']! >= 1) {
      await unlockAchievement('first_draw');
    }

    if (stats['tic_tac_draws']! >= 10) {
      await unlockAchievement('draws_10');
    }

    if (stats['tic_tac_losses']! >= 1) {
      await unlockAchievement('first_loss');
    }

    if (stats['tic_tac_losses']! >= 10) {
      await unlockAchievement('losses_10');
    }

    if (stats['total_games']! >= 10) {
      await unlockAchievement('games_10');
    }
    if (stats['total_games']! >= 50) {
      await unlockAchievement('games_50');
    }
    if (stats['total_games']! >= 100) {
      await unlockAchievement('games_100');
    }
    if (stats['total_games']! >= 250) {
      await unlockAchievement('games_250');
    }

    // Context-specific achievements
    if (difficulty == 'Hard' && gridSize == 3 && stats['tic_tac_wins']! >= 1) {
      await unlockAchievement('perfect_3x3');
    }
    if (gridSize != null && gridSize >= 7 && stats['tic_tac_wins']! >= 1) {
      await unlockAchievement('big_board_win');
    }
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _achievements.map((a) => a.toJson()).toList();
    await prefs.setString('achievements', jsonEncode(encoded));
  }

  Future<void> resetAchievements() async {
    for (var achievement in _achievements) {
      achievement.unlocked = false;
    }
    await _saveAchievements();
  }
}

class RateAppManager {
  static final RateAppManager _instance = RateAppManager._internal();
  factory RateAppManager() => _instance;
  RateAppManager._internal();

  int _launchCount = 0;
  bool _rated = false;
  bool _reminded = false;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _launchCount = prefs.getInt('launch_count') ?? 0;
    _rated = prefs.getBool('rated') ?? false;
    _reminded = prefs.getBool('reminded') ?? false;
    _launchCount++;
    await prefs.setInt('launch_count', _launchCount);
  }

  Future<void> checkAndShowRateDialog(BuildContext context) async {
    if (_rated || _reminded) return;
    if (_launchCount >= 3) {
      _reminded = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('reminded', true);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A0B2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Enjoying Mind Sharpener?',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Please take a moment to rate us! Your feedback helps us improve.',
              style: GoogleFonts.outfit(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Later',
                  style: GoogleFonts.outfit(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: () async {
                  _rated = true;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('rated', true);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Thank you for your support!'),
                      backgroundColor: const Color(0xFFB100FF),
                    ),
                  );
                },
                child: Text(
                  'Rate Now',
                  style: GoogleFonts.outfit(color: const Color(0xFF00E5FF)),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}

// ==================== MAIN APP ====================

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Sharpener',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A061E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFB100FF),
          secondary: Color(0xFF00FFFF),
          surface: Color(0xFF1A0B2E),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await SoundService().initialize();
    await SettingsManager().initialize();
    await StatsManager().initialize();
    await AchievementManager().initialize();
    await RateAppManager().initialize();

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1A0B2E), Color(0xFF0A061E)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB100FF), Color(0xFF00FFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB100FF).withAlpha(100),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology,
                      size: 80,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .fade(duration: 400.ms),
              const SizedBox(height: 40),
              Text(
                    'Mind Sharpener',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  )
                  .animate()
                  .fade(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 10),
              Text(
                'Train Your Brain',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(150),
                  letterSpacing: 2,
                ),
              ).animate().fade(delay: 500.ms, duration: 600.ms),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB100FF)),
                strokeWidth: 3,
              ).animate().fade(delay: 700.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== MAIN SCREEN WITH BOTTOM NAVIGATION ====================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> get _screens => [
    HomeContent(key: ValueKey('home_${StatsManager().stats.hashCode}')),
    StatsScreen(key: ValueKey('stats_${StatsManager().stats.hashCode}')),
    AchievementsScreen(
      key: ValueKey('achievements_${AchievementManager().unlockedCount}'),
    ),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A0B2E),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB100FF).withAlpha(30),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.bar_chart_rounded, 'Stats'),
                _buildNavItem(2, Icons.emoji_events_rounded, 'Awards'),
                _buildNavItem(3, Icons.settings_rounded, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFFB100FF) : Colors.white54;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        SoundService().playTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFB100FF).withAlpha(30)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HOME SCREEN ====================

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSavedGame();
    });
  }

  Future<void> _checkForSavedGame() async {
    final savedGame = await GameStateManager().loadGameState();
    if (savedGame != null && mounted) {
      _showResumeDialog(savedGame);
    }
  }

  void _showResumeDialog(Map<String, dynamic> savedGame) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Continue Game?',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You have an unfinished game. Would you like to continue?',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await GameStateManager().clearGameState();
            },
            child: Text(
              'Start New',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeGame(savedGame);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB100FF),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resumeGame(Map<String, dynamic> savedGame) async {
    if (savedGame['gameType'] == 'tic_tac_toe') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicTacToeScreen(
            difficulty: savedGame['difficulty'] ?? 'Hard',
            gridSize: savedGame['gridSize'] ?? 3,
            isMultiplayer: savedGame['isMultiplayer'] ?? false,
            savedGame: savedGame,
          ),
        ),
      );
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -0.6),
            radius: 1.5,
            colors: [Color(0xFF1A0B2E), Color(0xFF0A061E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFB100FF), Color(0xFF00FFFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Mind Sharpener',
                          style: GoogleFonts.outfit(
                            fontSize: math.min(
                              MediaQuery.of(context).size.width * 0.085,
                              30,
                            ),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStreakBadge(),
                        const SizedBox(height: 4),
                        Text(
                          'STREAK',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(150),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fade(duration: 600.ms).slideY(begin: -0.2, end: 0),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildQuickStatsBar(),
                        const SizedBox(height: 24),
                        GestureDetector(
                              onTap: () {
                                SoundService().playSelect();
                                _openLevelSelection();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00E5FF,
                                    ).withAlpha(100),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00E5FF,
                                      ).withAlpha(30),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: GlassContainer(
                                  width: double.infinity,
                                  useOwnLayer: true,
                                  padding: const EdgeInsets.all(20),
                                  shape: const LiquidRoundedSuperellipse(
                                    borderRadius: 24,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF00E5FF,
                                          ).withAlpha(25),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.grid_3x3_rounded,
                                          size: 40,
                                          color: Color(0xFF00E5FF),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Tic Tac Toe (Gomoku)',
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Can you beat the AI?',
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(
                                                  150,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.white.withAlpha(100),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fade(delay: 300.ms)
                            .scale(begin: const Offset(0.9, 0.9)),
                        const SizedBox(height: 24),
                        Text(
                          'BRAIN TRICKS',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withAlpha(150),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildTrickCard(
                                  title: 'Binary\nPrediction',
                                  icon: Icons.psychology_rounded,
                                  color: const Color(0xFF00FFFF),
                                  completed: false,
                                  onTap: () {
                                    SoundService().playSelect();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const BinaryTrickScreen(),
                                      ),
                                    );
                                  },
                                )
                                .animate()
                                .fade(delay: 400.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                            _buildTrickCard(
                                  title: 'Magic\nSquare',
                                  icon: Icons.auto_awesome_rounded,
                                  color: const Color(0xFFB100FF),
                                  completed: false,
                                  onTap: () {
                                    SoundService().playSelect();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MagicSquareScreen(),
                                      ),
                                    );
                                  },
                                )
                                .animate()
                                .fade(delay: 500.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                            _buildTrickCard(
                                  title: 'Always\n1089',
                                  icon: Icons.tag_rounded,
                                  color: const Color(0xFFFFE600),
                                  completed: false,
                                  onTap: () {
                                    SoundService().playSelect();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const Always1089Screen(),
                                      ),
                                    );
                                  },
                                )
                                .animate()
                                .fade(delay: 600.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                            _buildTrickCard(
                                  title: 'Missing\nCard',
                                  icon: Icons.casino_rounded,
                                  color: const Color(0xFFFF007F),
                                  completed: false,
                                  onTap: () {
                                    SoundService().playSelect();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MissingCardScreen(),
                                      ),
                                    );
                                  },
                                )
                                .animate()
                                .fade(delay: 700.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBadge() {
    final streak = StatsManager().stats['current_streak'] ?? 0;

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: streak > 0
                ? const LinearGradient(
                    colors: [Color(0xFFFF4500), Color(0xFFFFE600)],
                  )
                : null,
            color: streak == 0 ? Colors.white.withAlpha(15) : null,
            borderRadius: BorderRadius.circular(20),
            border: streak == 0
                ? Border.all(color: Colors.white.withAlpha(30))
                : null,
            boxShadow: streak > 0
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF4500).withAlpha(100),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                    Icons.local_fire_department,
                    color: streak > 0
                        ? Colors.white
                        : Colors.white.withAlpha(100),
                    size: 18,
                  )
                  .animate(
                    onPlay: (controller) =>
                        streak > 0 ? controller.repeat(reverse: true) : null,
                  )
                  .scaleXY(
                    begin: 1.0,
                    end: streak > 0 ? 1.3 : 1.0,
                    duration: 600.ms,
                    curve: Curves.easeInOut,
                  )
                  .shimmer(
                    duration: 1200.ms,
                    color: streak > 0
                        ? const Color(0xFFFFE600).withAlpha(120)
                        : Colors.transparent,
                  ),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: GoogleFonts.outfit(
                  color: streak > 0
                      ? Colors.white
                      : Colors.white.withAlpha(100),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fade(delay: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut);
  }

  Widget _buildQuickStatsBar() {
    final stats = StatsManager().stats;
    final wins = stats['tic_tac_wins'] ?? 0;
    final draws = stats['tic_tac_draws'] ?? 0;
    final losses = stats['tic_tac_losses'] ?? 0;
    final totalGames = stats['total_games'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickStatItem('Games', '$totalGames', Icons.games_rounded),
          Container(width: 1, height: 40, color: Colors.white.withAlpha(30)),
          _buildQuickStatItem('Wins', '$wins', Icons.emoji_events_rounded),
          Container(width: 1, height: 40, color: Colors.white.withAlpha(30)),
          _buildQuickStatItem('Draws', '$draws', Icons.handshake_rounded),
          Container(width: 1, height: 40, color: Colors.white.withAlpha(30)),
          _buildQuickStatItem('Losses', '$losses', Icons.close_rounded),
        ],
      ),
    ).animate().fade(delay: 250.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildQuickStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFB100FF), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTrickCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool completed = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withAlpha(120), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(40),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: GlassContainer(
          width: double.infinity,
          height: double.infinity,
          useOwnLayer: true,
          padding: const EdgeInsets.all(16),
          shape: const LiquidRoundedSuperellipse(borderRadius: 24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withAlpha(40), color.withAlpha(15)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.withAlpha(150),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(60),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 30, color: color),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .custom(
                        duration: 2000.ms,
                        builder: (context, value, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withAlpha(
                                    (30 + value * 30).toInt(),
                                  ),
                                  blurRadius: 8 + value * 8,
                                  spreadRadius: value * 2,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                      ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: color.withAlpha(150),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
              if (completed)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.withAlpha(150)),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLevelSelection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LevelSelectionScreen()),
    );
    if (mounted) setState(() {});
  }
}

// ==================== STATS SCREEN ====================

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Statistics',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.5, -0.5),
            radius: 1.5,
            colors: [Color(0xFF1A0B2E), Color(0xFF0A061E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildOverviewCard(),
                const SizedBox(height: 24),
                Text(
                  'TIC TAC TOE',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withAlpha(150),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTicTacStatsCard(),
                const SizedBox(height: 24),
                _buildShareButton(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    final stats = StatsManager().stats;
    final totalGames = stats['total_games'] ?? 0;
    final totalWins = stats['total_wins'] ?? 0;
    final winRate = totalGames > 0
        ? (totalWins / totalGames * 100).toStringAsFixed(1)
        : '0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB100FF), Color(0xFF00FFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB100FF).withAlpha(80),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'OVERALL STATS',
            style: GoogleFonts.outfit(
              color: Colors.white.withAlpha(200),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('$totalGames', 'Games\nPlayed'),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withAlpha(50),
              ),
              _buildStatColumn('$totalWins', 'Total\nWins'),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withAlpha(50),
              ),
              _buildStatColumn('$winRate%', 'Win\nRate'),
            ],
          ),
        ],
      ),
    ).animate().fade().slideY(begin: -0.1, end: 0);
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: Colors.white.withAlpha(200),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTicTacStatsCard() {
    final stats = StatsManager().stats;
    final wins = stats['tic_tac_wins'] ?? 0;
    final losses = stats['tic_tac_losses'] ?? 0;
    final draws = stats['tic_tac_draws'] ?? 0;
    final streak = stats['best_streak'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTicTacStatItem('Wins', wins, Colors.green)),
              Expanded(
                child: _buildTicTacStatItem('Losses', losses, Colors.red),
              ),
              Expanded(
                child: _buildTicTacStatItem('Draws', draws, Colors.amber),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4500).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF4500).withAlpha(50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFFF4500),
                ),
                const SizedBox(width: 8),
                Text(
                  'Best Streak: $streak',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFF4500),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTicTacStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$value',
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _shareStats(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0A061E),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(Icons.share),
        label: Text(
          'Share Stats',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
    ).animate().fade(delay: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  void _shareStats(BuildContext context) {
    final stats = StatsManager().stats;
    final message =
        '''
🎮 Mind Sharpener Stats

🎯 Tic Tac Toe:
• Wins: ${stats['tic_tac_wins']}
• Losses: ${stats['tic_tac_losses']}
• Draws: ${stats['tic_tac_draws']}
• Games Played: ${stats['total_games']}
• Best Streak: ${stats['best_streak']}

🏆 Achievements: ${AchievementManager().unlockedCount}/${_allAchievements.length}

Can you beat my score?
    ''';
    // ignore: deprecated_member_use
    Share.share(message);
  }
}

// ==================== ACHIEVEMENTS SCREEN ====================

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = AchievementManager().achievements;
    final unlockedCount = achievements.where((a) => a.unlocked).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Achievements',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, 0.5),
            radius: 1.5,
            colors: [Color(0xFF1A0B2E), Color(0xFF0A061E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProgressHeader(unlockedCount, achievements.length),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return _buildAchievementCard(achievement, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(int unlocked, int total) {
    final progress = total > 0 ? unlocked / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFD700),
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '$unlocked / $total',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withAlpha(20),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFD700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% Complete',
            style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 14),
          ),
        ],
      ),
    ).animate().fade().slideY(begin: -0.1, end: 0);
  }

  Widget _buildAchievementCard(Achievement achievement, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? achievement.color.withAlpha(20)
            : Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.unlocked
              ? achievement.color.withAlpha(100)
              : Colors.white.withAlpha(10),
          width: achievement.unlocked ? 2 : 1,
        ),
        boxShadow: achievement.unlocked
            ? [
                BoxShadow(
                  color: achievement.color.withAlpha(50),
                  blurRadius: 20,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? achievement.color.withAlpha(50)
                  : Colors.white.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.unlocked
                  ? achievement.color
                  : Colors.white.withAlpha(50),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: GoogleFonts.outfit(
                    color: achievement.unlocked
                        ? Colors.white
                        : Colors.white.withAlpha(100),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: Colors.white.withAlpha(
                      achievement.unlocked ? 180 : 80,
                    ),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (achievement.unlocked)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 20),
            )
          else
            Icon(Icons.lock_outline, color: Colors.white.withAlpha(50)),
        ],
      ),
    ).animate().fade(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }
}

// ==================== SETTINGS SCREEN ====================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.5, 0.5),
            radius: 1.5,
            colors: [Color(0xFF1A0B2E), Color(0xFF0A061E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'GENERAL',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withAlpha(150),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildSwitchTile(
                    'Sound Effects',
                    'Enable game sounds',
                    Icons.volume_up,
                    SoundService().soundEnabled,
                    (value) async {
                      await SoundService().setSoundEnabled(value);
                      setState(() {});
                    },
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  _buildSwitchTile(
                    'Haptic Feedback',
                    'Enable vibration feedback',
                    Icons.vibration,
                    SoundService().hapticsEnabled,
                    (value) async {
                      await SoundService().setHapticsEnabled(value);
                      setState(() {});
                    },
                  ),
                ]),
                const SizedBox(height: 24),
                Text(
                  'DATA',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withAlpha(150),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildActionTile(
                    'Reset Statistics',
                    'Clear all game progress',
                    Icons.delete_outline,
                    Colors.red,
                    () => _showResetStatsDialog(),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  _buildActionTile(
                    'Reset Achievements',
                    'Unlock all achievements again',
                    Icons.emoji_events_outlined,
                    Colors.orange,
                    () => _showResetAchievementsDialog(),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  _buildActionTile(
                    'Clear Saved Game',
                    'Remove unfinished game',
                    Icons.gamepad_outlined,
                    Colors.blue,
                    () => _clearSavedGame(),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSettingsCard([
                  _buildInfoTile('Version', '1.0.0', Icons.info_outline),
                  const Divider(color: Colors.white12, height: 1),
                  _buildInfoTile(
                    'Developer',
                    'Mind Sharpener Team',
                    Icons.code,
                  ),
                ]),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(children: children),
    ).animate().fade().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF00E5FF),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFB100FF).withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFB100FF), size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.white.withAlpha(50)),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white54, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(value, style: GoogleFonts.outfit(color: Colors.white54)),
    );
  }

  void _showResetStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Statistics?',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will permanently delete all your game statistics. This action cannot be undone.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await StatsManager().resetStats();
              if (!context.mounted) return;
              Navigator.pop(context);
              _showSuccessSnackbar('Statistics reset successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Reset',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetAchievementsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Achievements?',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will reset all your achievements. You\'ll need to unlock them again.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await AchievementManager().resetAchievements();
              if (!context.mounted) return;
              Navigator.pop(context);
              setState(() {});
              _showSuccessSnackbar('Achievements reset successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(
              'Reset',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearSavedGame() async {
    await GameStateManager().clearGameState();
    _showSuccessSnackbar('Saved game cleared');
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFB100FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ==================== LEVEL SELECTION ====================

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _timedMode = false;
  int _timerDuration = 180; // Default 3 minutes
  final List<int> _gridSizes = [3, 5, 7, 10];

  String _getGridName(int size) {
    if (size == 3) return 'Classic 3x3';
    if (size == 5) return 'Medium 5x5';
    if (size == 7) return 'Large 7x7';
    return 'Gomoku 10x10';
  }

  int _getWinTarget(int size) {
    if (size == 3) return 3;
    if (size == 5 || size == 7) return 4;
    return 5;
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    if (min > 0 && sec > 0) return '${min}m ${sec}s';
    if (min > 0) return '$min min';
    return '${sec}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFB100FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SELECT LEVEL',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.5,
            colors: [Color(0xFF1A0B2E), Color(0xFF0A061E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Timed Mode Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: () {
                      SoundService().playTap();
                      setState(() {
                        _timedMode = !_timedMode;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: _timedMode
                            ? const LinearGradient(
                                colors: [Color(0xFFB100FF), Color(0xFF00FFFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: _timedMode ? null : Colors.white.withAlpha(10),
                        border: Border.all(
                          color: _timedMode
                              ? Colors.transparent
                              : Colors.white.withAlpha(40),
                          width: 1.5,
                        ),
                        boxShadow: _timedMode
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFB100FF).withAlpha(60),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            color: _timedMode
                                ? Colors.white
                                : Colors.white.withAlpha(120),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Timed Mode',
                                  style: GoogleFonts.outfit(
                                    color: _timedMode
                                        ? Colors.white
                                        : Colors.white.withAlpha(180),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${_formatDuration(_timerDuration)} to win',
                                  style: TextStyle(
                                    color: _timedMode
                                        ? Colors.white.withAlpha(200)
                                        : Colors.white.withAlpha(80),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 44,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: _timedMode
                                  ? Colors.white.withAlpha(40)
                                  : Colors.white.withAlpha(15),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              alignment: _timedMode
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _timedMode
                                      ? Colors.white
                                      : Colors.white.withAlpha(100),
                                  boxShadow: _timedMode
                                      ? [
                                          BoxShadow(
                                            color: Colors.white.withAlpha(80),
                                            blurRadius: 6,
                                          ),
                                        ]
                                      : [],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fade(delay: 100.ms).slideY(begin: -0.3),
                // Custom Timer Duration Control (visible when timed mode is on)
                if (_timedMode) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Timer Duration',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB100FF).withAlpha(40),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFB100FF,
                                    ).withAlpha(100),
                                  ),
                                ),
                                child: Text(
                                  _formatDuration(_timerDuration),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFFB100FF),
                              inactiveTrackColor: Colors.white.withAlpha(20),
                              thumbColor: Colors.white,
                              overlayColor: const Color(
                                0xFFB100FF,
                              ).withAlpha(40),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                            ),
                            child: Slider(
                              value: _timerDuration.toDouble(),
                              min: 30,
                              max: 600,
                              divisions: 19,
                              onChanged: (value) {
                                setState(() {
                                  _timerDuration = value.toInt();
                                });
                                SoundService().playTap();
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTimerPreset(60, '1m'),
                              _buildTimerPreset(180, '3m'),
                              _buildTimerPreset(300, '5m'),
                              _buildTimerPreset(600, '10m'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 150.ms).slideY(begin: -0.2),
                ],
                const SizedBox(height: 16),
                // Win Condition Illustration
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildWinConditionIllustration(),
                ).animate().fade(delay: 200.ms).slideY(begin: -0.1),
                const SizedBox(height: 24),
                SizedBox(
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (int page) {
                              setState(() {
                                _currentPage = page;
                              });
                            },
                            itemCount: _gridSizes.length,
                            itemBuilder: (context, index) {
                              bool isActive = index == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: isActive ? 0 : 30,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00E5FF,
                                    ).withAlpha(isActive ? 255 : 50),
                                    width: isActive ? 3 : 1,
                                  ),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF00E5FF,
                                            ).withAlpha(80),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: CustomPaint(
                                        size: const Size(200, 200),
                                        painter: MiniGridPainter(
                                          _gridSizes[index],
                                        ),
                                      ),
                                    ),
                                    if (isActive)
                                      Positioned(
                                        top: 10,
                                        left: 0,
                                        right: 0,
                                        child: Text(
                                          _getGridName(_gridSizes[index]),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white.withAlpha(150),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Positioned(
                            left: 10,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xFFFFE600),
                                size: 30,
                              ),
                              onPressed: () {
                                if (_currentPage > 0) {
                                  _pageController.previousPage(
                                    duration: 300.ms,
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                          Positioned(
                            right: 10,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFFFFE600),
                                size: 30,
                              ),
                              onPressed: () {
                                if (_currentPage < _gridSizes.length - 1) {
                                  _pageController.nextPage(
                                    duration: 300.ms,
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fade(delay: 200.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_gridSizes.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 12 : 8,
                      height: _currentPage == index ? 12 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withAlpha(100),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                _buildNeonButton(
                  icon: Icons.person_outline,
                  icon2: Icons.computer,
                  text: 'vs',
                  color: const Color(0xFF00E5FF),
                  onTap: _timedMode
                      ? () => _startTimedGame()
                      : _showDifficultyDialog,
                ).animate().fade(delay: 400.ms).slideY(begin: 0.5),
                const SizedBox(height: 16),
                _buildNeonButton(
                  icon: Icons.person_outline,
                  icon2: Icons.person_outline,
                  text: 'vs',
                  color: const Color(0xFFFFE600),
                  onTap: () {
                    SoundService().playSelect();
                    if (_timedMode) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TimedChallengeScreen(
                            difficulty: 'Hard',
                            gridSize: _gridSizes[_currentPage],
                            timerDuration: _timerDuration,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicTacToeScreen(
                            difficulty: 'Hard',
                            gridSize: _gridSizes[_currentPage],
                            isMultiplayer: true,
                          ),
                        ),
                      );
                    }
                  },
                ).animate().fade(delay: 500.ms).slideY(begin: 0.5),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeonButton({
    required IconData icon,
    required IconData icon2,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        SoundService().playTap();
        onTap();
      },
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(50),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Text(
              text,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon2, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerPreset(int seconds, String label) {
    final isSelected = _timerDuration == seconds;
    return GestureDetector(
      onTap: () {
        setState(() => _timerDuration = seconds);
        SoundService().playTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFB100FF).withAlpha(50)
              : Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB100FF)
                : Colors.white.withAlpha(30),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.white.withAlpha(120),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildWinConditionIllustration() {
    final gridSize = _gridSizes[_currentPage];
    final winTarget = _getWinTarget(gridSize);
    final miniSize = winTarget.clamp(3, 5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withAlpha(40)),
      ),
      child: Row(
        children: [
          // Mini grid illustration with winning line highlighted
          SizedBox(
            width: 70,
            height: 70,
            child: CustomPaint(
              painter: _WinConditionPainter(miniSize, winTarget),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect $winTarget in a row',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gridSize == 3
                      ? 'Classic rules — align 3 to win'
                      : gridSize == 10
                      ? 'Gomoku style — align 5 to win'
                      : 'Align $winTarget pieces horizontally, vertically, or diagonally',
                  style: TextStyle(
                    color: Colors.white.withAlpha(120),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          // Win target badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFFB100FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withAlpha(60),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$winTarget',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startTimedGame() {
    SoundService().playSelect();
    _showTimedDifficultyDialog();
  }

  void _showTimedDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.timer_rounded, color: Color(0xFFFFE600), size: 24),
            const SizedBox(width: 8),
            Text(
              'Timed Difficulty',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_formatDuration(_timerDuration)} to win!',
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildTimedDiffButton('Hard', const Color(0xFFFF1744)),
            const SizedBox(height: 12),
            _buildTimedDiffButton('Medium', const Color(0xFFFFD600)),
            const SizedBox(height: 12),
            _buildTimedDiffButton('Easy', const Color(0xFF4CAF50)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimedDiffButton(String diff, Color color) {
    return InkWell(
      onTap: () {
        SoundService().playSelect();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TimedChallengeScreen(
              difficulty: diff,
              gridSize: _gridSizes[_currentPage],
              timerDuration: _timerDuration,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          border: Border.all(color: color.withAlpha(100)),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              diff,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Difficulty',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDiffButton('Hard', const Color(0xFFFF1744)),
            const SizedBox(height: 12),
            _buildDiffButton('Medium', const Color(0xFFFFD600)),
            const SizedBox(height: 12),
            _buildDiffButton('Easy', const Color(0xFF4CAF50)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiffButton(String diff, Color color) {
    return InkWell(
      onTap: () {
        SoundService().playSelect();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicTacToeScreen(
              difficulty: diff,
              gridSize: _gridSizes[_currentPage],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          border: Border.all(color: color.withAlpha(100)),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          diff,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ==================== TIMED CHALLENGE SCREEN ====================

class TimedChallengeScreen extends StatefulWidget {
  final String difficulty;
  final int gridSize;
  final int timerDuration;

  const TimedChallengeScreen({
    super.key,
    required this.difficulty,
    required this.gridSize,
    this.timerDuration = 180,
  });

  @override
  State<TimedChallengeScreen> createState() => _TimedChallengeScreenState();
}

class _TimedChallengeScreenState extends State<TimedChallengeScreen> {
  late int gridSize;
  late List<int> board;
  bool isPlayerTurn = true;
  bool isGameOver = false;
  late int _timeRemaining;
  int moves = 0;
  Timer? _timer;
  String gameResult = '';

  @override
  void initState() {
    super.initState();
    gridSize = widget.gridSize;
    _timeRemaining = widget.timerDuration;
    board = List.filled(gridSize * gridSize, 0);
    _startTimer();
    SoundService().playStart();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0 && !isGameOver) {
        setState(() {
          _timeRemaining--;
        });
      } else if (_timeRemaining <= 0 && !isGameOver) {
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    setState(() {
      isGameOver = true;
      gameResult = 'Time\'s Up!';
    });
    _timer?.cancel();
    SoundService().playError();
    _showTimeUpDialog();
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Time\'s Up!',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_off, size: 60, color: Color(0xFFFF007F)),
            const SizedBox(height: 16),
            Text(
              'You made $moves moves!',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Exit',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB100FF),
            ),
            child: Text(
              'Play Again',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      board = List.filled(gridSize * gridSize, 0);
      isGameOver = false;
      _timeRemaining = widget.timerDuration;
      moves = 0;
      isPlayerTurn = true;
      gameResult = '';
    });
    _startTimer();
  }

  int get winTarget {
    if (gridSize == 3) return 3;
    if (gridSize == 5 || gridSize == 7) return 4;
    return 5;
  }

  void _handleTap(int index) {
    if (isGameOver || board[index] != 0) return;

    setState(() {
      board[index] = 1;
      moves++;
    });
    SoundService().playTap();

    if (_checkWin(1)) {
      _endGame('Player Wins!', true);
    } else if (!board.contains(0)) {
      _endGame('Draw!', false);
    } else {
      setState(() {
        isPlayerTurn = false;
      });
      Future.delayed(const Duration(milliseconds: 300), _makeCpuMove);
    }
  }

  void _makeCpuMove() {
    if (isGameOver) return;
    int move = -1;

    if (widget.difficulty == 'Easy') {
      move = _getRandomMove();
    } else {
      move = _getHeuristicMove();
    }

    if (move != -1) {
      setState(() {
        board[move] = 2;
        isPlayerTurn = true;
      });
      SoundService().playTap();

      if (_checkWin(2)) {
        _endGame('CPU Wins!', false);
      } else if (!board.contains(0)) {
        _endGame('Draw!', false);
      }
    }
  }

  int _getRandomMove() {
    final emptySpots = [
      for (int i = 0; i < board.length; i++)
        if (board[i] == 0) i,
    ];
    if (emptySpots.isEmpty) return -1;
    return emptySpots[math.Random().nextInt(emptySpots.length)];
  }

  int _getHeuristicMove() {
    int bestScore = -1;
    int bestMove = -1;
    final emptySpots = [
      for (int i = 0; i < board.length; i++)
        if (board[i] == 0) i,
    ];

    for (int i in emptySpots) {
      int score = _evaluateCellForMove(i, 2) + _evaluateCellForMove(i, 1);
      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }

    if (bestMove == -1) return _getRandomMove();
    return bestMove;
  }

  int _evaluateCellForMove(int index, int player) {
    int r = index ~/ gridSize;
    int c = index % gridSize;
    int totalScore = 0;

    totalScore += _countLine(r, c, 1, 0, player);
    totalScore += _countLine(r, c, 0, 1, player);
    totalScore += _countLine(r, c, 1, 1, player);
    totalScore += _countLine(r, c, 1, -1, player);

    return totalScore;
  }

  int _countLine(int r, int c, int dr, int dc, int player) {
    int count = 1;
    int openEnds = 0;

    for (int i = 1; i < winTarget; i++) {
      int nr = r + dr * i;
      int nc = c + dc * i;
      if (nr < 0 || nr >= gridSize || nc < 0 || nc >= gridSize) break;
      if (board[nr * gridSize + nc] == player) {
        count++;
      } else if (board[nr * gridSize + nc] == 0) {
        openEnds++;
        break;
      } else {
        break;
      }
    }

    for (int i = 1; i < winTarget; i++) {
      int nr = r - dr * i;
      int nc = c - dc * i;
      if (nr < 0 || nr >= gridSize || nc < 0 || nc >= gridSize) break;
      if (board[nr * gridSize + nc] == player) {
        count++;
      } else if (board[nr * gridSize + nc] == 0) {
        openEnds++;
        break;
      } else {
        break;
      }
    }

    if (count >= winTarget) return 100000;
    if (count == 4 && openEnds > 0) return 10000;
    if (count == 3 && openEnds == 2) return 5000;
    if (count == 3 && openEnds == 1) return 100;
    if (count == 2 && openEnds == 2) return 50;
    return count;
  }

  bool _checkWin(int player) {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (board[r * gridSize + c] == player) {
          if (_checkDirection(r, c, 1, 0, player) ||
              _checkDirection(r, c, 0, 1, player) ||
              _checkDirection(r, c, 1, 1, player) ||
              _checkDirection(r, c, 1, -1, player)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _checkDirection(int r, int c, int dr, int dc, int player) {
    for (int i = 0; i < winTarget; i++) {
      int nr = r + dr * i;
      int nc = c + dc * i;
      if (nr < 0 || nr >= gridSize || nc < 0 || nc >= gridSize) return false;
      if (board[nr * gridSize + nc] != player) return false;
    }
    return true;
  }

  Future<void> _endGame(String result, bool playerWon) async {
    setState(() {
      isGameOver = true;
      gameResult = result;
    });
    _timer?.cancel();

    if (playerWon) {
      SoundService().playWin();
      await StatsManager().recordTicTacWin();
    } else {
      if (result == 'Draw!') {
        await StatsManager().recordTicTacDraw();
      } else {
        await StatsManager().recordTicTacLoss();
        SoundService().playLose();
      }
    }

    await AchievementManager().checkAndUnlockAchievements(
      difficulty: widget.difficulty,
      gridSize: gridSize,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFB100FF)),
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0),
            radius: 1.5,
            colors: [Color(0xFF1A0B2E), Color(0xFF0A061E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildTimerDisplay(),
              const SizedBox(height: 10),
              _buildMovesCounter(),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00E5FF),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withAlpha(50),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size.infinite,
                            painter: GridLinesPainter(gridSize),
                          ),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: gridSize,
                                ),
                            itemCount: gridSize * gridSize,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _handleTap(index),
                                child: Container(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: board[index] == 0
                                        ? null
                                        : board[index] == 1
                                        ? Container(
                                            width:
                                                (MediaQuery.of(
                                                      context,
                                                    ).size.width -
                                                    48) /
                                                gridSize *
                                                0.6,
                                            height:
                                                (MediaQuery.of(
                                                      context,
                                                    ).size.width -
                                                    48) /
                                                gridSize *
                                                0.6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xFF00E5FF),
                                                width: gridSize == 3 ? 6 : 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF00E5FF,
                                                  ).withAlpha(100),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ).animate().scale(
                                            duration: 200.ms,
                                            curve: Curves.easeOutBack,
                                          )
                                        : SizedBox(
                                            width:
                                                (MediaQuery.of(
                                                      context,
                                                    ).size.width -
                                                    48) /
                                                gridSize *
                                                0.6,
                                            height:
                                                (MediaQuery.of(
                                                      context,
                                                    ).size.width -
                                                    48) /
                                                gridSize *
                                                0.6,
                                            child: CustomPaint(
                                              painter: XPainter(
                                                const Color(0xFFFF007F),
                                                strokeWidth: gridSize == 3
                                                    ? 6
                                                    : 3,
                                              ),
                                            ),
                                          ).animate().scale(
                                            duration: 200.ms,
                                            curve: Curves.easeOutBack,
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isGameOver)
                Column(
                  children: [
                    Text(
                      gameResult,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          const Shadow(color: Colors.white, blurRadius: 10),
                        ],
                      ),
                    ).animate().scale(curve: Curves.elasticOut),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _restartGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0A061E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'PLAY AGAIN',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().fade(delay: 500.ms).slideY(),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    final isLowTime = _timeRemaining <= 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isLowTime
            ? Colors.red.withAlpha(30)
            : const Color(0xFF00E5FF).withAlpha(30),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isLowTime ? Colors.red : const Color(0xFF00E5FF),
          width: 2,
        ),
        boxShadow: isLowTime
            ? [BoxShadow(color: Colors.red.withAlpha(100), blurRadius: 20)]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: isLowTime ? Colors.red : const Color(0xFF00E5FF),
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            '${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isLowTime ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
    ).animate(target: isLowTime ? 1 : 0).shake(duration: 500.ms);
  }

  Widget _buildMovesCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.touch_app, color: Color(0xFFB100FF), size: 20),
          const SizedBox(width: 8),
          Text(
            'Moves: $moves',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== GAME SCREENS ====================

class BinaryTrickScreen extends StatefulWidget {
  const BinaryTrickScreen({super.key});

  @override
  State<BinaryTrickScreen> createState() => _BinaryTrickScreenState();
}

class _BinaryTrickScreenState extends State<BinaryTrickScreen> {
  int _currentStep = 0;
  int _guessedNumber = 0;

  final List<List<int>> _cards = [
    List.generate(32, (i) => i * 2 + 1),
    List.generate(32, (i) => ((i ~/ 2) * 4) + (i % 2) + 2),
    List.generate(32, (i) => ((i ~/ 4) * 8) + (i % 4) + 4),
    List.generate(32, (i) => ((i ~/ 8) * 16) + (i % 8) + 8),
    List.generate(32, (i) => ((i ~/ 16) * 32) + (i % 16) + 16),
    List.generate(32, (i) => i + 32),
  ];

  Future<void> _answer(bool isYes) async {
    if (isYes) {
      _guessedNumber += (1 << _currentStep);
    }

    setState(() {
      _currentStep++;
    });
    SoundService().playTap();

    if (_currentStep >= 6) {
      await StatsManager().recordGamePlayed();
      await AchievementManager().checkAndUnlockAchievements();
    }
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _guessedNumber = 0;
    });
    SoundService().playSelect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Binary Prediction',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.5),
            radius: 1.5,
            colors: [Color(0xFF201736), Color(0xFF0A061E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: AnimatedSwitcher(
              duration: 400.ms,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _currentStep < 6 ? _buildQuestionKey() : _buildResultKey(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionKey() {
    return Column(
      key: ValueKey<int>(_currentStep),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Step ${_currentStep + 1} / 6',
                style: TextStyle(
                  color: const Color(0xFF00FFFF).withAlpha(200),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search for your number',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ).animate().fade().slideY(begin: -0.2),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00FFFF).withAlpha(50)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 32,
            itemBuilder: (context, index) {
              return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withAlpha(25)),
                    ),
                    child: Center(
                      child: Text(
                        '${_cards[_currentStep][index]}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fade(delay: (index * 5).ms)
                  .scale(delay: (index * 5).ms, begin: const Offset(0.8, 0.8));
            },
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Just keep one digit in your mind.\nIs it in the box above? Select YES or NO.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 16,
              height: 1.5,
            ),
          ).animate().fade(delay: 200.ms),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Expanded(
                child: _buildButton(
                  title: 'NO',
                  color: const Color(0xFFFF007F),
                  onTap: () => _answer(false),
                ).animate().fade(delay: 300.ms).slideX(begin: -0.2),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildButton(
                  title: 'YES',
                  color: const Color(0xFF00FFFF),
                  onTap: () => _answer(true),
                ).animate().fade(delay: 300.ms).slideX(begin: 0.2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        SoundService().playSelect();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(100)),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildResultKey() {
    return Center(
      key: const ValueKey('result'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'YOUR NUMBER IS',
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 16,
              letterSpacing: 4,
            ),
          ).animate().fade(delay: 300.ms),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00FFFF).withAlpha(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withAlpha(50),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Text(
              '$_guessedNumber',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate().scale(
            delay: 500.ms,
            duration: 600.ms,
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: _reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0A061E),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'PLAY AGAIN',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ).animate().fade(delay: 1000.ms).slideY(begin: 0.5),
        ],
      ),
    );
  }
}

class MagicSquareScreen extends StatefulWidget {
  const MagicSquareScreen({super.key});

  @override
  State<MagicSquareScreen> createState() => _MagicSquareScreenState();
}

class _MagicSquareScreenState extends State<MagicSquareScreen> {
  final List<int> _grid = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
  ];

  final Set<int> _eliminatedRows = {};
  final Set<int> _eliminatedCols = {};
  final List<int> _selectedNumbers = [];

  Future<void> _selectNumber(int index) async {
    int row = index ~/ 4;
    int col = index % 4;

    if (_eliminatedRows.contains(row) || _eliminatedCols.contains(col)) {
      return;
    }

    setState(() {
      _selectedNumbers.add(_grid[index]);
      _eliminatedRows.add(row);
      _eliminatedCols.add(col);
    });
    SoundService().playTap();

    if (_selectedNumbers.length == 4) {
      await StatsManager().recordGamePlayed();
      await AchievementManager().checkAndUnlockAchievements();
    }
  }

  void _reset() {
    setState(() {
      _selectedNumbers.clear();
      _eliminatedRows.clear();
      _eliminatedCols.clear();
    });
    SoundService().playSelect();
  }

  @override
  Widget build(BuildContext context) {
    bool isFinished = _selectedNumbers.length == 4;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Magic Square',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.5, -0.5),
            radius: 1.5,
            colors: [Color(0xFF321245), Color(0xFF0A061E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Text(
                        'INSTRUCTIONS',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFB100FF),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Choose any number from the grid.\n'
                        '2. Its row and column will be eliminated.\n'
                        '3. Repeat until you select 4 numbers.\n'
                        '4. Watch the magic sum appear!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 15,
                          height: 1.6,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ).animate().fade().slideY(begin: -0.2),
                ),
                const SizedBox(height: 20),
                if (isFinished)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'THE MAGIC REVEALED',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFB100FF),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ).animate().shimmer(duration: 1200.ms),
                  ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        int row = index ~/ 4;
                        int col = index % 4;
                        bool isEliminated =
                            _eliminatedRows.contains(row) ||
                            _eliminatedCols.contains(col);
                        bool isSelected = _selectedNumbers.contains(
                          _grid[index],
                        );

                        return GestureDetector(
                              onTap: () => _selectNumber(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFB100FF).withAlpha(80)
                                      : isEliminated
                                      ? Colors.transparent
                                      : Colors.white.withAlpha(15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFB100FF)
                                        : isEliminated
                                        ? Colors.white.withAlpha(10)
                                        : Colors.white.withAlpha(30),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFB100FF,
                                            ).withAlpha(100),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    '${_grid[index]}',
                                    style: GoogleFonts.outfit(
                                      color: isEliminated && !isSelected
                                          ? Colors.white.withAlpha(40)
                                          : Colors.white,
                                      fontSize: 26,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fade(delay: (index * 20).ms)
                            .scale(
                              delay: (index * 20).ms,
                              begin: const Offset(0.8, 0.8),
                            );
                      },
                    ),
                  ),
                ),
                if (isFinished) ...[
                  Column(
                    children: [
                      Text(
                        'YOUR MAGIC SUM',
                        style: TextStyle(
                          color: Colors.white.withAlpha(150),
                          fontSize: 14,
                          letterSpacing: 4,
                        ),
                      ).animate().fade(delay: 300.ms),
                      const SizedBox(height: 10),
                      Text(
                        '${_selectedNumbers.fold(0, (a, b) => a + b)}',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFB100FF),
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().scale(
                        delay: 500.ms,
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _reset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0A061E),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'PLAY AGAIN',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ).animate().fade(delay: 1000.ms).slideY(begin: 0.5),
                      const SizedBox(height: 40),
                    ],
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 4; i++)
                          Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i < _selectedNumbers.length
                                      ? const Color(0xFFB100FF).withAlpha(50)
                                      : Colors.white.withAlpha(10),
                                  border: Border.all(
                                    color: i < _selectedNumbers.length
                                        ? const Color(0xFFB100FF)
                                        : Colors.white.withAlpha(20),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    i < _selectedNumbers.length
                                        ? '${_selectedNumbers[i]}'
                                        : '',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              .animate(
                                target: i < _selectedNumbers.length ? 1 : 0,
                              )
                              .scale(duration: 200.ms),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Always1089Screen extends StatefulWidget {
  const Always1089Screen({super.key});

  @override
  State<Always1089Screen> createState() => _Always1089ScreenState();
}

class _Always1089ScreenState extends State<Always1089Screen> {
  int _step = 0;

  final List<String> _steps = [
    "Think of a 3-digit number where the first and last digits are different (e.g., 732).",
    "Reverse that number (e.g., 237).",
    "Subtract the smaller number from the larger number (732 - 237 = 495).",
    "Reverse the new result (e.g., 594).",
    "Add the two new numbers together (495 + 594).",
    "Your final answer is...",
  ];

  Future<void> _nextStep() async {
    if (_step < _steps.length) {
      setState(() {
        _step++;
      });
      SoundService().playTap();

      if (_step >= _steps.length) {
        await StatsManager().recordGamePlayed();
        await AchievementManager().checkAndUnlockAchievements();
      }
    }
  }

  void _reset() {
    setState(() {
      _step = 0;
    });
    SoundService().playSelect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Always 1089',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, 0.5),
            radius: 1.5,
            colors: [Color(0xFF383015), Color(0xFF0A061E)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_step < _steps.length) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_steps.length, (index) {
                              return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: _step == index ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _step >= index
                                          ? const Color(0xFFFFE600)
                                          : Colors.white.withAlpha(50),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  )
                                  .animate(target: _step == index ? 1 : 0)
                                  .effect(duration: 300.ms);
                            }),
                          ).animate().fade().slideY(begin: -0.5),
                          const SizedBox(height: 60),
                        ],
                        AnimatedSwitcher(
                          duration: 500.ms,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.1),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                          child: _step < _steps.length
                              ? _buildStepContent()
                              : _buildResultContent(),
                        ),
                        const SizedBox(height: 40),
                        if (_step < _steps.length) ...[
                          ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0A061E),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _step == _steps.length - 1
                                  ? 'REVEAL ANSWER'
                                  : 'NEXT STEP',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ).animate().fade(delay: 500.ms).slideY(begin: 0.2),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    return Column(
      key: ValueKey<int>(_step),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'STEP ${_step + 1}',
          style: TextStyle(
            color: const Color(0xFFFFE600).withAlpha(200),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: Text(
            _steps[_step],
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent() {
    return Column(
      key: const ValueKey('result'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Text(
          'YOUR RESULT IS',
          style: TextStyle(
            color: Colors.white.withAlpha(150),
            fontSize: 16,
            letterSpacing: 4,
          ),
        ).animate().fade(delay: 300.ms),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFE600).withAlpha(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFE600).withAlpha(50),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
          ),
          child: Text(
            '1089',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 100,
              fontWeight: FontWeight.w800,
            ),
          ),
        ).animate().scale(
          delay: 500.ms,
          duration: 800.ms,
          curve: Curves.elasticOut,
        ),
        const SizedBox(height: 60),
        ElevatedButton(
          onPressed: _reset,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0A061E),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'PLAY AGAIN',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ).animate().fade(delay: 1200.ms).slideY(begin: 0.5),
        const SizedBox(height: 60),
      ],
    );
  }
}

class MissingCardScreen extends StatefulWidget {
  const MissingCardScreen({super.key});

  @override
  State<MissingCardScreen> createState() => _MissingCardScreenState();
}

class _MissingCardScreenState extends State<MissingCardScreen> {
  bool _isRevealed = false;

  final List<String> _initialCards = ['K♠', 'Q♥', 'J♣', 'K♦', 'Q♣', 'J♠'];
  final List<String> _finalCards = ['K♣', 'Q♠', 'J♥', 'K♥', 'Q♦'];

  Color _getCardColor(String card) {
    if (card.contains('♥') || card.contains('♦')) {
      return const Color(0xFFE53935);
    }
    return const Color(0xFF1E1E1E);
  }

  String _getRank(String card) {
    return card.substring(0, card.length - 1);
  }

  String _getSuit(String card) {
    return card.substring(card.length - 1);
  }

  Widget _buildCard(String card) {
    final color = _getCardColor(card);
    final rank = _getRank(card);
    final suit = _getSuit(card);

    return Container(
      width: 90,
      height: 140,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 8,
            child: Column(
              children: [
                Text(
                  rank,
                  style: GoogleFonts.merriweather(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1,
                  ),
                ),
                Text(
                  suit,
                  style: TextStyle(fontSize: 14, color: color, height: 1),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 6,
            right: 8,
            child: Transform.rotate(
              angle: 3.14159,
              child: Column(
                children: [
                  Text(
                    rank,
                    style: GoogleFonts.merriweather(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                      height: 1,
                    ),
                  ),
                  Text(
                    suit,
                    style: TextStyle(fontSize: 14, color: color, height: 1),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rank,
                  style: GoogleFonts.merriweather(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  suit,
                  style: TextStyle(fontSize: 36, color: color, height: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Missing Card',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.5, 0.5),
            radius: 1.5,
            colors: [Color(0xFF4A1525), Color(0xFF0A061E)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 16.0,
                        ),
                        child: AnimatedSwitcher(
                          duration: 400.ms,
                          child: Text(
                            _isRevealed
                                ? 'Look closely. YOUR card is gone!'
                                : 'Memorize ONE card. Do not tap it, just keep it in your mind.',
                            key: ValueKey<bool>(_isRevealed),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ).animate().fade().slideY(begin: -0.2),

                      const SizedBox(height: 50),

                      AnimatedSwitcher(
                        duration: 800.ms,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              final rotateAnim = Tween(
                                begin: 3.14159,
                                end: 0.0,
                              ).animate(animation);
                              return AnimatedBuilder(
                                animation: rotateAnim,
                                child: child,
                                builder: (context, child) {
                                  final isUnder =
                                      (ValueKey(_isRevealed) != child!.key);
                                  var tilt =
                                      ((animation.value - 0.5).abs() - 0.5) *
                                      0.003;
                                  tilt *= isUnder ? -1.0 : 1.0;
                                  final value = isUnder
                                      ? math.min(rotateAnim.value, 1.5708)
                                      : rotateAnim.value;
                                  return Transform(
                                    transform: Matrix4.rotationY(value)
                                      ..setEntry(3, 0, tilt),
                                    alignment: Alignment.center,
                                    child: child,
                                  );
                                },
                              );
                            },
                        child: Wrap(
                          key: ValueKey<bool>(_isRevealed),
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          runSpacing: 16,
                          children: (_isRevealed ? _finalCards : _initialCards)
                              .asMap()
                              .entries
                              .map((entry) {
                                return _buildCard(entry.value)
                                    .animate()
                                    .fade(delay: (entry.key * 100).ms)
                                    .slideY(begin: 0.2);
                              })
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 60),

                      ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isRevealed = !_isRevealed;
                              });
                              SoundService().playSelect();

                              if (_isRevealed) {
                                await StatsManager().recordGamePlayed();
                                await AchievementManager()
                                    .checkAndUnlockAchievements();
                                SoundService().playWin();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0A061E),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              minimumSize: const Size(280, 60),
                            ),
                            child: Text(
                              _isRevealed
                                  ? 'PLAY AGAIN'
                                  : 'I MEMORIZED MY CARD',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          )
                          .animate()
                          .fade(delay: 600.ms)
                          .scale(begin: const Offset(0.9, 0.9)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==================== TIC TAC TOE SCREEN ====================

class TicTacToeScreen extends StatefulWidget {
  final String difficulty;
  final int gridSize;
  final bool isMultiplayer;
  final Map<String, dynamic>? savedGame;

  const TicTacToeScreen({
    super.key,
    required this.difficulty,
    required this.gridSize,
    this.isMultiplayer = false,
    this.savedGame,
  });

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  late int gridSize;
  late List<int> board;
  bool isPlayerTurn = true;
  bool isGameOver = false;
  String winner = "";
  List<int> winningLine = [];
  bool _gameSaved = false;

  @override
  void initState() {
    super.initState();
    gridSize = widget.gridSize;

    if (widget.savedGame != null) {
      board = List<int>.from(widget.savedGame!['board']);
      isPlayerTurn = widget.savedGame!['isPlayerTurn'];
    } else {
      board = List.filled(gridSize * gridSize, 0);
    }

    SoundService().playStart();
  }

  int get winTarget {
    if (gridSize == 3) return 3;
    if (gridSize == 5 || gridSize == 7) return 4;
    return 5;
  }

  void _handleTap(int index) {
    if (isGameOver || board[index] != 0) return;
    if (!widget.isMultiplayer && !isPlayerTurn) return;

    setState(() {
      board[index] = widget.isMultiplayer ? (isPlayerTurn ? 1 : 2) : 1;
    });
    SoundService().playTap();

    int currentPlayer = widget.isMultiplayer ? (isPlayerTurn ? 1 : 2) : 1;

    if (_checkWin(currentPlayer)) {
      if (widget.isMultiplayer) {
        _endGame(isPlayerTurn ? "Player 1 Wins!" : "Player 2 Wins!", true);
      } else {
        _endGame("Player Wins!", true);
      }
    } else if (!board.contains(0)) {
      _endGame("Draw!", false);
    } else {
      setState(() {
        isPlayerTurn = !isPlayerTurn;
      });
      _saveGame();
      if (!widget.isMultiplayer) {
        Future.delayed(const Duration(milliseconds: 500), _makeCpuMove);
      }
    }
  }

  void _saveGame() async {
    if (!_gameSaved && !isGameOver) {
      await GameStateManager().saveGameState(
        gameType: 'tic_tac_toe',
        board: board,
        isPlayerTurn: isPlayerTurn,
        gridSize: gridSize,
        difficulty: widget.difficulty,
      );
      _gameSaved = true;
    }
  }

  void _makeCpuMove() {
    if (isGameOver) return;
    int move = -1;

    if (widget.difficulty == 'Easy') {
      move = _getRandomMove();
    } else if (widget.difficulty == 'Medium') {
      move = _getHeuristicMove(depth: 1);
    } else {
      move = _getHeuristicMove(depth: 2);
    }

    if (move != -1) {
      setState(() {
        board[move] = 2;
        isPlayerTurn = true;
        _gameSaved = false;
      });
      SoundService().playTap();

      if (_checkWin(2)) {
        _endGame("CPU Wins!", false);
      } else if (!board.contains(0)) {
        _endGame("Draw!", false);
      }
    }
  }

  int _getRandomMove() {
    final emptySpots = [
      for (int i = 0; i < board.length; i++)
        if (board[i] == 0) i,
    ];
    if (emptySpots.isEmpty) return -1;
    return emptySpots[math.Random().nextInt(emptySpots.length)];
  }

  int _getHeuristicMove({required int depth}) {
    int bestScore = -1;
    int bestMove = -1;
    final emptySpots = [
      for (int i = 0; i < board.length; i++)
        if (board[i] == 0) i,
    ];

    for (int i in emptySpots) {
      int score =
          _evaluateCellForMove(i, 2) +
          _evaluateCellForMove(i, 1) * (depth == 2 ? 3 : 1);
      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }

    if (bestMove == -1) return _getRandomMove();
    return bestMove;
  }

  int _evaluateCellForMove(int index, int player) {
    int r = index ~/ gridSize;
    int c = index % gridSize;
    int totalScore = 0;

    totalScore += _countLine(r, c, 1, 0, player);
    totalScore += _countLine(r, c, 0, 1, player);
    totalScore += _countLine(r, c, 1, 1, player);
    totalScore += _countLine(r, c, 1, -1, player);

    return totalScore;
  }

  int _countLine(int r, int c, int dr, int dc, int player) {
    int count = 1;
    int openEnds = 0;

    for (int i = 1; i < winTarget; i++) {
      int nr = r + dr * i;
      int nc = c + dc * i;
      if (nr < 0 || nr >= gridSize || nc < 0 || nc >= gridSize) break;
      if (board[nr * gridSize + nc] == player) {
        count++;
      } else if (board[nr * gridSize + nc] == 0) {
        openEnds++;
        break;
      } else {
        break;
      }
    }

    for (int i = 1; i < winTarget; i++) {
      int nr = r - dr * i;
      int nc = c - dc * i;
      if (nr < 0 || nr >= gridSize || nc < 0 || nc >= gridSize) break;
      if (board[nr * gridSize + nc] == player) {
        count++;
      } else if (board[nr * gridSize + nc] == 0) {
        openEnds++;
        break;
      } else {
        break;
      }
    }

    if (count >= winTarget) return 100000;
    if (count == 4 && openEnds > 0) return 10000;
    if (count == 3 && openEnds == 2) return 5000;
    if (count == 3 && openEnds == 1) return 100;
    if (count == 2 && openEnds == 2) return 50;
    return count;
  }

  bool _checkWin(int player) {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (board[r * gridSize + c] == player) {
          if (_checkDirection(r, c, 1, 0, player) ||
              _checkDirection(r, c, 0, 1, player) ||
              _checkDirection(r, c, 1, 1, player) ||
              _checkDirection(r, c, 1, -1, player)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _checkDirection(int r, int c, int dr, int dc, int player) {
    List<int> currentLine = [];
    for (int i = 0; i < winTarget; i++) {
      int nr = r + dr * i;
      int nc = c + dc * i;
      if (nr < 0 || nr >= gridSize || nc < 0 || nc >= gridSize) return false;
      if (board[nr * gridSize + nc] != player) return false;
      currentLine.add(nr * gridSize + nc);
    }
    winningLine = currentLine;
    return true;
  }

  Future<void> _endGame(String result, bool playerWon) async {
    setState(() {
      isGameOver = true;
      winner = result;
    });
    await GameStateManager().clearGameState();

    if (playerWon) {
      await StatsManager().recordTicTacWin();
      SoundService().playWin();
    } else {
      if (result == "Draw!") {
        await StatsManager().recordTicTacDraw();
      } else {
        await StatsManager().recordTicTacLoss();
        SoundService().playLose();
      }
    }

    await AchievementManager().checkAndUnlockAchievements(
      difficulty: widget.difficulty,
      gridSize: gridSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFB100FF)),
          onPressed: () {
            _saveGame();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0),
            radius: 1.5,
            colors: [Color(0xFF1A0B2E), Color(0xFF0A061E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00E5FF),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withAlpha(100),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PLAYER',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF00E5FF),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'vs',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CustomPaint(
                          painter: XPainter(const Color(0xFFFF007F)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isMultiplayer ? 'PLAYER 2' : 'AI',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withAlpha(150),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fade().slideY(begin: -0.5),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withAlpha(15),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withAlpha(80),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(
                            winTarget,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF00E5FF),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00E5FF,
                                    ).withAlpha(60),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '= WIN',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF00E5FF),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isMultiplayer)
                      Builder(
                        builder: (context) {
                          final diffColor = widget.difficulty == 'Easy'
                              ? const Color(0xFF4CAF50)
                              : widget.difficulty == 'Medium'
                              ? const Color(0xFFFFD600)
                              : const Color(0xFFFF1744);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: diffColor.withAlpha(25),
                              border: Border.all(
                                color: diffColor.withAlpha(150),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: diffColor.withAlpha(30),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(
                              widget.difficulty.toUpperCase(),
                              style: GoogleFonts.outfit(
                                color: diffColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00E5FF),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withAlpha(50),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withAlpha(20),
                            blurRadius: 40,
                            spreadRadius: 10,
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size.infinite,
                            painter: GridLinesPainter(gridSize),
                          ),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: gridSize,
                                ),
                            itemCount: gridSize * gridSize,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _handleTap(index),
                                child: Container(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: board[index] == 0
                                        ? null
                                        : board[index] == 1
                                        ? Container(
                                            width:
                                                (MediaQuery.of(
                                                      context,
                                                    ).size.width -
                                                    48) /
                                                gridSize *
                                                0.6,
                                            height:
                                                (MediaQuery.of(
                                                      context,
                                                    ).size.width -
                                                    48) /
                                                gridSize *
                                                0.6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xFF00E5FF),
                                                width: gridSize == 3 ? 6 : 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF00E5FF,
                                                  ).withAlpha(100),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ).animate().scale(
                                            duration: 200.ms,
                                            curve: Curves.easeOutBack,
                                          )
                                        : SizedBox(
                                            width:
                                                (MediaQuery.of(
                                                      context,
                                                    ).size.width -
                                                    48) /
                                                gridSize *
                                                0.6,
                                            height:
                                                (MediaQuery.of(
                                                      context,
                                                    ).size.width -
                                                    48) /
                                                gridSize *
                                                0.6,
                                            child: CustomPaint(
                                              painter: XPainter(
                                                const Color(0xFFFF007F),
                                                strokeWidth: gridSize == 3
                                                    ? 6
                                                    : 3,
                                              ),
                                            ),
                                          ).animate().scale(
                                            duration: 200.ms,
                                            curve: Curves.easeOutBack,
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (isGameOver && winningLine.isNotEmpty)
                            CustomPaint(
                              size: Size.infinite,
                              painter: LinePainter(winningLine, gridSize),
                            ).animate().fade(duration: 500.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isGameOver)
                Column(
                  children: [
                    Text(
                      winner,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          const Shadow(color: Colors.white, blurRadius: 10),
                        ],
                      ),
                    ).animate().scale(curve: Curves.elasticOut),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          board = List.filled(gridSize * gridSize, 0);
                          isGameOver = false;
                          winner = "";
                          winningLine = [];
                          isPlayerTurn = true;
                          _gameSaved = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0A061E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'PLAY AGAIN',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().fade(delay: 500.ms).slideY(),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== CUSTOM PAINTERS ====================

class XPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  XPainter(this.color, {this.strokeWidth = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color.withAlpha(100)
      ..strokeWidth = strokeWidth * 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width, size.height),
      glowPaint,
    );
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), glowPaint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridLinesPainter extends CustomPainter {
  final int gridSize;
  GridLinesPainter(this.gridSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..strokeWidth = 1;

    double cellW = size.width / gridSize;
    double cellH = size.height / gridSize;

    for (int i = 1; i < gridSize; i++) {
      canvas.drawLine(
        Offset(i * cellW, 0),
        Offset(i * cellW, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, i * cellH),
        Offset(size.width, i * cellH),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniGridPainter extends CustomPainter {
  final int gridSize;
  MiniGridPainter(this.gridSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(50)
      ..strokeWidth = 1;

    double cellW = size.width / gridSize;
    double cellH = size.height / gridSize;

    for (int i = 1; i < gridSize; i++) {
      canvas.drawLine(
        Offset(i * cellW, 0),
        Offset(i * cellW, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, i * cellH),
        Offset(size.width, i * cellH),
        paint,
      );
    }

    final xPaint = Paint()
      ..color = const Color(0xFFFF007F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final oPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    void drawX(int r, int c) {
      double padding = cellW * 0.25;
      canvas.drawLine(
        Offset(c * cellW + padding, r * cellH + padding),
        Offset((c + 1) * cellW - padding, (r + 1) * cellH - padding),
        xPaint,
      );
      canvas.drawLine(
        Offset((c + 1) * cellW - padding, r * cellH + padding),
        Offset(c * cellW + padding, (r + 1) * cellH - padding),
        xPaint,
      );
    }

    void drawO(int r, int c) {
      canvas.drawCircle(
        Offset(c * cellW + cellW / 2, r * cellH + cellH / 2),
        cellW * 0.25,
        oPaint,
      );
    }

    if (gridSize == 3) {
      drawO(0, 0);
      drawX(0, 1);
      drawX(1, 0);
      drawO(1, 1);
      drawX(1, 2);
      drawO(2, 2);
    } else if (gridSize == 5) {
      drawO(1, 1);
      drawX(1, 3);
      drawX(2, 2);
      drawO(3, 1);
      drawO(3, 3);
    } else if (gridSize == 7) {
      drawX(2, 2);
      drawO(2, 4);
      drawO(4, 2);
      drawX(4, 4);
      drawX(3, 3);
    } else {
      drawX(3, 3);
      drawO(3, 4);
      drawX(3, 7);
      drawO(4, 4);
      drawX(4, 5);
      drawO(5, 5);
      drawX(6, 4);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LinePainter extends CustomPainter {
  final List<int> line;
  final int gridSize;
  LinePainter(this.line, this.gridSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (line.isEmpty) return;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = Colors.white.withAlpha(100)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    double cellWidth = size.width / gridSize;
    double cellHeight = size.height / gridSize;

    int startIdx = line.first;
    int endIdx = line.last;

    Offset start = Offset(
      (startIdx % gridSize) * cellWidth + cellWidth / 2,
      (startIdx ~/ gridSize) * cellHeight + cellHeight / 2,
    );
    Offset end = Offset(
      (endIdx % gridSize) * cellWidth + cellWidth / 2,
      (endIdx ~/ gridSize) * cellHeight + cellHeight / 2,
    );

    canvas.drawLine(start, end, glowPaint);
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WinConditionPainter extends CustomPainter {
  final int gridSize;
  final int winTarget;
  _WinConditionPainter(this.gridSize, this.winTarget);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..strokeWidth = 1;

    final cellW = size.width / gridSize;
    final cellH = size.height / gridSize;

    // Draw grid lines
    for (int i = 1; i < gridSize; i++) {
      canvas.drawLine(
        Offset(i * cellW, 0),
        Offset(i * cellW, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, i * cellH),
        Offset(size.width, i * cellH),
        gridPaint,
      );
    }

    // Draw winning line highlight (diagonal)
    final winPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withAlpha(60)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Draw winning pieces on diagonal
    for (int i = 0; i < winTarget; i++) {
      final cx = i * cellW + cellW / 2;
      final cy = i * cellH + cellH / 2;
      final radius = cellW * 0.25;

      // Glow
      canvas.drawCircle(
        Offset(cx, cy),
        radius,
        Paint()
          ..color = const Color(0xFF00E5FF).withAlpha(40)
          ..style = PaintingStyle.fill,
      );
      // Circle
      canvas.drawCircle(Offset(cx, cy), radius, winPaint);
    }

    // Draw winning line through pieces
    final startX = cellW / 2;
    final startY = cellH / 2;
    final endX = (winTarget - 1) * cellW + cellW / 2;
    final endY = (winTarget - 1) * cellH + cellH / 2;
    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), glowPaint);
    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, endY),
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
