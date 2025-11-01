import 'package:flutter/material.dart';

class HomeTabBar extends StatefulWidget {
  final int currentIndex;
  final int allCount;
  final int favoritesCount;
  final int categoriesCount;
  final ValueChanged<int> onTabChanged;

  const HomeTabBar({
    super.key,
    required this.currentIndex,
    required this.allCount,
    required this.favoritesCount,
    required this.categoriesCount,
    required this.onTabChanged,
  });

  @override
  State<HomeTabBar> createState() => _HomeTabBarState();
}

class _HomeTabBarState extends State<HomeTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(HomeTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Animated sliding indicator
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final startPosition = _previousIndex / 3;
              final endPosition = widget.currentIndex / 3;
              final currentPosition =
                  startPosition +
                  (endPosition - startPosition) * _animation.value;

              return Positioned(
                left:
                    currentPosition * (MediaQuery.of(context).size.width - 40),
                right:
                    (1 - currentPosition - 1 / 3) *
                    (MediaQuery.of(context).size.width - 40),
                top: 0,
                bottom: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withOpacity(0.9),
                        colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Tab buttons
          Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'All',
                  count: widget.allCount,
                  icon: Icons.all_inclusive_rounded,
                  isSelected: widget.currentIndex == 0,
                  onTap: () => widget.onTabChanged(0),
                ),
              ),
              Expanded(
                child: _TabButton(
                  label: 'Favorites',
                  count: widget.favoritesCount,
                  icon: Icons.favorite_rounded,
                  isSelected: widget.currentIndex == 1,
                  onTap: () => widget.onTabChanged(1),
                ),
              ),
              Expanded(
                child: _TabButton(
                  label: 'Categories',
                  count: widget.categoriesCount,
                  icon: Icons.category_rounded,
                  isSelected: widget.currentIndex == 2,
                  onTap: () => widget.onTabChanged(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.transparent,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? Colors.white
                    : colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurfaceVariant.withOpacity(0.7),
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : colorScheme.onSurfaceVariant.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withOpacity(0.4)
                          : colorScheme.onSurfaceVariant.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white.withOpacity(0.95)
                            : colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
