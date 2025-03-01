import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkMerkinsCompletion() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  int completedMerkins = prefs.getInt('merkings_today') ?? 0;
  int requiredMerkins = 100; // Adjust based on your challenge

  return completedMerkins >= requiredMerkins;
}
