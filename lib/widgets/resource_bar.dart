import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../utils/format_number.dart';
import 'currency_info.dart';
import 'currency_icon.dart';

class ResourceBar extends StatelessWidget {
  const ResourceBar({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final isPhone = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isPhone ? 4 : 8, vertical: isPhone ? 2 : 4),
      decoration: const BoxDecoration(
        color: Color(0xFF1a1916),
        border: Border(bottom: BorderSide(color: Color(0xFF3a3530))),
      ),
      child: Row(
        children: [
          _Res(iconWidget: const CurrencyIcon(id: 'gold', size: 15), value: game.gold, color: const Color(0xFFdaa520),
              tooltip: CurrencyInfo.gold),
          _Res(iconWidget: const CurrencyIcon(id: 'shards', size: 15), value: game.shards, color: const Color(0xFF6699ff),
              tooltip: CurrencyInfo.shards),
          _Res(iconWidget: const CurrencyIcon(id: 'zcoins', size: 14), value: game.zcoins, color: const Color(0xFFffcc44),
              tooltip: CurrencyInfo.zcoins),
          _Res(iconWidget: const CurrencyIcon(id: 'echoes', size: 15), value: game.echoes, color: const Color(0xFF44ccaa),
              tooltip: CurrencyInfo.echoes),
        ],
      ),
    );
  }
}

class _Res extends StatefulWidget {
  const _Res({this.icon, this.iconWidget, required this.value, required this.color, this.tooltip});
  final String? icon;
  final Widget? iconWidget;
  final int value;
  final Color color;
  final String? tooltip;

  @override
  State<_Res> createState() => _ResState();
}

class _ResState extends State<_Res> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  int _prev = -1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Res old) {
    super.didUpdateWidget(old);
    if (_prev >= 0 && widget.value != _prev) {
      _ctrl.forward(from: 0);
    }
    _prev = widget.value;
  }

  bool _isPhone(BuildContext ctx) => MediaQuery.of(ctx).size.width < 600;
  bool _isNarrow(BuildContext ctx) => MediaQuery.of(ctx).size.width < 380;

  @override
  Widget build(BuildContext context) {
    final phone = _isPhone(context);
    final fs = phone ? 8.0 : 10.0;
    final content = AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.iconWidget ?? Text(widget.icon ?? '', style: TextStyle(fontSize: fs)),
            if (!_isNarrow(context)) ...[
              const SizedBox(width: 2),
              Text(fmtNum(widget.value),
                  style: TextStyle(
                    fontSize: fs,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  )),
            ],
          ],
        ),
      ),
    );
    return Expanded(
      child: widget.tooltip != null
          ? Tooltip(message: widget.tooltip!, child: content)
          : content,
    );
  }
}
