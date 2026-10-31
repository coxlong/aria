import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/error/error_text.dart';
import '../../../core/theme/aria_colors.dart';
import '../../../core/theme/aria_tokens.dart';
import '../../../core/theme/aria_type.dart';
import '../../../core/widgets/aria_sheet.dart';
import '../../../core/widgets/aria_viewport.dart';
import '../../../domain/profile/server_profile.dart';
import '../../../domain/session/agent_connection.dart';
import '../../../l10n/app_localizations.dart';
import '../../connection/application/agent_manager.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/presentation/settings_sheet.dart';

/// What Aria looks like before it is on.
///
/// There is no connection page here: one dormant point sits in the middle of
/// the field. Touch it and Aria wakes in place; the home surface appears only
/// after the point has bloomed. Choosing which agent answers is a quiet line
/// under the point, not a list you must work through.
class ConnectPage extends ConsumerStatefulWidget {
  const ConnectPage({super.key});

  @override
  ConsumerState<ConnectPage> createState() => _ConnectPageState();
}

enum _WakePhase { idle, connecting, success, error }

class _ConnectPageState extends ConsumerState<ConnectPage> {
  String? _pickedId;
  bool _leaving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final agent = ref.watch(
      agentManagerProvider.select((state) => state.activeAgent),
    );
    final profiles = settings.profiles;
    final current =
        profiles.where((profile) => profile.id == _pickedId).firstOrNull ??
        settings.profileToConnect;

    final phase = switch (agent?.status) {
      AgentStatus.connecting => _WakePhase.connecting,
      AgentStatus.connected || AgentStatus.reconnecting => _WakePhase.success,
      AgentStatus.failed => _WakePhase.error,
      _ => _WakePhase.idle,
    };

    if (phase == _WakePhase.success) _leaveForHome();

    return AriaViewport(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _WakeTopBar(
            tone: switch (phase) {
              _WakePhase.connecting => BrandTone.warn,
              _WakePhase.success => BrandTone.quiet,
              _WakePhase.idle || _WakePhase.error => BrandTone.off,
            },
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                const AriaAura(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 64),
                  child: Center(
                    child: _WakeCore(
                      phase: phase,
                      title: switch (phase) {
                        _WakePhase.idle =>
                          current == null
                              ? l10n.connectFirstAgent
                              : l10n.connectAria,
                        _WakePhase.connecting => l10n.connectingAria,
                        _WakePhase.success => l10n.connected,
                        _WakePhase.error => l10n.connectionFailed,
                      },
                      sub: phase == _WakePhase.idle && current == null
                          ? l10n.connectFirstAgentBody
                          : null,
                      error: phase == _WakePhase.error && agent?.error != null
                          ? describeError(l10n, agent!.error!)
                          : null,
                      altLabel: current == null
                          ? (phase == _WakePhase.idle ? l10n.addAgent : null)
                          : (phase == _WakePhase.idle ||
                                    phase == _WakePhase.connecting
                                ? '${current.displayName} · ${l10n.changeAgent}'
                                : null),
                      onTap: switch (phase) {
                        _WakePhase.idle => () => _start(current),
                        _WakePhase.error => null,
                        _ => null,
                      },
                      onAlt: switch (phase) {
                        _WakePhase.connecting => _cancel,
                        _WakePhase.error => _pick,
                        _WakePhase.idle when current == null => _addAgent,
                        _WakePhase.idle => _pick,
                        _ => null,
                      },
                      altBusy: phase == _WakePhase.connecting,
                      onRetry: phase == _WakePhase.error
                          ? () => _start(current)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Holds the success bloom for a beat, then the home surface rises.
  void _leaveForHome() {
    if (_leaving) return;
    _leaving = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (mounted) context.go('/home');
      });
    });
  }

  void _start(ServerProfile? profile) {
    if (profile == null) {
      unawaited(_addAgent());
      return;
    }
    unawaited(ref.read(agentManagerProvider.notifier).connect(profile));
  }

