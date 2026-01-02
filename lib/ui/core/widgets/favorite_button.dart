import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:provider/provider.dart';

/// Botão de favorito reutilizável (coração)
/// Usado para marcar/desmarcar recordings e activities como favoritos
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.contentType,
    required this.contentId,
    required this.authUserId,
    this.size = 24.0,
    this.initialIsFavorite,
    this.onToggle,
    this.iconColor,
  });

  /// Tipo de conteúdo: 'recording' ou 'activity'
  final String contentType;

  /// ID do conteúdo
  final int contentId;

  /// ID do usuário autenticado (auth.users.id)
  /// O repository busca o member_id correspondente
  final String authUserId;

  /// Tamanho do ícone
  final double size;

  /// Estado inicial de favorito (opcional, para evitar query inicial)
  final bool? initialIsFavorite;

  /// Callback após toggle (retorna novo estado)
  final void Function(bool isFavorite)? onToggle;

  /// Cor customizada do ícone (opcional, usa primary do tema se não fornecida)
  final Color? iconColor;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late bool _isFavorite;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite ?? false;

    // Animação de escala para feedback visual
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Se não foi passado estado inicial, busca do banco
    if (widget.initialIsFavorite == null) {
      _loadFavoriteStatus();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteStatus() async {
    final repository = context.read<FavoritesRepository>();
    final isFavorite = await repository.isFavorite(
      authUserId: widget.authUserId,
      contentType: widget.contentType,
      contentId: widget.contentId,
    );

    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    // Animação de feedback
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Optimistic UI: atualiza imediatamente
    setState(() {
      _isFavorite = !_isFavorite;
    });

    final repository = context.read<FavoritesRepository>();
    final newState = await repository.toggleFavorite(
      authUserId: widget.authUserId,
      contentType: widget.contentType,
      contentId: widget.contentId,
    );

    // Se o resultado foi diferente do esperado, corrige
    if (mounted && newState != _isFavorite) {
      setState(() {
        _isFavorite = newState;
      });
    }

    widget.onToggle?.call(newState);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Padding(
          padding: EdgeInsets.all(widget.size * 0.15),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.of(context).secondaryText,
          ),
        ),
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        onPressed: _toggleFavorite,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: widget.size,
          minHeight: widget.size,
        ),
        iconSize: widget.size,
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
          color: widget.iconColor ?? AppTheme.of(context).primary,
          size: widget.size,
        ),
        tooltip: _isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
      ),
    );
  }
}
