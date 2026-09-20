import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_text_field.dart';

class FacultyScreen extends StatefulWidget {
  const FacultyScreen({super.key});

  @override
  State<FacultyScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends State<FacultyScreen> {
  String _searchQuery = '';
  String _selectedDepartment = 'All Departments';

  final List<String> _departmentFilterOptions = [
    'All Departments',
    'Computer Science & Engineering',
    'Information Technology',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Artificial Intelligence & Data Science',
  ];

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final facultyList = firestoreService.faculty;

    final filtered = facultyList.where((f) {
      final matchesDept = _selectedDepartment == 'All Departments' ||
          (f.department != null && f.department!.toLowerCase().contains(_selectedDepartment.toLowerCase()));
      final q = _searchQuery.toLowerCase();
      final matchesSearch = f.name.toLowerCase().contains(q) ||
          f.email.toLowerCase().contains(q) ||
          (f.designation ?? '').toLowerCase().contains(q) ||
          (f.department ?? '').toLowerCase().contains(q);
      return matchesDept && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Faculty Directory',
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage academic professors, designations, qualifications, and department appointments.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddFacultyModal(context, firestoreService),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Add New Faculty'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters Bar
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search faculty by name, designation, email...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDepartment,
                      isExpanded: true,
                      items: _departmentFilterOptions.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.inter(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDepartment = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Faculty Grid Cards
          filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        const Icon(Icons.school_outlined, size: 54, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text('No faculty members found.', style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 480,
                    mainAxisExtent: 180,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final f = filtered[idx];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.12),
                            child: Text(
                              f.name.isNotEmpty ? f.name[0] : 'F',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF0D9488)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        f.name,
                                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Delete Faculty?'),
                                            content: Text('Remove ${f.name} from directory?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await firestoreService.deleteFaculty(f.id);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  f.designation ?? 'Professor',
                                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0D9488), fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  f.department ?? 'General Engineering',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  f.qualification ?? 'M.Tech, Ph.D',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📧 ${f.email} • 📞 ${f.phone ?? '9876543210'}',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _showAddFacultyModal(BuildContext context, FirestoreService service) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final designationCtrl = TextEditingController(text: 'Associate Professor');
    final qualificationCtrl = TextEditingController(text: 'M.Tech (CSE)');
    String department = 'Computer Science & Engineering';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Faculty Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: nameCtrl, label: 'Full Name', hintText: 'Dr. / Prof. Name'),
                const SizedBox(height: 12),
                CustomTextField(controller: emailCtrl, label: 'Email', hintText: 'name@assessment.edu'),
                const SizedBox(height: 12),
                CustomTextField(controller: phoneCtrl, label: 'Phone', hintText: '9876543210'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: department,
                  decoration: InputDecoration(
                    labelText: 'Assigned Department',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: _departmentFilterOptions.where((d) => d != 'All Departments').map((d) {
                    return DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => department = val);
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(controller: designationCtrl, label: 'Designation', hintText: 'e.g. Professor & HOD'),
                const SizedBox(height: 12),
                CustomTextField(controller: qualificationCtrl, label: 'Qualification', hintText: 'e.g. M.Tech, Ph.D'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                  final newFac = UserModel(
                    id: 'fac_${DateTime.now().millisecondsSinceEpoch}',
                    employeeId: 'EMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    role: 'Faculty',
                    phone: phoneCtrl.text.trim(),
                    department: department,
                    designation: designationCtrl.text.trim(),
                    qualification: qualificationCtrl.text.trim(),
                    createdAt: DateTime.now(),
                  );
                  service.addFaculty(newFac);
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
              child: const Text('Add Faculty', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
