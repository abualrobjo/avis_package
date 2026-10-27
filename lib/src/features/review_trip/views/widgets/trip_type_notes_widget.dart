import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

class TripTypeNotesWidget extends StatelessWidget {
  const TripTypeNotesWidget({
    super.key,
    required this.notes,
    this.servicePrimaryName,
    this.serviceSecondaryName,
  });

  final List<TripTypeNoteModel> notes;
  final String? servicePrimaryName;
  final String? serviceSecondaryName;

  @override
  Widget build(BuildContext context) {
    final groups = TripTypeNoteGroup.fromNotes(notes);
    if (groups.isEmpty) return const SizedBox.shrink();

    final trimmedName = context
        .localized(servicePrimaryName ?? '', serviceSecondaryName)
        .trim();
    final header = trimmedName.isEmpty
        ? 'General Terms and Conditions'
        : '$trimmedName, General Terms and Conditions';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HorizontalDivider(),
        const SizedBox(height: AppSpaces.large),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpaces.medium),
                child: TextWidget(
                  header,
                  style: AppTextStyles.bodyLargeBold.copyWith(
                    color: context.colors.primaryText,
                  ),
                ),
              ),
              for (var i = 0; i < groups.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpaces.medium),
                if (groups[i].title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextWidget(
                      groups[i].title,
                      style: AppTextStyles.bodyLargeBold.copyWith(
                        color: context.colors.primaryText,
                      ),
                    ),
                  ),
                for (final note in groups[i].notes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            context.localized(
                              note.notePrimaryName ?? '',
                              note.noteSecondaryName,
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: context.colors.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpaces.large),
        const HorizontalDivider(),
      ],
    );
  }
}
