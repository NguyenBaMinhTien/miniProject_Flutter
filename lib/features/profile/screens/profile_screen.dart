// DEV 5 Scope: Auth UI, History, Profile, Audio & App Shell
import 'package:flutter/material.dart';

import '../../../audio/audio_controller.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/settings_tile.dart';
import '../widgets/stats_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.audioController,
  });

  final AudioController audioController;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _vibrationEnabled = true;

  AudioController get _audioController => widget.audioController;

  @override
  void initState() {
    super.initState();
    _audioController.addListener(_handleAudioChanged);
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioController == widget.audioController) return;

    oldWidget.audioController.removeListener(_handleAudioChanged);
    _audioController.addListener(_handleAudioChanged);
  }

  @override
  void dispose() {
    _audioController.removeListener(_handleAudioChanged);
    super.dispose();
  }

  void _handleAudioChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _setSoundEnabled(bool enabled) async {
    try {
      await _audioController.setSoundEnabled(enabled);
    } catch (_) {
      _showAudioError();
    }
  }

  Future<void> _playSoundPreview() async {
    try {
      await _audioController.playButtonTap();
    } catch (_) {
      _showAudioError();
    }
  }

  Future<void> _toggleGallopingPreview() async {
    try {
      if (_audioController.isGalloping) {
        await _audioController.stopGalloping();
      } else {
        await _audioController.startGalloping();
      }
    } catch (_) {
      _showAudioError();
    }
  }

  void _showAudioError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to play audio on this device.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will return to the login flow.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _audioController.stopGalloping();
    } catch (_) {
      // Logout navigation must not depend on platform audio availability.
    }
    if (!mounted) return;

    // TODO(DEV1-INTEGRATION):
    // Replace mock navigation with real session logout handling.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 752
                ? (constraints.maxWidth - 720) / 2
                : 16.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                28,
              ),
              children: [
                const _ProfileHeader(),
                const SizedBox(height: 28),
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                const StatsCard(
                  totalBets: 24,
                  totalWon: 10,
                  totalLost: 14,
                  winRate: 41.7,
                ),
                const SizedBox(height: 28),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: _audioController.isSoundEnabled
                            ? Icons.volume_up_outlined
                            : Icons.volume_off_outlined,
                        title: 'Sound',
                        subtitle: _audioController.isSoundEnabled
                            ? 'Race sounds are enabled'
                            : 'All race sounds are muted',
                        value: _audioController.isSoundEnabled,
                        onChanged: _setSoundEnabled,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      SettingsTile(
                        icon: Icons.vibration_rounded,
                        title: 'Vibration',
                        subtitle: 'Local preference for race feedback',
                        value: _vibrationEnabled,
                        onChanged: (enabled) {
                          setState(() => _vibrationEnabled = enabled);
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sound preview',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Check effects and the looping race sound.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _audioController.isSoundEnabled
                                      ? _playSoundPreview
                                      : null,
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: const Text('Test sound'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _audioController.isSoundEnabled
                                      ? _toggleGallopingPreview
                                      : null,
                                  icon: Icon(
                                    _audioController.isGalloping
                                        ? Icons.stop_rounded
                                        : Icons.repeat_rounded,
                                  ),
                                  label: Text(
                                    _audioController.isGalloping
                                        ? 'Stop gallop'
                                        : 'Start gallop',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log out'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // TODO(DEV1-INTEGRATION):
    // Replace mock profile details and statistics with real user data.
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: Text(
            'HR',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'race_master',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          'Member since March 2026',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