  void _cancel() {
    final agent = ref.read(agentManagerProvider).activeAgent;
    if (agent == null) return;
    unawaited(
      ref.read(agentManagerProvider.notifier).disconnect(agent.profile.id),
    );
  }

  Future<void> _addAgent() {
    return showSettings(context, newAgent: true);
  }

  Future<void> _pick() async {
    final profiles = ref.read(settingsProvider).profiles;
    if (profiles.isEmpty) {
      await _addAgent();
      return;
    }
    if (!mounted) return;
    final settings = ref.read(settingsProvider);
    final selectedId =
        _pickedId ?? settings.activeProfileId ?? profiles.first.id;
    final chosen = await showAriaSheet<String>(
      context: context,
      builder: (context) => _AgentPicker(
        profiles: profiles,
        selectedId: selectedId,
        defaultId: settings.activeProfileId,
      ),
    );
    if (!mounted || chosen == null) return;
    if (chosen == _AgentPicker.addId) {
      await _addAgent();
      return;
    }
    setState(() => _pickedId = chosen);
    unawaited(ref.read(settingsProvider.notifier).setConnectProfile(chosen));
  }
}

class _WakeTopBar extends StatelessWidget {
  const _WakeTopBar({required this.tone});

  final BrandTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
      child: Row(
        children: <Widget>[
          AriaBrandDot(tone: tone),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context).appName,
            style: type.brand.copyWith(color: colors.ink),
          ),
          const Spacer(),
          AriaIconButton(
            icon: Icons.tune_rounded,
            label: AppLocalizations.of(context).settings,
            onTap: () => showSettings(context),
          ),
        ],
      ),
    );
  }
}

/// The point, its title, and the one quiet way to change who answers.
class _WakeCore extends StatelessWidget {
  const _WakeCore({
    required this.phase,
    required this.title,
    required this.sub,
    required this.error,
    required this.altLabel,
    required this.onTap,
    required this.onAlt,
    required this.altBusy,
    required this.onRetry,
  });

  final _WakePhase phase;
  final String title;
  final String? sub;
  final String? error;
  final String? altLabel;
  final VoidCallback? onTap;
  final VoidCallback? onAlt;
  final bool altBusy;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _WakeDot(phase: phase, onTap: onTap),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: type.headline.copyWith(
            fontSize: 26,
            height: 1.3,
            letterSpacing: -1,
            color: colors.ink,
          ),
        ),
        if (sub != null) ...<Widget>[
          const SizedBox(height: AriaSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(
              sub!,
              textAlign: TextAlign.center,
              style: type.ui.copyWith(color: colors.muted, height: 1.65),
            ),
          ),
        ],
        if (error != null) ...<Widget>[
          const SizedBox(height: AriaSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: type.small.copyWith(color: colors.ink2, height: 1.65),
            ),
          ),
        ],
        if (onRetry != null) ...<Widget>[
          const SizedBox(height: AriaSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: onRetry,
                    child: Text(AppLocalizations.of(context).relink),
                  ),
                ),
                if (onAlt != null) ...<Widget>[
                  const SizedBox(width: AriaSpacing.xs),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAlt,
                      child: Text(AppLocalizations.of(context).changeAgent),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (altLabel != null) ...<Widget>[
          const SizedBox(height: AriaSpacing.xs),
          TextButton(
            onPressed: onAlt,
            style: TextButton.styleFrom(
              foregroundColor: colors.muted,
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: AriaSpacing.sm),
              textStyle: type.small.copyWith(height: 1.4),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
            child: Text(
              altBusy ? AppLocalizations.of(context).cancel : altLabel!,
            ),
          ),
        ],
      ],
    );
  }
}

class _WakeDot extends StatelessWidget {
  const _WakeDot({required this.phase, required this.onTap});

  final _WakePhase phase;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final dormant = dark ? const Color(0xFF5B5954) : const Color(0xFFA9A8A4);
    final reduced = MediaQuery.disableAnimationsOf(context);

