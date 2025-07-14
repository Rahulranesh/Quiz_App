import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/storage_service.dart';

class DebugExport {
  static Future<void> exportSharedPreferencesToFile() async {
    try {
      // Get all stored data
      final allData = await StorageService.getAllStoredData();
      
      // Get the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/shared_preferences_debug.json');
      
      // Write data to file with pretty formatting
      final jsonString = const JsonEncoder.withIndent('  ').convert(allData);
      await file.writeAsString(jsonString);
      
      print('✅ SharedPreferences data exported to: ${file.path}');
      print('📁 You can now open this file in VS Code to view your data');
      
      // Also print to console for immediate viewing
      print('\n📊 Current SharedPreferences Data:');
      print('=' * 50);
      print(jsonString);
      print('=' * 50);
      
    } catch (e) {
      print('❌ Error exporting data: $e');
    }
  }
  
  static Future<void> exportToDesktop() async {
    try {
      final allData = await StorageService.getAllStoredData();
      
      // Try to get desktop directory
      String desktopPath;
      if (Platform.isLinux || Platform.isMacOS) {
        desktopPath = '${Platform.environment['HOME']}/Desktop';
      } else if (Platform.isWindows) {
        desktopPath = '${Platform.environment['USERPROFILE']}/Desktop';
      } else {
        desktopPath = await getApplicationDocumentsDirectory().then((dir) => dir.path);
      }
      
      final file = File('$desktopPath/quiz_app_debug_data.json');
      final jsonString = const JsonEncoder.withIndent('  ').convert(allData);
      await file.writeAsString(jsonString);
      
      print('✅ Data exported to desktop: ${file.path}');
      print('📁 Open this file in VS Code to view your SharedPreferences data');
      
    } catch (e) {
      print('❌ Error exporting to desktop: $e');
    }
  }
} 