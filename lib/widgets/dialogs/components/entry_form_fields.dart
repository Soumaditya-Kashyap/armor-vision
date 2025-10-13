import 'package:flutter/material.dart';

class EntryFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController notesController;

  const EntryFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Title',
            hintText: 'Enter entry title',
            prefixIcon: const Icon(Icons.title_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surface,
          ),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Description Field
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Enter a brief description',
            prefixIcon: const Icon(Icons.description_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surface,
          ),
          textInputAction: TextInputAction.next,
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Notes Field
        TextFormField(
          controller: notesController,
          decoration: InputDecoration(
            labelText: 'Notes (Optional)',
            hintText: 'Add any additional notes',
            prefixIcon: const Icon(Icons.note_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surface,
          ),
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}
