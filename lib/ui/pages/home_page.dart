import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sidebar/project_form.dart';
import '../widgets/sidebar/view_toggles.dart';
import '../widgets/sidebar/floors_panel.dart';
import '../widgets/canvas/preview_canvas.dart';
import '../../services/pdf_service.dart';
import '../../state/project_provider.dart';
import '../../state/theme_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _sidebarVisible = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrMobile = screenWidth < 1024;
    final isDark = ref.watch(themeProvider.notifier).isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mimari Teklif Hazırlama'),
        leading: isTabletOrMobile
            ? IconButton(
                icon: Icon(_sidebarVisible ? Icons.close : Icons.menu),
                onPressed: () {
                  setState(() {
                    _sidebarVisible = !_sidebarVisible;
                  });
                },
              )
            : null,
        actions: [
          Switch(
            value: isDark,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => _downloadPDF(context),
              icon: const Icon(Icons.download),
              label: const Text('PDF İndir'),
            ),
          ),
        ],
      ),
      body: isTabletOrMobile
          ? _buildMobileLayout()
          : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: _buildSidebar(),
        ),
        const VerticalDivider(width: 1),
        const Expanded(
          child: PreviewCanvas(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _sidebarVisible ? 400 : 0,
          child: _sidebarVisible
              ? _buildSidebar()
              : const SizedBox.shrink(),
        ),
        if (_sidebarVisible) const Divider(height: 1),
        Expanded(
          child: const PreviewCanvas(),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProjectForm(),
            SizedBox(height: 16),
            ViewToggles(),
            SizedBox(height: 16),
            FloorsPanel(),
            SizedBox(height: 24),
            _ActionButtons(),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPDF(BuildContext context) async {
    try {
      final project = ref.read(projectProvider);
      final pdfService = PdfService();
      await pdfService.generateAndDownloadPDF(project);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF başarıyla indirildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            ref.read(projectProvider.notifier).resetProject();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Yeni Proje'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            context.push('/cost');
          },
          icon: const Icon(Icons.calculate),
          label: const Text('Maliyet Hesaplama'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(projectProvider.notifier).loadDemoData();
          },
          icon: const Icon(Icons.upload),
          label: const Text('Örnek Veriyi Yükle'),
        ),
      ],
    );
  }
}