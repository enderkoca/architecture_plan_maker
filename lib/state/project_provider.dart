import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/project.dart';
import '../data/models/floor.dart';
import '../data/models/unit.dart';
import '../data/seed/demo_data.dart';
import '../services/persistence_service.dart';

class ProjectNotifier extends StateNotifier<ProjectModel> {
  ProjectNotifier() : super(DemoData.emptyProject) {
    _loadProject();
  }

  final _persistenceService = PersistenceService();

  Future<void> _loadProject() async {
    final savedProject = await _persistenceService.loadProject();
    if (savedProject != null) {
      state = savedProject;
    } else {
      loadDemoData();
    }
  }

  Future<void> _saveProject() async {
    await _persistenceService.saveProject(state);
  }

  void updateProjectInfo({String? projeAdi, String? adres}) {
    state = state.copyWith(
      projeAdi: projeAdi ?? state.projeAdi,
      adres: adres ?? state.adres,
    );
    _saveProject();
  }

  void updateViewSettings({bool? showCati, bool? showOtopark}) {
    state = state.copyWith(
      showCati: showCati ?? state.showCati,
      showOtopark: showOtopark ?? state.showOtopark,
    );
    _saveProject();
  }

  void addFloor() {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newFloor = FloorModel(
      id: newId,
      ad: '${state.katlar.length + 1}. Kat',
      alan: 0.0,
      daireler: [],
    );
    
    state = state.copyWith(
      katlar: [...state.katlar, newFloor],
    );
    _saveProject();
  }

  void removeFloor(String floorId) {
    state = state.copyWith(
      katlar: state.katlar.where((floor) => floor.id != floorId).toList(),
    );
    _saveProject();
  }

  void updateFloor(String floorId, {String? ad, double? alan, bool? collapsed, String? aciklama}) {
    state = state.copyWith(
      katlar: state.katlar.map((floor) {
        if (floor.id == floorId) {
          return floor.copyWith(
            ad: ad ?? floor.ad,
            alan: alan ?? floor.alan,
            collapsed: collapsed ?? floor.collapsed,
            aciklama: aciklama ?? floor.aciklama,
          );
        }
        return floor;
      }).toList(),
    );
    _saveProject();
  }

  void toggleFloorCollapsed(String floorId) {
    state = state.copyWith(
      katlar: state.katlar.map((floor) {
        if (floor.id == floorId) {
          return floor.copyWith(collapsed: !floor.collapsed);
        }
        return floor;
      }).toList(),
    );
    _saveProject();
  }

  void addUnit(String floorId) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final floor = state.katlar.firstWhere((f) => f.id == floorId);
    final newUnit = UnitModel(
      id: newId,
      ad: 'Daire ${floor.daireler.length + 1}',
      malik: Malik.muteahhit,
    );

    state = state.copyWith(
      katlar: state.katlar.map((f) {
        if (f.id == floorId) {
          return f.copyWith(
            daireler: [...f.daireler, newUnit],
          );
        }
        return f;
      }).toList(),
    );
    _saveProject();
  }

  void removeUnit(String floorId, String unitId) {
    state = state.copyWith(
      katlar: state.katlar.map((floor) {
        if (floor.id == floorId) {
          return floor.copyWith(
            daireler: floor.daireler.where((unit) => unit.id != unitId).toList(),
          );
        }
        return floor;
      }).toList(),
    );
    _saveProject();
  }

  void updateUnit(
    String floorId,
    String unitId, {
    String? ad,
    Malik? malik,
    double? eskiBrut,
    double? yeniBrut,
  }) {
    state = state.copyWith(
      katlar: state.katlar.map((floor) {
        if (floor.id == floorId) {
          return floor.copyWith(
            daireler: floor.daireler.map((unit) {
              if (unit.id == unitId) {
                return unit.copyWith(
                  ad: ad ?? unit.ad,
                  malik: malik ?? unit.malik,
                  eskiBrut: eskiBrut ?? unit.eskiBrut,
                  yeniBrut: yeniBrut ?? unit.yeniBrut,
                );
              }
              return unit;
            }).toList(),
          );
        }
        return floor;
      }).toList(),
    );
    _saveProject();
  }

  void loadDemoData() {
    state = DemoData.sampleProject;
    _saveProject();
  }

  void resetProject() {
    state = DemoData.emptyProject;
    _saveProject();
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectModel>((ref) {
  return ProjectNotifier();
});