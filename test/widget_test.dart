import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:architecture_plan_maker/app.dart';

void main() {
  testWidgets('Uygulama başlatma testi', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ArchitecturePlanMakerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Mimari Teklif Hazırlama'), findsOneWidget);
    expect(find.text('PDF İndir'), findsOneWidget);
  });

  testWidgets('Sidebar görünürlük testi', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ArchitecturePlanMakerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Proje Bilgileri'), findsOneWidget);
    expect(find.text('Görünüm Ayarları'), findsOneWidget);
    expect(find.text('Katlar'), findsOneWidget);
  });
}
