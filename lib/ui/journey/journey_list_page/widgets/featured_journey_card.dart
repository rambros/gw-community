import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';

class FeaturedJourneyCard extends StatelessWidget {
  const FeaturedJourneyCard({
    super.key,
    required this.journeyRow,
    this.stepsCompleted = 0,
    this.journeyStatus,
    this.onTap,
  });

  final CcViewUserJourneysRow journeyRow;
  final int stepsCompleted;
  final String? journeyStatus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted =
        journeyStatus == 'completed' || (journeyRow.stepsTotal != null && stepsCompleted >= journeyRow.stepsTotal!);

    final double progress =
        journeyRow.stepsTotal != null && journeyRow.stepsTotal! > 0 ? stepsCompleted / journeyRow.stepsTotal! : 0.0;

    return Container(
      width: double.infinity,
      height: 180.0,
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondary, // Roxo Escuro da paleta
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 15.0,
            color: Color(0x33000000),
            offset: Offset(0.0, 8.0),
          )
        ],
      ),
      child: Stack(
        children: [
          // Background decorative elements (subtle)
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.auto_awesome,
              size: 150,
              color: Colors.white.withOpacity(0.05),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Left Side: Image of the journey
                if (journeyRow.imageUrl != null && journeyRow.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Container(
                      width: 90.0,
                      height: 90.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: CachedNetworkImage(
                          imageUrl: journeyRow.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/logo_goodwishes_300.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Middle: Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'FEATURED',
                        style: AppTheme.of(context).labelSmall.override(
                              color: AppTheme.of(context).tertiary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: 10.0,
                            ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        journeyRow.title ?? 'Untitled Journey',
                        style: AppTheme.of(context).headlineSmall.override(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12.0),
                      FFButtonWidget(
                        onPressed: onTap,
                        text: isCompleted ? 'VIEW AGAIN' : 'RESUME',
                        options: FFButtonOptions(
                          width: 120.0,
                          height: 36.0,
                          color: isCompleted ? AppTheme.of(context).tertiary : AppTheme.of(context).primary,
                          textStyle: AppTheme.of(context).bodySmall.override(
                                color: isCompleted ? AppTheme.of(context).secondary : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          borderRadius: BorderRadius.circular(18.0),
                          elevation: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Side: Circular Progress
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60.0,
                        height: 60.0,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6.0,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          color: AppTheme.of(context).tertiary,
                        ),
                      ),
                      Text(
                        isCompleted
                            ? '${journeyRow.stepsTotal ?? 0}/${journeyRow.stepsTotal ?? 0}'
                            : '$stepsCompleted/${journeyRow.stepsTotal ?? 0}',
                        style: AppTheme.of(context).bodySmall.override(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.0,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
