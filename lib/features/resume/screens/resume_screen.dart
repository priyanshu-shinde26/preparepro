import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../viewmodels/resume_viewmodel.dart';

class ResumeScreen extends ConsumerStatefulWidget {
  const ResumeScreen({super.key});

  @override
  ConsumerState<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends ConsumerState<ResumeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _projectsCtrl = TextEditingController();
  final _targetRoleCtrl = TextEditingController();
  final _targetCompanyCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _phoneCtrl, _skillsCtrl, _educationCtrl,
      _experienceCtrl, _projectsCtrl, _targetRoleCtrl, _targetCompanyCtrl, _summaryCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resumeProvider);
    final notifier = ref.read(resumeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Builder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            if (state.generatedResume != null) notifier.reset();
            else Navigator.of(context).pop();
          },
        ),
      ),
      body: state.isGenerating
          ? const LoadingWidget(message: 'Generating your ATS-optimized resume...')
          : state.generatedResume != null
          ? _ResumePreview(
        resumeText: state.generatedResume!,
        onBack: notifier.reset,
      )
          : _ResumeForm(
        formKey: _formKey,
        nameCtrl: _nameCtrl,
        emailCtrl: _emailCtrl,
        phoneCtrl: _phoneCtrl,
        skillsCtrl: _skillsCtrl,
        educationCtrl: _educationCtrl,
        experienceCtrl: _experienceCtrl,
        projectsCtrl: _projectsCtrl,
        targetRoleCtrl: _targetRoleCtrl,
        targetCompanyCtrl: _targetCompanyCtrl,
        summaryCtrl: _summaryCtrl,
        onGenerate: () {
          if (_formKey.currentState!.validate()) {
            notifier.generate(
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              phone: _phoneCtrl.text.trim(),
              skills: _skillsCtrl.text.trim(),
              education: _educationCtrl.text.trim(),
              experience: _experienceCtrl.text.trim(),
              projects: _projectsCtrl.text.trim(),
              targetRole: _targetRoleCtrl.text.trim(),
              targetCompany: _targetCompanyCtrl.text.trim(),
              summary: _summaryCtrl.text.trim(),
            );
          }
        },
        error: state.error,
      ),
    );
  }
}

class _ResumeForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, emailCtrl, phoneCtrl, skillsCtrl,
      educationCtrl, experienceCtrl, projectsCtrl, targetRoleCtrl,
      targetCompanyCtrl, summaryCtrl;
  final VoidCallback onGenerate;
  final String? error;

  const _ResumeForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.skillsCtrl,
    required this.educationCtrl,
    required this.experienceCtrl,
    required this.projectsCtrl,
    required this.targetRoleCtrl,
    required this.targetCompanyCtrl,
    required this.summaryCtrl,
    required this.onGenerate,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppTheme.cardGradients[3]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Resume Builder', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
                        Text('ATS-optimized for your target role', style: GoogleFonts.sora(color: Colors.white70, fontSize: 12)),
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
            _SectionTitle('Personal Information'),
            _FormField(ctrl: nameCtrl, label: 'Full Name *', icon: Icons.person_outline_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
            _FormField(ctrl: emailCtrl, label: 'Email *', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => v!.contains('@') ? null : 'Invalid email'),
            _FormField(ctrl: phoneCtrl, label: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            _FormField(ctrl: summaryCtrl, label: 'Professional Summary', icon: Icons.notes_rounded, maxLines: 3),

            const SizedBox(height: 8),
            _SectionTitle('Target'),
            _FormField(ctrl: targetRoleCtrl, label: 'Target Role *', icon: Icons.work_outline_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
            _FormField(ctrl: targetCompanyCtrl, label: 'Target Company (optional)', icon: Icons.business_outlined),

            const SizedBox(height: 8),
            _SectionTitle('Skills & Experience'),
            _FormField(ctrl: skillsCtrl, label: 'Skills *', icon: Icons.psychology_outlined, maxLines: 3, hint: 'e.g., Java, Python, React, SQL...', validator: (v) => v!.isEmpty ? 'Required' : null),
            _FormField(ctrl: educationCtrl, label: 'Education *', icon: Icons.school_outlined, maxLines: 3, hint: 'B.Tech in CS, XYZ University, 2024...', validator: (v) => v!.isEmpty ? 'Required' : null),
            _FormField(ctrl: experienceCtrl, label: 'Work Experience', icon: Icons.business_center_outlined, maxLines: 4, hint: 'Intern at ABC Corp, developed...'),
            _FormField(ctrl: projectsCtrl, label: 'Projects *', icon: Icons.folder_open_rounded, maxLines: 4, hint: 'Project Name: Description, Tech used...', validator: (v) => v!.isEmpty ? 'Required' : null),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'Generate Resume',
                icon: Icons.auto_awesome_rounded,
                onTap: onGenerate,
                gradient: AppTheme.cardGradients[3],
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: GoogleFonts.sora(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? 50 : 0),
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }
}

class _ResumePreview extends StatelessWidget {
  final String resumeText;
  final VoidCallback onBack;

  const _ResumePreview({required this.resumeText, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(bottom: BorderSide(color: cs.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '✅ Resume Generated!',
                  style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: AppTheme.accentGreen),
                ),
              ),
              // PDF export
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.accentRed),
                tooltip: 'Export PDF',
                onPressed: () => _exportPdf(context),
              ),
              // Share
              IconButton(
                icon: const Icon(Icons.share_rounded, color: AppTheme.primaryBlue),
                tooltip: 'Share',
                onPressed: () => Share.share(resumeText, subject: 'My AI Resume'),
              ),
              // Edit
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Edit',
                onPressed: onBack,
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: SelectableText(
                resumeText,
                style: GoogleFonts.sora(fontSize: 13, height: 1.7, color: cs.onSurface),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Download PDF',
                  icon: Icons.download_rounded,
                  onTap: () => _exportPdf(context),
                  gradient: [AppTheme.accentRed, const Color(0xFFDC2626)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'Share',
                  icon: Icons.share_rounded,
                  onTap: () => Share.share(resumeText, subject: 'My AI Resume'),
                  gradient: AppTheme.cardGradients[3],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context c) => [
          pw.Text(
            resumeText,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}