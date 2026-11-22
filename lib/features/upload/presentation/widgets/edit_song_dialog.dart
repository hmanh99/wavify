import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/song_entity.dart';
import '../bloc/upload_bloc.dart';
import '../bloc/upload_event.dart';

class EditSongDialog extends StatefulWidget {
  final SongEntity song;

  const EditSongDialog({super.key, required this.song});

  static Future<void> show(BuildContext context, SongEntity song) {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<UploadBloc>(),
        child: EditSongDialog(song: song),
      ),
    );
  }

  @override
  State<EditSongDialog> createState() => _EditSongDialogState();
}

class _EditSongDialogState extends State<EditSongDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _albumController;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song.title);
    _artistController = TextEditingController(text: widget.song.artist);
    _albumController = TextEditingController(text: widget.song.album ?? '');
    _isPublic = widget.song.isPublic;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  void _onSave() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final title = _titleController.text.trim();
    final artist = _artistController.text.trim();
    final album = _albumController.text.trim();

    context.read<UploadBloc>().add(
      UpdateSongSubmitted(
        songId: widget.song.id,
        title: title,
        artist: artist.isNotEmpty ? artist : 'Unknown Artist',
        album: album.isNotEmpty ? album : null,
        visibility: _isPublic ? 'PUBLIC' : 'PRIVATE',
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final appColors = context.appColors;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg + AppSpacing.xs,
        vertical: AppSpacing.xl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg + AppSpacing.xs),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        context.l10n.editSong,
                        style: textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.cancel,
                      icon: Icon(
                        Icons.close_rounded,
                        color: appColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: '${context.l10n.songTitle} *',
                  hint: context.l10n.songTitle,
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.pleaseEnterSongTitle;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: context.l10n.artist,
                  hint: context.l10n.artist,
                  controller: _artistController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: context.l10n.albumOptional,
                  hint: context.l10n.albumOptional,
                  controller: _albumController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onSave(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(context.l10n.visibility, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            context.l10n.publicVisibility,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        selected: _isPublic,
                        showCheckmark: false,
                        selectedColor: colorScheme.primary.withValues(
                          alpha: 0.14,
                        ),
                        backgroundColor: appColors.inputFill,
                        labelStyle: textTheme.bodySmall?.copyWith(
                          color: _isPublic
                              ? colorScheme.primary
                              : appColors.textMuted,
                          fontWeight: _isPublic
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: _isPublic
                              ? colorScheme.primary
                              : appColors.subtleBorder,
                        ),
                        onSelected: (_) => setState(() => _isPublic = true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            context.l10n.privateVisibility,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        selected: !_isPublic,
                        showCheckmark: false,
                        selectedColor: colorScheme.primary.withValues(
                          alpha: 0.14,
                        ),
                        backgroundColor: appColors.inputFill,
                        labelStyle: textTheme.bodySmall?.copyWith(
                          color: !_isPublic
                              ? colorScheme.primary
                              : appColors.textMuted,
                          fontWeight: !_isPublic
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: !_isPublic
                              ? colorScheme.primary
                              : appColors.subtleBorder,
                        ),
                        onSelected: (_) => setState(() => _isPublic = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  text: context.l10n.saveChanges,
                  onPressed: _onSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
