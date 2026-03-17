import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../viewmodels/company_viewmodel.dart';

class CompanyScreen extends ConsumerStatefulWidget {
  const CompanyScreen({super.key});

  @override
  ConsumerState<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  final _companyCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  String? _selectedCompany;

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyProvider);
    final notifier = ref.read(companyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Preparation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            if (state.data != null) notifier.reset();
            else Navigator.of(context).pop();
          },
        ),
      ),
      body: state.isLoading
          ? const LoadingWidget(message: 'Fetching company insights...')
          : state.data != null
          ? _CompanyDataView(state: state)
          : _InputView(
        companyCtrl: _companyCtrl,
        roleCtrl: _roleCtrl,
        selectedCompany: _selectedCompany,
        onSelectCompany: (c) {
          setState(() {
            _selectedCompany = c;
            _companyCtrl.text = c;
          });
        },
        isLoading: state.isLoading,
        error: state.error,
        onGenerate: () {
          final company = _companyCtrl.text.trim();
          final role = _roleCtrl.text.trim();
          if (company.isEmpty || role.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill all fields')),
            );
            return;
          }
          notifier.generate(company: company, role: role);
        },
      ),
    );
  }
}

class _InputView extends StatelessWidget {
  final TextEditingController companyCtrl, roleCtrl;
  final String? selectedCompany;
  final ValueChanged<String> onSelectCompany;
  final bool isLoading;
  final String? error;
  final VoidCallback onGenerate;

  const _InputView({
    required this.companyCtrl,
    required this.roleCtrl,
    required this.selectedCompany,
    required this.onSelectCompany,
    required this.isLoading,
    required this.error,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.cardGradients[4]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.business_rounded, color: Colors.white, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Company Intel', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
                      Text('AI-curated prep for any company', style: GoogleFonts.sora(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.2),

          if (error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.accentRed.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(error!, style: GoogleFonts.sora(color: AppTheme.accentRed, fontSize: 13)),
            ),
          ],

          const SizedBox(height: 28),
          Text('Company Name', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: companyCtrl,
            decoration: const InputDecoration(
              hintText: 'e.g., Google, TCS, Infosys...',
              prefixIcon: Icon(Icons.business_outlined),
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),
          Text('Popular Companies', style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 13, color: cs.onSurface.withOpacity(0.6))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.topCompanies.take(12).map((c) {
              final selected = c == selectedCompany;
              return GestureDetector(
                onTap: () => onSelectCompany(c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.accentOrange.withOpacity(0.15) : cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? AppTheme.accentOrange : cs.outline.withOpacity(0.3)),
                  ),
                  child: Text(c, style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? AppTheme.accentOrange : cs.onSurface)),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 20),
          Text('Your Role / Position', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: roleCtrl,
            decoration: const InputDecoration(
              hintText: 'e.g., Software Engineer, Data Analyst...',
              prefixIcon: Icon(Icons.work_outline_rounded),
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: 'Generate Company Guide',
              icon: Icons.auto_awesome_rounded,
              isLoading: isLoading,
              onTap: onGenerate,
              gradient: AppTheme.cardGradients[4],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _CompanyDataView extends StatelessWidget {
  final CompanyState state;
  const _CompanyDataView({required this.state});

  @override
  Widget build(BuildContext context) {
    final data = state.data!;
    final cs = Theme.of(context).colorScheme;

    final sections = [
      _SectionData('🏢 Company Overview', data['overview'] ?? '', Icons.info_outline_rounded, AppTheme.primaryBlue),
      _SectionData('🔄 Selection Process', data['selectionProcess'] ?? '', Icons.timeline_rounded, AppTheme.primaryPurple),
      _SectionData('❓ Frequently Asked Questions', data['faqs'] ?? '', Icons.quiz_rounded, AppTheme.accentCyan),
      _SectionData('📚 Important Topics', data['importantTopics'] ?? '', Icons.book_outlined, AppTheme.accentGreen),
      _SectionData('💡 Tips to Crack', data['tips'] ?? '', Icons.lightbulb_outline_rounded, AppTheme.accentOrange),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.cardGradients[4]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.business_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.company, style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                      Text('Role: ${state.role}', style: GoogleFonts.sora(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          ...sections.asMap().entries.map((entry) {
            return _ExpandableSection(
              section: entry.value,
              index: entry.key,
            );
          }).toList(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatefulWidget {
  final _SectionData section;
  final int index;
  const _ExpandableSection({required this.section, required this.index});

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: widget.index == 0,
            onExpansionChanged: (v) => setState(() => _expanded = v),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.section.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.section.icon, color: widget.section.color, size: 20),
            ),
            title: Text(
              widget.section.title,
              style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  widget.section.content,
                  style: GoogleFonts.sora(fontSize: 13, height: 1.7, color: cs.onSurface.withOpacity(0.8)),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 100 * widget.index)).slideY(begin: 0.2),
    );
  }
}

class _SectionData {
  final String title, content;
  final IconData icon;
  final Color color;
  const _SectionData(this.title, this.content, this.icon, this.color);
}