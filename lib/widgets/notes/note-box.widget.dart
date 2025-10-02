import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/themes/theme-extension.dart';

import 'package:rift/models/note.model.dart';
import 'package:rift/models/card-search.model.dart';

import 'package:rift/helpers/note.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/widgets/misc/pro-badge.widget.dart';
import 'package:rift/widgets/misc/subheader.widget.dart';
import 'package:rift/widgets/subscription/subscription-box-sm.widget.dart';

import 'package:rift/providers/card-search.provider.dart';
import 'package:rift/providers/decks.provider.dart';

class NoteBox extends ConsumerStatefulWidget {
  const NoteBox({
    super.key,
    required this.note,
    required this.type,
    required this.typeId,
    this.cardSearch,
    this.searchScreen,
  });

  final Note? note;
  final String type;
  final String typeId;
  final CardSearch? cardSearch;
  final String? searchScreen;

  @override
  ConsumerState<NoteBox> createState() => _NoteBoxState();
}

class _NoteBoxState extends ConsumerState<NoteBox> {
  Note? _note;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    _note = widget.note;

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed == true) setState(() => _isPro = isSubscribed);
    // });
  }

  Future<String?> _showForm(BuildContext context, {required Note? note, required type, required typeId}) async {
    final response = await showDialog(
        context: context,
        builder: (BuildContext context) {
          final formKey = GlobalKey<FormState>();
          final noteController = TextEditingController();

          if (note != null) {
            noteController.text = note.note;
          }

          void close({required bool save}) {
            String? note;
            if (save) {
              note = noteController.text;
            }

            Navigator.pop(context, note);
          }

          Future<void> save() async {
            if (!formKey.currentState!.validate()) {
              return;
            }
            formKey.currentState!.save();

            final Map<String, dynamic> payload = {
              "type": type,
              "type_id": int.parse(typeId),
              "note": noteController.text,
            };

            close(save: true);

            final response = await updateNote(payload);
            response.fold((l) {
              logEvent(name: 'note_${type}_update', parameters: {'type_id': int.parse(typeId)});
            }, (r) {
              showSnackbar('Unable to update username', subtitle: r['message']);
            });
          }

          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                'EDIT NOTE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    SizedBox(
                      width: 320,
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          controller: noteController,
                          maxLength: 1000,
                          keyboardType: TextInputType.multiline,
                          maxLines: 8,
                          minLines: 4,
                          validator: (val) {
                            if (val != null && val.length > 1000) {
                              return 'Text is too long';
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(
                                '(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))
                          ],
                          decoration: InputDecoration(
                            hintText: 'Notes',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                          ),
                          onSaved: (value) {
                            noteController.text = value!;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Cancel',
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(4), backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: save,
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
                    ))
              ],
            );
          });
        }).whenComplete(() {});

    return response;
  }

  Future<void> open() async {
    final note = await _showForm(context, note: _note, type: widget.type, typeId: widget.typeId);
    if (note != null) {
      setState(() {
        _note = Note(note: note, type: widget.type, typeId: widget.typeId);
      });
      if (widget.searchScreen != null) {
        ref
            .watch(cardSearchNotifierProvider(screen: widget.searchScreen!, cardSearch: widget.cardSearch!).notifier)
            .updateNote(int.parse(widget.typeId), _note);
      }
      if (widget.type == 'deck') {
        ref.watch(deckListNotifierProvider.notifier).updateNote(int.parse(widget.typeId), _note);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(text: '', children: [
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Subheader(
                text: 'Notes',
              ),
            ),
            WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ProBadge(
                    showUnlock: _isPro ? false : true,
                  ),
                )),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: _isPro
              ? GestureDetector(
                  onTap: open,
                  child: DottedBorder(
                    color: context.proColor.color,
                    padding: const EdgeInsets.all(8),
                    child: _note != null && _note!.note != ''
                        ? SizedBox(
                            width: double.infinity,
                            child: ReadMoreText(
                              _note!.note,
                              trimMode: TrimMode.Line,
                              trimLines: 4,
                              colorClickableText: Theme.of(context).colorScheme.primary,
                              trimCollapsedText: 'Show more',
                              trimExpandedText: 'Show less',
                              style: const TextStyle(fontSize: 16),
                            ))
                        : SizedBox(
                            width: double.infinity,
                            height: 70,
                            child: Center(
                                child: RichText(
                              text: TextSpan(
                                  text: '',
                                  style: TextStyle(color: context.proColor.color, fontSize: 16),
                                  children: [
                                    WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Icon(
                                            Symbols.edit_note,
                                            color: context.proColor.color,
                                          ),
                                        )),
                                    const TextSpan(
                                      text: 'Add a note',
                                    )
                                  ]),
                            )),
                          ),
                  ))
              : const SubscriptionBoxSm(
                  source: 'notes',
                ),
        ),
      ],
    );
  }
}
