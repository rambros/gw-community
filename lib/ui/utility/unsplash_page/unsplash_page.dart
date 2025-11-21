import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'view_model/unsplash_view_model.dart';

class UnsplashPage extends StatefulWidget {
  const UnsplashPage({super.key});

  static String routeName = 'unPlash'; // Keeping routeName for compatibility
  static String routePath = '/unPlash';

  @override
  State<UnsplashPage> createState() => _UnsplashPageState();
}

class _UnsplashPageState extends State<UnsplashPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UnsplashViewModel>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          top: true,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unsplash Image',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                                        font: GoogleFonts.lexendDeca(),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            FFButtonWidget(
                              onPressed: () async {
                                await viewModel.fetchRandomImage();

                                if (context.mounted) {
                                  if (viewModel.errorMessage == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('success'),
                                        duration: Duration(milliseconds: 4000),
                                        backgroundColor: Color(0x00000000),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Error'),
                                        duration: Duration(milliseconds: 4000),
                                        backgroundColor: Color(0x00000000),
                                      ),
                                    );
                                  }
                                }
                              },
                              text: 'get Image',
                              options: FFButtonOptions(
                                width: 130.0,
                                height: 40.0,
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      font: GoogleFonts.lexendDeca(),
                                      color: Colors.white,
                                    ),
                                elevation: 2.0,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: 400.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEEEEE),
                            ),
                            child: Image.network(
                              viewModel.currentImageUrl,
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
