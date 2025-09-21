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

  void updateProjectInfo({String? projeAdi, String? adres, String? malSahibi, double? otoparkAlani}) {
    state = state.copyWith(
      projeAdi: projeAdi ?? state.projeAdi,
      adres: adres ?? state.adres,
      malSahibi: malSahibi ?? state.malSahibi,
      otoparkAlani: otoparkAlani ?? state.otoparkAlani,
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

  void copyFloor(String floorId) {
    final originalFloor = state.katlar.firstWhere((f) => f.id == floorId);
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Extract floor number and increment it
    String newFloorName = originalFloor.ad;
    final match = RegExp(r'(\d+)').firstMatch(originalFloor.ad);
    if (match != null) {
      final floorNumber = int.tryParse(match.group(1)!) ?? 0;
      newFloorName = originalFloor.ad.replaceFirst(match.group(1)!, '${floorNumber + 1}');
    } else {
      newFloorName = '${originalFloor.ad} - Kopya';
    }
    
    // Copy all units with new IDs but preserve all other properties
    final copiedUnits = originalFloor.daireler.map((unit) {
      return unit.copyWith(
        id: '${DateTime.now().millisecondsSinceEpoch}_${unit.id}',
      );
    }).toList();
    
    final newFloor = originalFloor.copyWith(
      id: newId,
      ad: newFloorName,
      daireler: copiedUnits,
    );
    
    // Add the new floor right after the original floor in the list
    // Since we display floors reversed, adding after means higher floor
    final floorIndex = state.katlar.indexWhere((f) => f.id == floorId);
    final newKatlar = List<FloorModel>.from(state.katlar);
    newKatlar.insert(floorIndex + 1, newFloor);
    
    state = state.copyWith(katlar: newKatlar);
    _saveProject();
  }

  void removeFloor(String floorId) {
    state = state.copyWith(
      katlar: state.katlar.where((floor) => floor.id != floorId).toList(),
    );
    _saveProject();
  }

  void reorderFloors(int oldIndex, int newIndex) {
    final floors = List<FloorModel>.from(state.katlar);
    final floor = floors.removeAt(oldIndex);
    floors.insert(newIndex, floor);
    
    state = state.copyWith(katlar: floors);
    _saveProject();
  }

  void reorderUnits(String floorId, int oldIndex, int newIndex) {
    state = state.copyWith(
      katlar: state.katlar.map((floor) {
        if (floor.id == floorId) {
          final units = List<UnitModel>.from(floor.daireler);
          final unit = units.removeAt(oldIndex);
          units.insert(newIndex, unit);
          
          // Update unit numbers after reordering within this floor
          final updatedUnits = _updateFloorUnitNumbers(floorId, units);
          
          return floor.copyWith(daireler: updatedUnits);
        }
        return floor;
      }).toList(),
    );
    _saveProject();
  }

  List<UnitModel> _updateFloorUnitNumbers(String floorId, List<UnitModel> units) {
    // Get the lowest existing door number from this floor to maintain continuity
    int baseDoorNumber = 1;
    
    // Find all door numbers that follow "Daire X" pattern in this floor
    final existingNumbers = <int>[];
    for (final unit in units) {
      final match = RegExp(r'Daire (\d+)').firstMatch(unit.ad);
      if (match != null) {
        final doorNumber = int.tryParse(match.group(1)!) ?? 0;
        existingNumbers.add(doorNumber);
      }
    }
    
    // If we have existing numbers, use the lowest one as base
    if (existingNumbers.isNotEmpty) {
      existingNumbers.sort();
      baseDoorNumber = existingNumbers.first;
    }
    
    // Update unit names while preserving non-standard names
    return units.asMap().entries.map((entry) {
      final index = entry.key;
      final unit = entry.value;
      
      // Only update units that follow "Daire X" pattern
      final match = RegExp(r'Daire (\d+)').firstMatch(unit.ad);
      if (match != null) {
        // Sequential numbering starting from base
        final newDoorNumber = baseDoorNumber + index;
        return unit.copyWith(ad: 'Daire $newDoorNumber');
      }
      
      // Keep custom names as they are
      return unit;
    }).toList();
  }

  void updateFloor(String floorId, {String? ad, bool? collapsed, String? aciklama, double? ortakAlan}) {
    state = state.copyWith(
      katlar: state.katlar.map((floor) {
        if (floor.id == floorId) {
          return floor.copyWith(
            ad: ad ?? floor.ad,
            collapsed: collapsed ?? floor.collapsed,
            aciklama: aciklama ?? floor.aciklama,
            ortakAlan: ortakAlan ?? floor.ortakAlan,
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
    
    // Calculate next sequential door number across all floors
    int nextDoorNumber = 1;
    for (final floor in state.katlar) {
      for (final unit in floor.daireler) {
        // Extract number from unit name if it follows "Daire X" pattern
        final match = RegExp(r'Daire (\d+)').firstMatch(unit.ad);
        if (match != null) {
          final doorNumber = int.tryParse(match.group(1)!) ?? 0;
          if (doorNumber >= nextDoorNumber) {
            nextDoorNumber = doorNumber + 1;
          }
        }
      }
    }
    
    final newUnit = UnitModel(
      id: newId,
      ad: 'Daire $nextDoorNumber',
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
    CepheTarafi? cepheTarafi,
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
                  cepheTarafi: cepheTarafi ?? unit.cepheTarafi,
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