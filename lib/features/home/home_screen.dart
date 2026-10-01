import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_env.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/utils/media_url_helper.dart';
import '../../data/models/crop_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/video_guide_model.dart';
import '../../data/models/advisory_model.dart';
import '../../data/repositories/catalog_repository.dart';
import '../language/language_select_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Main view switcher: 'products' is primary per customer requirement
  String _activeTab = 'products'; // 'products' or 'crops'
  String _selectedProductCategory = 'ALL';
  String _selectedCropCategory = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    final phone = AppEnv.farmerHelpline;
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Helpline: $phone'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Helpline: $phone'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropsAsync = ref.watch(cropsProvider);
    final productsAsync = ref.watch(productsProvider);
    final videosAsync = ref.watch(videoGuidesProvider);
    final advisoriesAsync = ref.watch(advisoriesProvider);
    final langCode = ref.watch(localeProvider).languageCode;
    final l10n = context.l10n;

    final isProductsTab = _activeTab == 'products';

    final allProducts = productsAsync.value ?? [];
    final filteredProducts = _filterProducts(allProducts, langCode);

    final allCrops = cropsAsync.value ?? [];
    final filteredCrops = _filterCrops(allCrops, langCode);

    final headerTitle = isProductsTab
        ? _getSelectedProductCategoryTitle(l10n, langCode)
        : _getSelectedCropCategoryTitle(l10n, langCode);

    final countText = isProductsTab
        ? (productsAsync.isLoading
              ? '...'
              : _getProductsCountText(filteredProducts.length, langCode))
        : (cropsAsync.isLoading
              ? '...'
              : _getCropsCountText(filteredCrops.length, langCode));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onPrimary,
              ),
            ),
            Text(
              l10n.appSubtitle,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFFC7E6CD),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_in_talk_rounded),
            tooltip: AppEnv.farmerHelpline,
            onPressed: () => _makePhoneCall(context),
          ),
          IconButton(
            icon: const Icon(Icons.translate_rounded),
            tooltip: l10n.changeLanguage,
            onPressed: () => LanguageSelectSheet.show(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(cropsProvider);
          ref.invalidate(productsProvider);
          ref.invalidate(videoGuidesProvider);
          ref.invalidate(advisoriesProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Bar & Primary Section Switcher
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Input Box
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: l10n.searchHint,
                          hintStyle: AppTypography.caption.copyWith(
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Primary Tab Segment: Products vs Crops
                    _buildPrimarySegmentSwitch(l10n),
                    const SizedBox(height: 12),

                    // Horizontal Category Chips for Selected Tab
                    if (isProductsTab)
                      _buildProductCategoryChips(l10n, langCode)
                    else
                      _buildCropCategoryChips(l10n, langCode),
                  ],
                ),
              ),
            ),

            // Agricultural Advisories Banner
            SliverToBoxAdapter(
              child: advisoriesAsync.when(
                data: (advisories) =>
                    _buildAdvisoryBanner(advisories, langCode, l10n),
                loading: () => _buildAdvisoryShimmer(),
                error: (err, stack) => const SizedBox.shrink(),
              ),
            ),

            // Section Header (Dynamic Title & Reactive Item Count)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      headerTitle,
                      style: AppTypography.title.copyWith(fontSize: 18),
                    ),
                    Text(countText, style: AppTypography.caption),
                  ],
                ),
              ),
            ),

            // Product Cards OR Crop Cards based on active tab
            if (isProductsTab)
              productsAsync.when(
                data: (products) {
                  final filtered = _filterProducts(products, langCode);
                  if (filtered.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            l10n.noDataFound,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = filtered[index];
                        return _buildProductCard(
                          context,
                          product,
                          langCode,
                          l10n,
                        );
                      }, childCount: filtered.length),
                    ),
                  );
                },
                loading: () => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCardShimmer(),
                      childCount: 3,
                    ),
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err')),
                ),
              )
            else
              cropsAsync.when(
                data: (crops) {
                  final filtered = _filterCrops(crops, langCode);
                  if (filtered.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            l10n.noDataFound,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final crop = filtered[index];
                        return _buildCropCard(context, crop, langCode, l10n);
                      }, childCount: filtered.length),
                    ),
                  );
                },
                loading: () => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCardShimmer(),
                      childCount: 3,
                    ),
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err')),
                ),
              ),

            // Video Guides Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.ondemand_video_rounded,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.videoGuides,
                      style: AppTypography.title.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            // Video Guides List
            videosAsync.when(
              data: (videos) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final video = videos[index];
                      return _buildVideoCard(context, video, langCode, l10n);
                    }, childCount: videos.length),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildVideoCardShimmer(),
                    childCount: 2,
                  ),
                ),
              ),
              error: (err, stack) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Farmer Helpline Call Footer (Interactive 1-Tap Dialing)
            SliverToBoxAdapter(
              child: InkWell(
                onTap: () => _makePhoneCall(context),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryLight,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.farmerHelpline,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.callToOrder,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.primary),
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

  // Primary Segment Switch: Products & Medicines vs Crop Library
  Widget _buildPrimarySegmentSwitch(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (_activeTab != 'products') {
                  setState(() {
                    _activeTab = 'products';
                  });
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _activeTab == 'products'
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.science_rounded,
                      size: 16,
                      color: _activeTab == 'products'
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.products,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _activeTab == 'products'
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                if (_activeTab != 'crops') {
                  setState(() {
                    _activeTab = 'crops';
                  });
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _activeTab == 'crops'
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.grass_rounded,
                      size: 16,
                      color: _activeTab == 'crops'
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.crops,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _activeTab == 'crops'
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Product Category Filter Chips
  Widget _buildProductCategoryChips(AppLocalizations l10n, String langCode) {
    final categories = [
      {'key': 'ALL', 'label': l10n.allProducts},
      {'key': 'Insecticide', 'label': l10n.insecticides},
      {'key': 'Fungicide', 'label': l10n.fungicides},
      {'key': 'Herbicide', 'label': l10n.herbicides},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedProductCategory == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat['label']!),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedProductCategory = cat['key']!;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // Crop Category Filter Chips
  Widget _buildCropCategoryChips(AppLocalizations l10n, String langCode) {
    final categories = [
      {'key': 'ALL', 'label': l10n.allCrops},
      {'key': 'Rabi', 'label': l10n.rabiSeason},
      {'key': 'Kharif', 'label': l10n.kharifSeason},
      {
        'key': 'Cereal',
        'label': langCode == 'hi'
            ? 'अनाज (Cereals)'
            : (langCode == 'pa' ? 'ਅਨਾਜ (Cereals)' : 'Cereals'),
      },
      {
        'key': 'Oilseed',
        'label': langCode == 'hi'
            ? 'तिलहन (Oilseeds)'
            : (langCode == 'pa' ? 'ਤੇਲ ਬੀਜ (Oilseeds)' : 'Oilseeds'),
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCropCategory == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat['label']!),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedCropCategory = cat['key']!;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getSelectedProductCategoryTitle(
    AppLocalizations l10n,
    String langCode,
  ) {
    if (_searchQuery.isNotEmpty) {
      if (langCode == 'hi') return 'खोज परिणाम';
      if (langCode == 'pa') return 'ਖੋਜ ਨਤੀਜੇ';
      return 'Search Results';
    }
    switch (_selectedProductCategory) {
      case 'Insecticide':
        return l10n.insecticides;
      case 'Fungicide':
        return l10n.fungicides;
      case 'Herbicide':
        return l10n.herbicides;
      case 'ALL':
      default:
        return l10n.allProducts;
    }
  }

  String _getProductsCountText(int count, String langCode) {
    if (langCode == 'hi') {
      return count == 1 ? '1 उत्पाद उपलब्ध' : '$count उत्पाद उपलब्ध';
    }
    if (langCode == 'pa') {
      return count == 1 ? '1 ਉਤਪਾਦ ਉਪਲਬਧ' : '$count ਉਤਪਾਦ ਉਪਲਬਧ';
    }
    return count == 1 ? '1 Product Available' : '$count Products Available';
  }

  String _getSelectedCropCategoryTitle(AppLocalizations l10n, String langCode) {
    if (_searchQuery.isNotEmpty) {
      if (langCode == 'hi') return 'खोज परिणाम';
      if (langCode == 'pa') return 'ਖੋਜ ਨਤੀਜੇ';
      return 'Search Results';
    }
    switch (_selectedCropCategory) {
      case 'Rabi':
        return l10n.rabiSeason;
      case 'Kharif':
        return l10n.kharifSeason;
      case 'Cereal':
        if (langCode == 'hi') return 'अनाज फसलें (Cereals)';
        if (langCode == 'pa') return 'ਅਨਾਜ ਫ਼ਸਲਾਂ (Cereals)';
        return 'Cereal Crops';
      case 'Oilseed':
        if (langCode == 'hi') return 'तिलहन फसलें (Oilseeds)';
        if (langCode == 'pa') return 'ਤੇਲ ਬੀਜ ਫ਼ਸਲਾਂ (Oilseeds)';
        return 'Oilseed Crops';
      case 'ALL':
      default:
        return l10n.allCrops;
    }
  }

  String _getCropsCountText(int count, String langCode) {
    if (langCode == 'hi') {
      return count == 1 ? '1 फसल उपलब्ध' : '$count फसलें उपलब्ध';
    }
    if (langCode == 'pa') {
      return count == 1 ? '1 ਫ਼ਸਲ ਉਪਲਬਧ' : '$count ਫ਼ਸਲਾਂ ਉਪਲਬਧ';
    }
    return count == 1 ? '1 Crop Available' : '$count Crops Available';
  }

  List<ProductModel> _filterProducts(List<ProductModel> list, String langCode) {
    return list.where((product) {
      if (_selectedProductCategory != 'ALL' &&
          product.category.toLowerCase() !=
              _selectedProductCategory.toLowerCase()) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final name = product.getName(langCode).toLowerCase();
        final tech = product.technicalName.toLowerCase();
        final pests = product.getTargetPests(langCode).toLowerCase();
        final enName = (product.name['en'] ?? '').toLowerCase();
        final hiName = (product.name['hi'] ?? '').toLowerCase();
        final paName = (product.name['pa'] ?? '').toLowerCase();

        return name.contains(q) ||
            tech.contains(q) ||
            pests.contains(q) ||
            enName.contains(q) ||
            hiName.contains(q) ||
            paName.contains(q);
      }

      return true;
    }).toList();
  }

  List<CropModel> _filterCrops(List<CropModel> list, String langCode) {
    return list.where((crop) {
      if (_selectedCropCategory == 'Rabi' && crop.season != 'Rabi') {
        return false;
      }
      if (_selectedCropCategory == 'Kharif' && crop.season != 'Kharif') {
        return false;
      }
      if (_selectedCropCategory == 'Cereal' && crop.category != 'Cereal') {
        return false;
      }
      if (_selectedCropCategory == 'Oilseed' && crop.category != 'Oilseed') {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final name = crop.getName(langCode).toLowerCase();
        final sci = crop.scientificName.toLowerCase();
        final enName = (crop.name['en'] ?? '').toLowerCase();
        final hiName = (crop.name['hi'] ?? '').toLowerCase();
        final paName = (crop.name['pa'] ?? '').toLowerCase();

        return name.contains(q) ||
            sci.contains(q) ||
            enName.contains(q) ||
            hiName.contains(q) ||
            paName.contains(q);
      }

      return true;
    }).toList();
  }

  // Product Card with technical formula, dosage, pack sizes, and 1-tap call
  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    String langCode,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/product/${product.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with ImageKit transform and strict memCache enforcement
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  OptimizedNetworkImage(
                    imageUrl: product.imageUrl,
                    height: 150,
                    width: double.infinity,
                    memCacheWidth: 500,
                    memCacheHeight: 300,
                    fit: BoxFit.cover,
                  ),
                  // Category Badge Overlay
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(180),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getCategoryChipLabel(product.category, l10n),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.getName(langCode),
                          style: AppTypography.title.copyWith(fontSize: 17),
                        ),
                      ),
                      if (product.isOriginal)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Genuine',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.technicalName,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.getTargetPests(langCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Key Product Specs Row (Dosage & Rate / Call action)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dosagePerAcre,
                              style: AppTypography.caption,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.getDosagePerAcre(langCode),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 1-Tap Call Order Button
                      OutlinedButton.icon(
                        onPressed: () => _makePhoneCall(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: const Icon(Icons.call, size: 14),
                        label: const Text(
                          '7355555441',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
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
    );
  }

  String _getCategoryChipLabel(String category, AppLocalizations l10n) {
    switch (category.toLowerCase()) {
      case 'insecticide':
        return l10n.insecticides;
      case 'fungicide':
        return l10n.fungicides;
      case 'herbicide':
        return l10n.herbicides;
      default:
        return category;
    }
  }

  Widget _buildCropCard(
    BuildContext context,
    CropModel crop,
    String langCode,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/crop/${crop.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with ImageKit transform and strict memCache enforcement
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  OptimizedNetworkImage(
                    imageUrl: crop.imageUrl,
                    height: 150,
                    width: double.infinity,
                    memCacheWidth: 500,
                    memCacheHeight: 300,
                    fit: BoxFit.cover,
                  ),
                  // Season Badge Overlay
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(180),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        crop.season == 'Rabi'
                            ? l10n.rabiSeason
                            : l10n.kharifSeason,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          crop.getName(langCode),
                          style: AppTypography.title.copyWith(fontSize: 17),
                        ),
                      ),
                      Text(
                        crop.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    crop.scientificName,
                    style: AppTypography.caption.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Key Agronomic Specs Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.sowing, style: AppTypography.caption),
                            const SizedBox(height: 2),
                            Text(
                              crop.getSowingTime(langCode),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 28, color: AppColors.border),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.marketPrice,
                              style: AppTypography.caption,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              crop.marketPriceRange,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildVideoCard(
    BuildContext context,
    VideoGuideModel video,
    String langCode,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/video/${video.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 105,
                    height: 72,
                    child: OptimizedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      width: 105,
                      height: 72,
                      memCacheWidth: 240,
                      memCacheHeight: 160,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video.getTitle(langCode),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subtitle.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${video.duration} • ${l10n.tapToWatch}',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvisoryBanner(
    List<AdvisoryModel> advisories,
    String langCode,
    AppLocalizations l10n,
  ) {
    if (advisories.isEmpty) return const SizedBox.shrink();

    final first = advisories.first;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withAlpha(80), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  first.getTitle(langCode),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onWarningContainer,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  first.getDescription(langCode),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onWarningContainer,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer skeleton loaders
  Widget _buildCardShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildVideoCardShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildAdvisoryShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
