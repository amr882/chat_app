// Dart imports:
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'dart:math';

import 'package:chat_app/components/caption_field.dart';
import 'package:chat_app/services/stories_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/designs/whatsapp/whatsapp.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';

class ImageCrop extends StatefulWidget {
  const ImageCrop({super.key, required this.file});

  /// The URL of the image to display.
  final File file;

  @override
  State<ImageCrop> createState() => _ImageCropState();
}

class _ImageCropState extends State<ImageCrop> {
  final bool _useMaterialDesign =
      platformDesignMode == ImageEditorDesignMode.material;

  /// Helper class for managing WhatsApp filters.
  final WhatsAppHelper _whatsAppHelper = WhatsAppHelper();

  void openWhatsAppStickerEditor(ProImageEditorState editor) async {
    editor.removeKeyEventListener();

    Layer? layer;
    if (_useMaterialDesign) {
      layer = await editor.openPage(
        WhatsAppStickerPage(
          configs: editor.configs,
          callbacks: editor.callbacks,
        ),
      );
    } else {
      layer = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black12,
        showDragHandle: false,
        isScrollControlled: true,
        useSafeArea: true,
        builder:
            (context) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: WhatsAppStickerPage(
                    configs: editor.configs,
                    callbacks: editor.callbacks,
                  ),
                ),
              ),
            ),
      );
    }

    editor.initKeyEventListener();
    if (layer == null || !mounted) return;

    if (layer.runtimeType != WidgetLayer) {
      layer.scale = editor.configs.emojiEditor.initScale;
    }

    editor.addLayer(layer);
  }

  /// Calculates the number of columns for the EmojiPicker.
  int _calculateEmojiColumns(BoxConstraints constraints) =>
      max(
        1,
        (_useMaterialDesign ? 6 : 10) / 400 * constraints.maxWidth - 1,
      ).floor();
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ProImageEditor.file(
          widget.file,

          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (bytes) async {
              // Convert Uint8List bytes to a File
              final tempDir = await getTemporaryDirectory();
              final uuid = Uuid();
              final fileName = '${uuid.v4()}.png';
              final filePath = '${tempDir.path}/$fileName';
              final File resultFile = File(filePath);
              await resultFile.writeAsBytes(bytes);

              Provider.of<StoriesServices>(
                context,
                listen: false,
              ).uploadToStorage(resultFile, controller.text);
              Navigator.of(context).pop();
            },
            mainEditorCallbacks: MainEditorCallbacks(
              onScaleStart: _whatsAppHelper.onScaleStart,
              onScaleUpdate: (details) {},

              onTap: () => FocusScope.of(context).unfocus(),
            ),
            stickerEditorCallbacks: StickerEditorCallbacks(
              onSearchChanged: (value) {
                /// Filter your stickers
                debugPrint(value);
              },
            ),
          ),
          configs: ProImageEditorConfigs(
            designMode: platformDesignMode,
            mainEditor: MainEditorConfigs(
              enableZoom: true,
              widgets: MainEditorWidgets(
                appBar: (editor, rebuildStream) => null,
                bottomBar: (editor, rebuildStream, key) => null,
                wrapBody: (editor, rebuildStream, content) {
                  return Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      Transform.scale(
                        transformHitTests: false,
                        scale:
                            1 /
                            constraints.maxHeight *
                            (constraints.maxHeight -
                                _whatsAppHelper.filterShowHelper * 2),
                        child: content,
                      ),
                      if (editor.selectedLayerIndex < 0)
                        ..._buildWhatsAppWidgets(editor),
                    ],
                  );
                },
              ),
            ),
            paintEditor: PaintEditorConfigs(
              style: const PaintEditorStyle(
                initialColor: Color.fromARGB(255, 129, 218, 88),
                initialStrokeWidth: 5,
              ),
              widgets: PaintEditorWidgets(
                appBar: (paintEditor, rebuildStream) => null,
                bottomBar: (paintEditor, rebuildStream) => null,
                colorPicker:
                    (paintEditor, rebuildStream, currentColor, setColor) =>
                        null,
                bodyItems: _buildPaintEditorBody,
              ),
            ),
            textEditor: TextEditorConfigs(
              customTextStyles: [
                GoogleFonts.roboto(),
                GoogleFonts.averiaLibre(),
                GoogleFonts.lato(),
                GoogleFonts.comicNeue(),
                GoogleFonts.actor(),
                GoogleFonts.odorMeanChey(),
                GoogleFonts.nabla(),
              ],
              widgets: TextEditorWidgets(
                appBar: (textEditor, rebuildStream) => null,
                colorPicker:
                    (editor, rebuildStream, currentColor, setColor) => null,
                bottomBar: (textEditor, rebuildStream) => null,
                bodyItems: _buildTextEditorBody,
              ),
              style: TextEditorStyle(
                textFieldMargin: EdgeInsets.zero,
                bottomBarBackground: Colors.transparent,
                bottomBarMainAxisAlignment:
                    !_useMaterialDesign
                        ? MainAxisAlignment.spaceEvenly
                        : MainAxisAlignment.start,
              ),
            ),
            cropRotateEditor: CropRotateEditorConfigs(
              enableDoubleTap: false,
              widgets: CropRotateEditorWidgets(
                appBar: (cropRotateEditor, rebuildStream) => null,
                bottomBar:
                    (cropRotateEditor, rebuildStream) => ReactiveWidget(
                      stream: rebuildStream,
                      builder:
                          (_) => WhatsAppCropRotateToolbar(
                            bottomBarColor: const Color(0xFF303030),
                            configs: cropRotateEditor.configs,
                            onCancel: cropRotateEditor.close,
                            onRotate: cropRotateEditor.rotate,
                            onDone: cropRotateEditor.done,
                            onReset: cropRotateEditor.reset,
                            openAspectRatios:
                                cropRotateEditor.openAspectRatioOptions,
                          ),
                    ),
              ),
              style: const CropRotateEditorStyle(
                cropCornerColor: Colors.white,
                helperLineColor: Colors.white,
                cropCornerLength: 28,
                cropCornerThickness: 3,
              ),
            ),

            emojiEditor: EmojiEditorConfigs(
              checkPlatformCompatibility: !kIsWeb,
              style: EmojiEditorStyle(
                backgroundColor: Colors.transparent,
                textStyle: DefaultEmojiTextStyle.copyWith(
                  fontFamily:
                      !kIsWeb ? null : GoogleFonts.notoColorEmoji().fontFamily,
                  fontSize: _useMaterialDesign ? 48 : 30,
                ),
                emojiViewConfig: EmojiViewConfig(
                  gridPadding: EdgeInsets.zero,
                  horizontalSpacing: 0,
                  verticalSpacing: 0,
                  recentsLimit: 40,
                  backgroundColor: Colors.transparent,
                  buttonMode:
                      !_useMaterialDesign
                          ? ButtonMode.CUPERTINO
                          : ButtonMode.MATERIAL,
                  loadingIndicator: const Center(
                    child: CircularProgressIndicator(),
                  ),
                  columns: _calculateEmojiColumns(constraints),
                  emojiSizeMax: !_useMaterialDesign ? 32 : 64,
                  replaceEmojiOnLimitExceed: false,
                ),
                bottomActionBarConfig: const BottomActionBarConfig(
                  enabled: false,
                ),
              ),
            ),

            layerInteraction: const LayerInteractionConfigs(
              style: LayerInteractionStyle(
                removeAreaBackgroundInactive: Colors.black12,
              ),
            ),
            helperLines: const HelperLineConfigs(
              style: HelperLineStyle(
                horizontalColor: Color.fromARGB(255, 129, 218, 88),
                verticalColor: Color.fromARGB(255, 129, 218, 88),
              ),
            ),
          ),
        );
      },
    );
  }

  List<ReactiveWidget> _buildPaintEditorBody(
    PaintEditorState paintEditor,
    Stream<dynamic> rebuildStream,
  ) {
    return [
      ReactiveWidget(
        stream: rebuildStream,
        builder:
            (_) => WhatsAppPaintBottomBar(
              configs: paintEditor.configs,
              strokeWidth: paintEditor.paintCtrl.strokeWidth,
              initColor: paintEditor.paintCtrl.color,
              onColorChanged: (color) {
                paintEditor.paintCtrl.setColor(color);
                paintEditor.uiPickerStream.add(null);
              },
              onSetLineWidth: paintEditor.setStrokeWidth,
            ),
      ),
      if (!_useMaterialDesign)
        ReactiveWidget(
          stream: rebuildStream,
          builder: (_) => WhatsappPaintColorpicker(paintEditor: paintEditor),
        ),
      ReactiveWidget(
        stream: rebuildStream,
        builder:
            (_) => WhatsAppPaintAppBar(
              configs: paintEditor.configs,
              canUndo: paintEditor.canUndo,
              onDone: paintEditor.done,
              onTapUndo: paintEditor.undoAction,
              onClose: paintEditor.close,
              activeColor: paintEditor.activeColor,
            ),
      ),
    ];
  }

  List<ReactiveWidget> _buildTextEditorBody(
    TextEditorState textEditor,
    Stream<dynamic> rebuildStream,
  ) {
    return [
      /// Color-Picker
      if (_useMaterialDesign)
        ReactiveWidget(
          stream: rebuildStream,
          builder:
              (_) => Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight),
                child: WhatsappTextSizeSlider(textEditor: textEditor),
              ),
        )
      else
        ReactiveWidget(
          stream: rebuildStream,
          builder:
              (_) => Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight),
                child: WhatsappTextColorpicker(textEditor: textEditor),
              ),
        ),

      /// Appbar
      ReactiveWidget(
        stream: rebuildStream,
        builder:
            (_) => WhatsAppTextAppBar(
              configs: textEditor.configs,
              align: textEditor.align,
              onDone: textEditor.done,
              onAlignChange: textEditor.toggleTextAlign,
              onBackgroundModeChange: textEditor.toggleBackgroundMode,
            ),
      ),

      /// Bottombar
      ReactiveWidget(
        stream: rebuildStream,
        builder:
            (_) => WhatsAppTextBottomBar(
              configs: textEditor.configs,
              initColor: textEditor.primaryColor,
              onColorChanged: (color) {
                textEditor.primaryColor = color;
              },
              selectedStyle: textEditor.selectedTextStyle,
              onFontChange: textEditor.setTextStyle,
            ),
      ),
    ];
  }

  List<Widget> _buildWhatsAppWidgets(ProImageEditorState editor) {
    double opacity = max(
      0,
      min(1, 1 - 1 / 120 * _whatsAppHelper.filterShowHelper),
    );
    return [
      WhatsAppAppBar(
        configs: editor.configs,
        onClose: editor.closeEditor,
        onTapCropRotateEditor: editor.openCropRotateEditor,
        onTapStickerEditor: () => openWhatsAppStickerEditor(editor),
        onTapPaintEditor: editor.openPaintEditor,
        onTapTextEditor: editor.openTextEditor,
        onTapUndo: editor.undoAction,
        canUndo: editor.canUndo,
        openEditor: editor.isSubEditorOpen,
      ),

      _buildDemoSendArea(editor, opacity),
    ];
  }

  Widget _buildDemoSendArea(ProImageEditorState editor, double opacity) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureInterceptor(
        child: Opacity(
          opacity: opacity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      20,
                      16,
                      20 +
                          (editor.isSubEditorOpen
                              ? 0
                              : MediaQuery.viewInsetsOf(context).bottom),
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xff323741),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: CaptionField(controller: controller)),
                        GestureDetector(
                          onTap: () async {
                            editor.doneEditing();
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xff7c01f6),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: SvgPicture.asset(
                              "assets/send_story.svg",
                              height: 3.5.h,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
