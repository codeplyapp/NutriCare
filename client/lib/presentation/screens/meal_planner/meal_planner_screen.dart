import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/nutrition_provider.dart';
import 'package:nutricare/presentation/providers/iot_provider.dart';
import 'package:nutricare/presentation/widgets/animated_macro_bar.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/app_text_field.dart';
import 'package:nutricare/presentation/widgets/fade_slide_entrance.dart';
import 'package:nutricare/presentation/widgets/iot_pulse_radar.dart';

class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatMealType(String rawType) {
    switch (rawType.toLowerCase()) {
      case 'sarapan':
        return 'Sarapan';
      case 'makan_siang':
        return 'Makan Siang';
      case 'makan_malam':
        return 'Makan Malam';
      case 'snack':
        return 'Camilan';
      case 'minuman':
        return 'Minuman';
      default:
        return rawType
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '')
            .join(' ');
    }
  }

  IconData _getMealIcon(String rawType) {
    switch (rawType.toLowerCase()) {
      case 'sarapan':
        return Icons.wb_sunny_rounded;
      case 'makan_siang':
        return Icons.restaurant_rounded;
      case 'makan_malam':
        return Icons.nightlight_round;
      case 'snack':
        return Icons.cookie_rounded;
      case 'minuman':
        return Icons.water_drop_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  Color _getMealColor(String rawType) {
    switch (rawType.toLowerCase()) {
      case 'sarapan':
        return const Color(0xFFD97706);
      case 'makan_siang':
        return AppColors.frozenWater800;
      case 'makan_malam':
        return AppColors.darkAmethyst700;
      case 'snack':
        return const Color(0xFFEA580C);
      case 'minuman':
        return AppColors.turquoise700;
      default:
        return AppColors.primaryHover;
    }
  }

  Color _getMealBgColor(String rawType) {
    switch (rawType.toLowerCase()) {
      case 'sarapan':
        return const Color(0xFFFEF3C7);
      case 'makan_siang':
        return AppColors.frozenWater100;
      case 'makan_malam':
        return AppColors.darkAmethyst100;
      case 'snack':
        return const Color(0xFFFFEDD5);
      case 'minuman':
        return AppColors.turquoise100;
      default:
        return AppColors.frozenWater50;
    }
  }

  void _showAddMealModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final protCtrl = TextEditingController(text: '0');
    final carbCtrl = TextEditingController(text: '0');
    final fatCtrl = TextEditingController(text: '0');
    final waterCtrl = TextEditingController(text: '0');
    String mealType = 'sarapan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Catat Asupan Gizi Baru',
                      style: AppTypography.display.copyWith(fontSize: 20, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Nama Makanan / Minuman',
                  hint: 'cth: Nasi Goreng Telur, Jus Alpukat',
                  controller: nameCtrl,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Waktu Makan', style: AppTypography.captionStrong.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  initialValue: mealType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                    border: OutlineInputBorder(borderRadius: AppShapes.input),
                  ),
                  selectedItemBuilder: (context) => const [
                    Text('Sarapan', overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('Makan Siang', overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('Makan Malam', overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('Snack / Camilan', overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('Minuman / Air Putih', overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                  items: const [
                    DropdownMenuItem(value: 'sarapan', child: Text('Sarapan', overflow: TextOverflow.ellipsis, maxLines: 1)),
                    DropdownMenuItem(value: 'makan_siang', child: Text('Makan Siang', overflow: TextOverflow.ellipsis, maxLines: 1)),
                    DropdownMenuItem(value: 'makan_malam', child: Text('Makan Malam', overflow: TextOverflow.ellipsis, maxLines: 1)),
                    DropdownMenuItem(value: 'snack', child: Text('Snack / Camilan', overflow: TextOverflow.ellipsis, maxLines: 1)),
                    DropdownMenuItem(value: 'minuman', child: Text('Minuman / Air Putih', overflow: TextOverflow.ellipsis, maxLines: 1)),
                  ],
                  onChanged: (val) => setModalState(() => mealType = val ?? 'sarapan'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Kalori (kcal)',
                        hint: '350',
                        controller: calCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        label: 'Air (ml)',
                        hint: '250',
                        controller: waterCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Protein (g)',
                        hint: '15',
                        controller: protCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: AppTextField(
                        label: 'Karbo (g)',
                        hint: '45',
                        controller: carbCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: AppTextField(
                        label: 'Lemak (g)',
                        hint: '8',
                        controller: fatCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  text: 'Simpan ke Catatan Harian',
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && calCtrl.text.isNotEmpty) {
                      ref.read(nutritionProvider.notifier).addMealLog(
                            itemName: nameCtrl.text.trim(),
                            mealType: mealType,
                            calorie: double.tryParse(calCtrl.text) ?? 0,
                            proteinG: double.tryParse(protCtrl.text) ?? 0,
                            carbG: double.tryParse(carbCtrl.text) ?? 0,
                            fatG: double.tryParse(fatCtrl.text) ?? 0,
                            waterMl: double.tryParse(waterCtrl.text) ?? 0,
                          );
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nutritionState = ref.watch(nutritionProvider);
    final iotState = ref.watch(iotProvider);
    final summary = nutritionState.summary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutri Meal'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.captionStrong.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTypography.captionStrong.copyWith(fontWeight: FontWeight.w400),
          tabs: const [
            Tab(
              icon: Icon(Icons.restaurant_rounded, size: 20),
              text: 'Log Makanan',
            ),
            Tab(
              icon: Icon(Icons.watch_rounded, size: 20),
              text: 'Sinkronisasi IoT',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Food Log
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeSlideEntrance(
                        index: 0,
                        child: AppButton(
                          text: 'Tambah Log Makanan Baru',
                          icon: Icons.add_rounded,
                          variant: AppButtonVariant.primary,
                          onPressed: () => _showAddMealModal(context),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Macronutrient Summary Card
                      if (summary != null)
                        FadeSlideEntrance(
                          index: 1,
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Ringkasan Makronutrisi',
                                      style: AppTypography.display.copyWith(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.frozenWater100,
                                        borderRadius: AppShapes.pill,
                                      ),
                                      child: Text(
                                        '${summary.currentCalorie.toInt()} / ${summary.targetCalorie.toInt()} kcal',
                                        style: AppTypography.finePrint.copyWith(
                                          color: AppColors.frozenWater800,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AnimatedMacroBar(
                                  label: 'Protein',
                                  currentValue: summary.currentProteinG,
                                  targetValue: summary.targetProteinG > 0 ? summary.targetProteinG : 85,
                                  unit: 'g',
                                  color: AppColors.frozenWater700,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                AnimatedMacroBar(
                                  label: 'Karbohidrat',
                                  currentValue: summary.currentCarbG,
                                  targetValue: summary.targetCarbG > 0 ? summary.targetCarbG : 260,
                                  unit: 'g',
                                  color: AppColors.richCerulean600,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                AnimatedMacroBar(
                                  label: 'Lemak Sehat',
                                  currentValue: summary.currentFatG,
                                  targetValue: summary.targetFatG > 0 ? summary.targetFatG : 60,
                                  unit: 'g',
                                  color: const Color(0xFFE59819),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                AnimatedMacroBar(
                                  label: 'Air Mineral',
                                  currentValue: summary.currentWaterMl,
                                  targetValue: summary.targetWaterMl > 0 ? summary.targetWaterMl : 2200,
                                  unit: 'ml',
                                  color: AppColors.turquoise700,
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      // Food Log History Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Riwayat Makan Hari Ini',
                            style: AppTypography.display.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (summary != null && summary.recentLogs.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfacePearl,
                                borderRadius: AppShapes.pill,
                              ),
                              child: Text(
                                '${summary.recentLogs.length} Asupan',
                                style: AppTypography.finePrint.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      if (summary?.recentLogs.isEmpty ?? true)
                        AppCard(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.restaurant_menu_rounded,
                                    size: 40,
                                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada riwayat asupan hari ini.',
                                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tekan tombol di atas untuk mencatat makanan Anda.',
                                    style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ...summary!.recentLogs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final log = entry.value;
                          final mealBg = _getMealBgColor(log.mealType);
                          final mealColor = _getMealColor(log.mealType);
                          final mealIcon = _getMealIcon(log.mealType);
                          final formattedType = _formatMealType(log.mealType);

                          return FadeSlideEntrance(
                            index: index + 2,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: AppCard(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: mealBg,
                                        borderRadius: AppShapes.input,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          mealIcon,
                                          color: mealColor,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            log.itemName,
                                            style: AppTypography.captionStrong.copyWith(
                                              color: AppColors.textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: formattedType,
                                                  style: AppTypography.finePrint.copyWith(
                                                    color: mealColor,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ' • ${log.calorie.toInt()} kcal',
                                                  style: AppTypography.finePrint.copyWith(
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                if (log.waterMl > 0)
                                                  TextSpan(
                                                    text: ' • Air: ${log.waterMl.toInt()}ml',
                                                    style: AppTypography.finePrint.copyWith(
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'P: ${log.proteinG.toInt()}g  •  K: ${log.carbG.toInt()}g  •  L: ${log.fatG.toInt()}g',
                                            style: AppTypography.finePrint.copyWith(
                                              color: AppColors.inkMuted48,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfacePearl,
                                        borderRadius: AppShapes.xs,
                                      ),
                                      child: Text(
                                        '+${log.calorie.toInt()}',
                                        style: AppTypography.finePrint.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                      // Floating Dock Bottom Clearance
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Tab 2: IoT Pairing & Status
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Animated Radar Scanner Section
                      FadeSlideEntrance(
                        index: 0,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            child: Column(
                              children: [
                                IoTPulseRadar(
                                  isScanning: iotState.isPairing || iotState.devices.isNotEmpty,
                                  color: AppColors.primary,
                                  size: 110,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  iotState.isPairing
                                      ? 'Memindai perangkat sekitar via BLE...'
                                      : 'Sinkronisasi IoT Real-time Aktif',
                                  style: AppTypography.captionStrong.copyWith(
                                    color: iotState.isPairing ? AppColors.secondary : AppColors.primaryHover,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideEntrance(
                        index: 1,
                        child: AppCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.frozenWater100,
                                      borderRadius: AppShapes.input,
                                    ),
                                    child: const Icon(Icons.watch_rounded, color: AppColors.frozenWater800, size: 28),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Perangkat Jam Pintar Terhubung',
                                          style: AppTypography.captionStrong.copyWith(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Sinkronisasi otomatis evaluasi gizi via MQTT / Bluetooth LE',
                                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Divider(color: AppColors.border),
                              const SizedBox(height: AppSpacing.sm),
                              if (iotState.devices.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                  child: Center(
                                    child: Text(
                                      'Belum ada jam pintar yang terhubung.',
                                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ),
                                )
                              else
                                ...iotState.devices.map((d) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfacePearl,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.bluetooth_connected_rounded, color: AppColors.primary, size: 20),
                                      ),
                                      title: Text(
                                        d.deviceName,
                                        style: AppTypography.captionStrong.copyWith(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Baterai: ${d.batteryPct}% • ID: ${d.deviceId}',
                                        style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.frozenWater100,
                                          borderRadius: AppShapes.pill,
                                        ),
                                        child: Text(
                                          'Terhubung',
                                          style: AppTypography.finePrint.copyWith(
                                            color: AppColors.frozenWater800,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeSlideEntrance(
                        index: 2,
                        child: AppButton(
                          text: 'Hubungkan Jam Tangan Pintar Baru',
                          icon: Icons.add_link_rounded,
                          variant: AppButtonVariant.secondary,
                          isLoading: iotState.isPairing,
                          onPressed: () {
                            ref.read(iotProvider.notifier).pairNewDevice('Apple Watch / Wear OS', 'smartwatch');
                          },
                        ),
                      ),

                      // Floating Dock Bottom Clearance
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
