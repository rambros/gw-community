import 'package:flutter/material.dart';
import '/config/app_config.dart';
import '/ui/core/themes/app_theme.dart';
import '/data/services/supabase/supabase.dart';
import 'package:google_fonts/google_fonts.dart';
import '/utils/custom_functions.dart' as functions;

class JourneyStepItemWidget extends StatelessWidget {
  const JourneyStepItemWidget({
    super.key,
    required this.stepRow,
    required this.isLastStep,
    required this.isCurrentStep,
    required this.onTap,
  });

  final CcViewUserStepsRow stepRow;
  final bool isLastStep;
  final bool isCurrentStep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline column with continuous line
              SizedBox(
                width: 40.0,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Continuous vertical line behind the indicator
                    if (!isLastStep)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 2.0,
                            color: AppTheme.of(context).primary,
                          ),
                        ),
                      ),
                    // Step indicator on top
                    _buildStepIndicator(context),
                  ],
                ),
              ),
              // Content column
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stepRow.title ?? 'Step Title',
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: FontWeight.w500,
                                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                              ),
                              color: (stepRow.stepStatus != 'open' && stepRow.stepStatus != 'closed')
                                  ? AppTheme.of(context).alternate
                                  : AppTheme.of(context).primaryText,
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                            ),
                      ),
                      Text(
                        stepRow.description ?? 'Description',
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: FontWeight.w300,
                                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                              ),
                              color: (stepRow.stepStatus != 'open' && stepRow.stepStatus != 'closed')
                                  ? AppTheme.of(context).alternate
                                  : AppTheme.of(context).primaryText,
                              fontSize: 14.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w300,
                              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    if (stepRow.stepStatus == 'completed') {
      // Step completo - círculo preenchido com primary e número branco
      return Container(
        width: 28.0,
        height: 28.0,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primary,
          shape: BoxShape.circle,
        ),
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: Text(
          stepRow.stepNumber?.toString() ?? '0',
          textAlign: TextAlign.center,
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(
                  fontWeight: FontWeight.w600,
                  fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                ),
                color: AppTheme.of(context).primaryBackground,
                fontSize: 14.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
              ),
        ),
      );
    } else if (stepRow.stepStatus == 'open') {
      // Apenas o step atual (primeiro open) pode ser acessado
      // Se o controle de data está habilitado, também verifica se passou o tempo necessário
      final canStart = isCurrentStep &&
          (stepRow.stepNumber == 1 ||
              !AppConfig.enableDateControl ||
              (stepRow.dateStarted != null && functions.checkStepIniciouMais1Dia(stepRow.dateStarted!)));

      if (canStart) {
        // Step aberto e disponível - mostra número
        return Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.of(context).primary,
              width: 2.0,
            ),
          ),
          alignment: const AlignmentDirectional(0.0, 0.0),
          child: Text(
            stepRow.stepNumber?.toString() ?? '0',
            textAlign: TextAlign.center,
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(
                    fontWeight: FontWeight.w600,
                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: AppTheme.of(context).secondary,
                  fontSize: 14.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
        );
      } else {
        // Step aberto mas aguardando tempo - mostra cadeado
        return Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.of(context).primary,
              width: 2.0,
            ),
          ),
          child: Icon(
            Icons.lock,
            color: AppTheme.of(context).secondary,
            size: 16.0,
          ),
        );
      }
    } else {
      // Step fechado (closed) - mostra cadeado
      return Container(
        width: 28.0,
        height: 28.0,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.of(context).primary,
            width: 2.0,
          ),
        ),
        child: Icon(
          Icons.lock,
          color: AppTheme.of(context).secondary,
          size: 16.0,
        ),
      );
    }
  }
}
