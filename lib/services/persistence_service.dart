import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/project.dart';

class PersistenceService {
  static const String _projectKey = 'current_project';

  Future<void> saveProject(ProjectModel project) async {
    final prefs = await SharedPreferences.getInstance();
    final projectJson = json.encode(project.toJson());
    await prefs.setString(_projectKey, projectJson);
  }

  Future<ProjectModel?> loadProject() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectJson = prefs.getString(_projectKey);
      
      if (projectJson != null) {
        final projectMap = json.decode(projectJson) as Map<String, dynamic>;
        return ProjectModel.fromJson(projectMap);
      }
    } catch (e) {
      // Veri yüklenirken hata oluşursa null döndür
    }
    
    return null;
  }

  Future<void> clearProject() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_projectKey);
  }
}