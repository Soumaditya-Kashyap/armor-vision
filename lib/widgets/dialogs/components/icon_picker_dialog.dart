import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class IconPickerDialog extends StatefulWidget {
  final String? currentIconName;
  final Function(String iconName, IconData iconData) onIconSelected;

  const IconPickerDialog({
    super.key,
    this.currentIconName,
    required this.onIconSelected,
  });

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedIconName;

  // Define icon categories with authentic Iconsax icons
  static final Map<String, List<IconItem>> _iconCategories = {
    'General': [
      IconItem('label', Iconsax.tag),
      IconItem('folder', Iconsax.folder),
      IconItem('document', Iconsax.document),
      IconItem('bookmark', Iconsax.bookmark),
      IconItem('star', Iconsax.star),
      IconItem('heart', Iconsax.heart),
      IconItem('flag', Iconsax.flag),
      IconItem('shield', Iconsax.shield_tick),
      IconItem('lock', Iconsax.lock),
      IconItem('key', Iconsax.key),
      IconItem('home', Iconsax.home),
      IconItem('archive', Iconsax.archive),
    ],
    'Social & Media': [
      IconItem('people', Iconsax.people),
      IconItem('message', Iconsax.message),
      IconItem('notification', Iconsax.notification),
      IconItem('sms', Iconsax.sms),
      IconItem('call', Iconsax.call),
      IconItem('video', Iconsax.video),
      IconItem('camera', Iconsax.camera),
      IconItem('gallery', Iconsax.gallery),
      IconItem('music', Iconsax.music),
      IconItem('microphone', Iconsax.microphone),
      IconItem('headphone', Iconsax.headphone),
      IconItem('share', Iconsax.share),
    ],
    'Finance & Business': [
      IconItem('bank', Iconsax.bank),
      IconItem('wallet', Iconsax.wallet),
      IconItem('card', Iconsax.card),
      IconItem('money', Iconsax.money),
      IconItem('dollar_circle', Iconsax.dollar_circle),
      IconItem('chart', Iconsax.chart),
      IconItem('graph', Iconsax.graph),
      IconItem('trend_up', Iconsax.trend_up),
      IconItem('shop', Iconsax.shop),
      IconItem('bag', Iconsax.bag),
      IconItem('receipt', Iconsax.receipt),
      IconItem('coin', Iconsax.coin),
    ],
    'Work & Productivity': [
      IconItem('briefcase', Iconsax.briefcase),
      IconItem('clipboard', Iconsax.clipboard),
      IconItem('note', Iconsax.note),
      IconItem('task', Iconsax.task_square),
      IconItem('calendar', Iconsax.calendar),
      IconItem('timer', Iconsax.timer),
      IconItem('alarm', Iconsax.alarm),
      IconItem('edit', Iconsax.edit),
      IconItem('copy', Iconsax.copy),
      IconItem('trash', Iconsax.trash),
      IconItem('printer', Iconsax.printer),
      IconItem('scan', Iconsax.scan),
    ],
    'Entertainment': [
      IconItem('game', Iconsax.game),
      IconItem('gameboy', Iconsax.gameboy),
      IconItem('monitor', Iconsax.monitor),
      IconItem('movie', Iconsax.video_square),
      IconItem('book', Iconsax.book),
      IconItem('music_library', Iconsax.music_library_2),
      IconItem('television', Iconsax.monitor_mobbile),
      IconItem('ticket', Iconsax.ticket),
      IconItem('award', Iconsax.award),
      IconItem('gift', Iconsax.gift),
      IconItem('emoji_happy', Iconsax.emoji_happy),
      IconItem('emoji_normal', Iconsax.emoji_normal),
    ],
    'Health & Lifestyle': [
      IconItem('heart_tick', Iconsax.heart_tick),
      IconItem('activity', Iconsax.activity),
      IconItem('health', Iconsax.health),
      IconItem('hospital', Iconsax.hospital),
      IconItem('shield_cross', Iconsax.shield_cross),
      IconItem('coffee', Iconsax.coffee),
      IconItem('cup', Iconsax.cup),
      IconItem('restaurant', Iconsax.cake),
      IconItem('weight', Iconsax.weight),
      IconItem('running', Iconsax.repeate_music),
      IconItem('bicycle', Iconsax.driving),
      IconItem('moon', Iconsax.moon),
    ],
    'Travel & Places': [
      IconItem('airplane', Iconsax.airplane),
      IconItem('car', Iconsax.car),
      IconItem('bus', Iconsax.bus),
      IconItem('ship', Iconsax.ship),
      IconItem('location', Iconsax.location),
      IconItem('map', Iconsax.map),
      IconItem('global', Iconsax.global),
      IconItem('building', Iconsax.building),
      IconItem('house', Iconsax.house),
      IconItem('courthouse', Iconsax.courthouse),
      IconItem('gas_station', Iconsax.gas_station),
      IconItem('reserve', Iconsax.reserve),
    ],
    'Education & Tech': [
      IconItem('teacher', Iconsax.teacher),
      IconItem('graduation', Iconsax.status),
      IconItem('book_square', Iconsax.book_square),
      IconItem('note_text', Iconsax.note_text),
      IconItem('calculator', Iconsax.calculator),
      IconItem('code', Iconsax.code),
      IconItem('programming', Iconsax.programming_arrows),
      IconItem('cpu', Iconsax.cpu),
      IconItem('cloud', Iconsax.cloud),
      IconItem('database', Iconsax.data),
      IconItem('security_user', Iconsax.security_user),
      IconItem('wifi', Iconsax.wifi),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedIconName = widget.currentIconName;
    _tabController = TabController(length: _iconCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Iconsax.emoji_happy,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose Icon',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Select an icon for your category',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                tabAlignment: TabAlignment.start,
                labelStyle: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                tabs: _iconCategories.keys.map((category) {
                  return Tab(text: category);
                }).toList(),
              ),
            ),

            // Icon Grid
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _iconCategories.entries.map((entry) {
                  return _buildIconGrid(entry.value);
                }).toList(),
              ),
            ),

            // Footer with selected icon
            if (_selectedIconName != null) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconDataFromName(_selectedIconName!),
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Icon',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                          Text(
                            _formatIconName(_selectedIconName!),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        widget.onIconSelected(
                          _selectedIconName!,
                          _getIconDataFromName(_selectedIconName!),
                        );
                        Navigator.of(context).pop();
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconGrid(List<IconItem> icons) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final iconItem = icons[index];
        final isSelected = _selectedIconName == iconItem.name;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedIconName = iconItem.name;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                iconItem.iconData,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconDataFromName(String name) {
    for (final category in _iconCategories.values) {
      for (final icon in category) {
        if (icon.name == name) return icon.iconData;
      }
    }
    return Iconsax.tag; // Default
  }

  String _formatIconName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class IconItem {
  final String name;
  final IconData iconData;

  IconItem(this.name, this.iconData);
}
