import 'package:flutter/material.dart';
import '../../models/password_entry.dart';
import 'add_entry_dialog.dart';
import 'detail_components/entry_header.dart';
import 'detail_components/entry_info_section.dart';
import 'detail_components/fields_list_section.dart';
import 'detail_components/notes_section.dart';

class PasswordEntryDetailDialog extends StatefulWidget {
  final PasswordEntry entry;
  final VoidCallback? onEntryUpdated;

  const PasswordEntryDetailDialog({
    super.key,
    required this.entry,
    this.onEntryUpdated,
  });

  @override
  State<PasswordEntryDetailDialog> createState() =>
      _PasswordEntryDetailDialogState();
}

class _PasswordEntryDetailDialogState extends State<PasswordEntryDetailDialog>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Visibility state
  bool _allFieldsVisible = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _fadeAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                  maxHeight: 600,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EntryHeader(
                      entry: widget.entry,
                      onEdit: _editEntry,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EntryInfoSection(entry: widget.entry),
                            const SizedBox(height: 24),
                            FieldsListSection(
                              entry: widget.entry,
                              allFieldsVisible: _allFieldsVisible,
                              onToggleVisibility: () {
                                setState(() {
                                  _allFieldsVisible = !_allFieldsVisible;
                                });
                              },
                            ),

                            // Notes section - only show if notes exist
                            if (widget.entry.notes != null &&
                                widget.entry.notes!.trim().isNotEmpty) ...[
                              const SizedBox(height: 24),
                              NotesSection(notes: widget.entry.notes!),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _editEntry() async {
    // Close current dialog first
    Navigator.of(context).pop();

    // Open edit dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEntryDialog(
        existingEntry: widget.entry,
        onEntryUpdated: widget.onEntryUpdated,
      ),
    );
  }
}
