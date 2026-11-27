import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../bloc/upload_bloc.dart';
import '../bloc/upload_event.dart';
import '../bloc/upload_state.dart';
import '../widgets/my_songs_list_view.dart';

class UploadMusicPage extends StatelessWidget {
  const UploadMusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasBloc = false;
    try {
      context.read<UploadBloc>();
      hasBloc = true;
    } catch (_) {
      hasBloc = false;
    }

    if (hasBloc) {
      return const _UploadMusicView();
    }

    if (!sl.isRegistered<UploadBloc>()) {
      initUploadDependencies();
    }

    return BlocProvider<UploadBloc>(
      create: (_) => sl<UploadBloc>()..add(const LoadMySongsRequested()),
      child: const _UploadMusicView(),
    );
  }
}

class _UploadMusicView extends StatefulWidget {
  const _UploadMusicView();

  @override
  State<_UploadMusicView> createState() => _UploadMusicViewState();
}

class _UploadMusicViewState extends State<_UploadMusicView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();

  String? _selectedAudioPath;
  Uint8List? _selectedAudioBytes;
  String? _selectedAudioFileName;
  String? _selectedAudioFileSize;

  String? _selectedCoverPath;
  Uint8List? _selectedCoverBytes;
  String? _selectedCoverFileName;

  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  Future<void> _onPickAudio() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac', 'flac', 'm4a'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        final sizeBytes = file.lengthSync() ?? bytes.length;
        setState(() {
          _selectedAudioPath = file.path;
          _selectedAudioBytes = bytes;
          _selectedAudioFileName = file.name;
          _selectedAudioFileSize =
              '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
          if (_titleController.text.isEmpty) {
            _titleController.text = file.name.split('.').first;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _onPickCover() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedCoverPath = file.path;
          _selectedCoverBytes = bytes;
          _selectedCoverFileName = file.name;
        });
      }
    } catch (_) {}
  }

  void _onUpload() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final colorScheme = context.colorScheme;
    if (_selectedAudioFileName == null &&
        _selectedAudioPath == null &&
        _selectedAudioBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.pleaseSelectAudioFile,
            style: TextStyle(color: colorScheme.onError),
          ),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    context.read<UploadBloc>().add(
      UploadSongSubmitted(
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        album: _albumController.text.trim().isNotEmpty
            ? _albumController.text.trim()
            : null,
        visibility: _isPublic ? 'PUBLIC' : 'PRIVATE',
        audioPath: _selectedAudioPath,
        audioBytes: _selectedAudioBytes,
        audioFileName: _selectedAudioFileName,
        coverPath: _selectedCoverPath,
        coverBytes: _selectedCoverBytes,
        coverFileName: _selectedCoverFileName,
      ),
    );
  }

  void _resetUploadForm() {
    _titleController.clear();
    _albumController.clear();
    setState(() {
      _selectedAudioPath = null;
      _selectedAudioBytes = null;
      _selectedAudioFileName = null;
      _selectedAudioFileSize = null;
      _selectedCoverPath = null;
      _selectedCoverBytes = null;
      _selectedCoverFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return BlocConsumer<UploadBloc, UploadState>(
      listener: (context, state) {
        if (state is UploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: appColors.onSuccess),
              ),
              backgroundColor: appColors.success,
            ),
          );
          _resetUploadForm();
          _tabController.animateTo(1);
        } else if (state is SongOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is UploadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: colorScheme.onError),
              ),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final bool isUploading = state is UploadInProgress;
        final double uploadProgress = state is UploadInProgress
            ? state.progress
            : 0.0;
        final bool isLoadingList = state is MySongsLoading;

        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          appBar: AppTopBar(
            showBackButton: false,
            title: context.l10n.uploadMusic,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: context.l10n.uploadNewSong),
                Tab(text: context.l10n.myUploadedSongs),
              ],
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg + AppSpacing.xs,
                    vertical: AppSpacing.lg,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.audioFile,
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm + 2),
                            AppCard(
                              showBorder: true,
                              color: appColors.cardSurface,
                              borderRadius: AppRadius.lg,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: AppSpacing.xl,
                              ),
                              onTap: isUploading ? null : _onPickAudio,
                              semanticLabel: context.l10n.chooseAudioFile,
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: appColors.inputFill,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                        border: Border.all(
                                          color: appColors.subtleBorder,
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        _selectedAudioFileName != null
                                            ? Icons.check_rounded
                                            : Icons.cloud_upload_outlined,
                                        size: 22,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      _selectedAudioFileName ??
                                          context.l10n.chooseAudioFile,
                                      textAlign: TextAlign.center,
                                      style: textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      _selectedAudioFileSize != null
                                          ? context.l10n.fileSize(
                                              _selectedAudioFileSize!,
                                            )
                                          : context.l10n.supportedAudioFormats,
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: appColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppCard(
                              showBorder: true,
                              borderRadius: AppRadius.lg,
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: AppSpacing.sm,
                                      runSpacing: AppSpacing.xs,
                                      children: [
                                        Text(
                                          context.l10n.coverImage,
                                          style: textTheme.titleMedium,
                                        ),
                                        TextButton.icon(
                                          onPressed: isUploading
                                              ? null
                                              : _onPickCover,
                                          icon: Icon(
                                            Icons.image_rounded,
                                            size: 18,
                                            color: colorScheme.primary,
                                          ),
                                          label: Text(
                                            _selectedCoverFileName != null
                                                ? context.l10n.changeCoverImage
                                                : context.l10n.chooseCoverImage,
                                            style: textTheme.labelLarge
                                                ?.copyWith(
                                                  color: colorScheme.primary,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedCoverFileName != null) ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: appColors.inputFill,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                        border: Border.all(
                                          color: appColors.subtleBorder,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm,
                                      ),
                                      child: Row(
                                        children: [
                                          if (_selectedCoverBytes != null)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.sm,
                                                  ),
                                              child: Image.memory(
                                                _selectedCoverBytes!,
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: appColors.cardSurface,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.sm,
                                                    ),
                                                border: Border.all(
                                                  color: appColors.subtleBorder,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.photo_outlined,
                                                color: colorScheme.primary,
                                                size: 20,
                                              ),
                                            ),
                                          const SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: Text(
                                              _selectedCoverFileName!,
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: context.l10n.cancel,
                                            icon: Icon(
                                              Icons.close_rounded,
                                              size: 18,
                                              color: appColors.textMuted,
                                            ),
                                            onPressed: () => setState(() {
                                              _selectedCoverPath = null;
                                              _selectedCoverBytes = null;
                                              _selectedCoverFileName = null;
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  Divider(
                                    height: AppSpacing.xl,
                                    color: appColors.subtleBorder,
                                  ),
                                  Text(
                                    context.l10n.songInfo,
                                    style: textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  AppTextField(
                                    label: context.l10n.songTitle,
                                    controller: _titleController,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return context
                                            .l10n
                                            .pleaseEnterSongTitle;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md + 2),
                                  AppTextField(
                                    label: context.l10n.artist,
                                    controller: _artistController,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: AppSpacing.md + 2),
                                  AppTextField(
                                    label: context.l10n.albumOptional,
                                    controller: _albumController,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  Divider(
                                    height: AppSpacing.xl,
                                    color: appColors.subtleBorder,
                                  ),
                                  Text(
                                    context.l10n.visibility,
                                    style: textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.sm + 2),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _VisibilityChip(
                                          icon: Icons.public_rounded,
                                          label: context.l10n.public,
                                          isSelected: _isPublic,
                                          onTap: () =>
                                              setState(() => _isPublic = true),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: _VisibilityChip(
                                          icon: Icons.lock_outline_rounded,
                                          label: context.l10n.private,
                                          isSelected: !_isPublic,
                                          onTap: () =>
                                              setState(() => _isPublic = false),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            if (isUploading) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                                child: LinearProgressIndicator(
                                  value: uploadProgress > 0
                                      ? uploadProgress
                                      : null,
                                  backgroundColor: appColors.inputFill,
                                  color: colorScheme.primary,
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm + 2),
                              Center(
                                child: Text(
                                  uploadProgress > 0
                                      ? context.l10n.uploadingWithPercent(
                                          (uploadProgress * 100).toInt(),
                                        )
                                      : context.l10n.uploading,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: appColors.textMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                            AppPrimaryButton(
                              text: isUploading
                                  ? context.l10n.loading
                                  : context.l10n.submitUpload,
                              isLoading: isUploading,
                              onPressed: _onUpload,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: MySongsListView(
                        songs: state.songs,
                        isLoading: isLoadingList,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VisibilityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VisibilityChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appColors = context.appColors;
    final textTheme = context.textTheme;
    final radius = BorderRadius.circular(AppRadius.md);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: isSelected ? appColors.inputFill : appColors.cardSurface,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : appColors.subtleBorder,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? colorScheme.primary : appColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onSurface
                          : appColors.textMuted,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
