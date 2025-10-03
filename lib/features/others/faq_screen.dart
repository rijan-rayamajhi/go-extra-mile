import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/core/utils/responsive_utils.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_bloc.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_event.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_state.dart';
import 'package:go_extra_mile_new/features/admin_data/domain/entities/faq.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch admin data when screen initializes
    context.read<AdminDataBloc>().add(FetchAdminDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        centerTitle: true,
      ),
      body: BlocBuilder<AdminDataBloc, AdminDataState>(
        builder: (context, state) {
          // Handle loading state
          if (state is AdminDataLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading FAQs...'),
                ],
              ),
            );
          }

          // Handle error state
          if (state is AdminDataError) {
            return Center(
              child: Padding(
                padding: context.padding(all: baseScreenPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: context.iconSize(baseXLargeIconSize),
                      color: Colors.red,
                    ),
                    SizedBox(height: context.baseSpacing(baseSpacing)),
                    Text(
                      'Failed to load FAQs',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: context.baseSpacing(baseSmallSpacing)),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.baseSpacing(baseLargeSpacing)),
                    PrimaryButton(
                      text: 'Retry',
                      onPressed: () {
                        context.read<AdminDataBloc>().add(FetchAdminDataEvent());
                      },
                      icon: Icons.refresh,
                    ),
                  ],
                ),
              ),
            );
          }

          // Handle loaded state
          if (state is AdminDataLoaded) {
            final faqs = state.appSettings.faqs;

            if (faqs.isEmpty) {
              return _buildEmptyState(context);
            }

            return _buildFAQList(context, faqs);
          }

          // Default empty state
          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.padding(all: baseScreenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.iconSize(baseXLargeIconSize * 3),
              height: context.iconSize(baseXLargeIconSize * 3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(
                  context.borderRadius(baseCardRadius * 1.5),
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.help_outline,
                size: context.iconSize(baseXLargeIconSize * 1.5),
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: context.baseSpacing(baseLargeSpacing)),
            Text(
              'No FAQs Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: context.fontSize(baseXLargeFontSize),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.baseSpacing(baseSpacing)),
            Text(
              'Frequently asked questions will appear here once they are added by the admin.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: context.fontSize(baseLargeFontSize),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQList(BuildContext context, List<Faq> faqs) {
    return ListView.builder(
      padding: context.padding(all: baseScreenPadding),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return _buildFAQItem(context, faq, index);
      },
    );
  }

  Widget _buildFAQItem(BuildContext context, Faq faq, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: context.baseSpacing(baseSpacing)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.borderRadius(baseCardRadius),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: context.padding(
            horizontal: baseCardPadding,
            vertical: baseSmallSpacing,
          ),
          childrenPadding: context.padding(
            horizontal: baseCardPadding,
            bottom: baseCardPadding,
          ),
          leading: Container(
            width: context.iconSize(baseLargeIconSize),
            height: context.iconSize(baseLargeIconSize),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                context.borderRadius(baseInputRadius),
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: context.fontSize(baseMediumFontSize),
                ),
              ),
            ),
          ),
          title: Text(
            faq.question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: context.fontSize(baseLargeFontSize),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: context.padding(all: baseCardPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(
                  context.borderRadius(baseInputRadius),
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                faq.answer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: context.fontSize(baseLargeFontSize),
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
