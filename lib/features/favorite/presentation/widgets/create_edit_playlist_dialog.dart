import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/playlist_entity.dart';
import '../bloc/playlist_bloc.dart';
import '../bloc/playlist_event.dart';

class CreateEditPlaylistDialog extends StatefulWidget {
  final PlaylistEntity? playlist;

  const CreateEditPlaylistDialog({super.key, this.playlist});

  static Future<void> show(BuildContext context, {PlaylistEntity? playlist}) {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<PlaylistBloc>(),
        child: CreateEditPlaylistDialog(playlist: playlist),
      ),
    );
  }

  @override
  State<CreateEditPlaylistDialog> createState() =>
      _CreateEditPlaylistDialogState();
}

class _CreateEditPlaylistDialogState extends State<CreateEditPlaylistDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlist?.name ?? '');
    _descController = TextEditingController(
      text: widget.playlist?.description ?? '',
    );
    _isPublic = widget.playlist?.isPublic ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onSave() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final visibility = _isPublic ? 'PUBLIC' : 'PRIVATE';

    if (widget.playlist == null) {
      context.read<PlaylistBloc>().add(
        CreatePlaylistSubmitted(
          name: name,
          description: desc.isNotEmpty ? desc : null,
          visibility: visibility,
        ),
      );
    } else {
      context.read<PlaylistBloc>().add(
        UpdatePlaylistSubmitted(
          playlistId: widget.playlist!.id,
          name: name,
          description: desc.isNotEmpty ? desc : null,
          visibility: visibility,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.playlist != null;
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

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
                      isEditing
                          ? Icons.edit_note_rounded
                          : Icons.playlist_add_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        isEditing
                            ? context.l10n.editPlaylist
                            : context.l10n.createPlaylist,
                        style: textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: context.l10n.playlistNameRequired,
                  hint: context.l10n.playlistNameHint,
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.playlistNameRequiredError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: context.l10n.playlistDescOptional,
                  hint: context.l10n.playlistDescHint,
                  controller: _descController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onSave(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md + 2,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.inputFill,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: appColors.subtleBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isPublic
                            ? Icons.public_rounded
                            : Icons.lock_outline_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm + 2),
                      Expanded(
                        child: Text(
                          _isPublic
                              ? context.l10n.publicVisibility
                              : context.l10n.privateVisibility,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      Switch(
                        value: _isPublic,
                        onChanged: (val) => setState(() => _isPublic = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                        text: context.l10n.cancel,
                        isSecondary: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppPrimaryButton(
                        text: isEditing
                            ? context.l10n.save
                            : context.l10n.createNew,
                        onPressed: _onSave,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