    final point = switch (phase) {
      _WakePhase.connecting || _WakePhase.success => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.goldFill,
          boxShadow: <BoxShadow>[
            BoxShadow(color: colors.goldSoft, spreadRadius: 4),
            BoxShadow(color: colors.goldGlow, blurRadius: 26, spreadRadius: 5),
          ],
        ),
      ),
      _WakePhase.error => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.danger,
          boxShadow: <BoxShadow>[
            BoxShadow(color: colors.dangerSoft, spreadRadius: 4),
          ],
        ),
      ),
      _WakePhase.idle => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(shape: BoxShape.circle, color: dormant),
      ),
    };

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (phase == _WakePhase.connecting) ...<Widget>[
            Positioned(
              left: -18,
              top: -18,
              right: -18,
              bottom: -18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      colors.goldSoft,
                      colors.goldSoft.withValues(alpha: 0),
                    ],
                    stops: const <double>[0, 0.68],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              right: 12,
              bottom: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.panel3),
                ),
              ),
            ),
            if (!reduced)
              const Positioned(
                left: 12,
                top: 12,
                right: 12,
                bottom: 12,
                child: Padding(
                  padding: EdgeInsets.all(1),
                  child: CircularProgressIndicator(strokeWidth: 1.2),
                ),
              ),
          ] else if (phase == _WakePhase.success) ...<Widget>[
            if (!reduced)
              const Positioned(
                left: 40,
                top: 40,
                right: 40,
                bottom: 40,
                child: _BloomRing(),
              ),
          ] else ...<Widget>[
            Positioned(
              left: 22,
              top: 22,
              right: 22,
              bottom: 22,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.panel,
                ),
              ),
            ),
          ],
          Semantics(
            button: onTap != null,
            label: AppLocalizations.of(context).connectAria,
            child: Material(
              key: const ValueKey<String>('wake-dot'),
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Center(child: point),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One ring opening outward when the connection lands.
class _BloomRing extends StatefulWidget {
  const _BloomRing();

  @override
  State<_BloomRing> createState() => _BloomRingState();
}

class _BloomRingState extends State<_BloomRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Opacity(
          opacity: 0.7 * (1 - t),
          child: Transform.scale(scale: 0.5 + 1.7 * t, child: child),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.gold),
        ),
      ),
    );
  }
}

class _AgentPicker extends StatelessWidget {
  const _AgentPicker({
    required this.profiles,
    required this.selectedId,
    required this.defaultId,
  });

  static const String addId = '__add__';

  final List<ServerProfile> profiles;
  final String? selectedId;
  final String? defaultId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AriaSheet(
      title: l10n.chooseAgent,
      onClose: () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final profile in profiles)
            _AgentChoice(
              profile: profile,
              selected: profile.id == selectedId,
              isDefault: profile.id == defaultId,
              onTap: () => Navigator.of(context).pop(profile.id),
            ),
          const SizedBox(height: AriaSpacing.xxs),
          AriaLinkButton(
            label: l10n.addAgent,
            onTap: () => Navigator.of(context).pop(addId),
          ),
        ],
      ),
      foot: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ),
    );
  }
}

class _AgentChoice extends StatelessWidget {
  const _AgentChoice({
    required this.profile,
    required this.selected,
    required this.isDefault,
    required this.onTap,
  });

  final ServerProfile profile;
  final bool selected;
  final bool isDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;
    final description = profile.description.trim();
    final detail = description.isNotEmpty ? description : profile.url;

    return Material(
      color: Colors.transparent,
      borderRadius: AriaRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AriaRadius.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            profile.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: type.chatTitle.copyWith(color: colors.ink),
                          ),
                        ),
                        if (isDefault) ...<Widget>[
                          const SizedBox(width: AriaSpacing.xs),
                          Container(
                            padding: const EdgeInsets.fromLTRB(9, 3, 9, 3),
                            decoration: BoxDecoration(
                              color: colors.goldSoft,
                              borderRadius: AriaRadius.pillAll,
                            ),
                            child: Text(
                              l10n.agentDefault,
                              style: type.tiny.copyWith(
                                color: colors.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: type.caption.copyWith(color: colors.muted),
                    ),
                  ],
                ),
              ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(left: AriaSpacing.xs),
                  child: Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: colors.gold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
