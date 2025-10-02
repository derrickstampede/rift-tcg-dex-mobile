import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/helpers/profile.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';

import 'package:rift/models/profile.model.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  Session? session = supabase.auth.currentSession;

  bool _isLoading = true;
  bool _isSaving = false;
  Profile? _profile;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStorage();
  }

  void _fetchStorage() async {
    _profile = await fetchProfile();
    setState(() {
      if (_profile != null && _profile!.displayName != null) {
        _displayNameController.text = _profile!.displayName!;
      }
      _isLoading = false;
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);
    _formKey.currentState!.save();

    // TODO: Check if session is not null, error handling
    final Map<String, dynamic> payload = {
      "display_name": _displayNameController.text,
    };

    final response = await updateProfile(payload);
    response.fold((l) {
      _profile!.displayName = payload['display_name'];
      saveProfile(_profile!);

      logEvent(name: 'account_update');
      setState(() => _isSaving = false);

      Navigator.pop(context, true);
    }, (r) {
      setState(() => _isSaving = false);
      // TODO error handling
    });

    // if (_leaderCard == null) {
    //   setState(() {
    //     _isLeaderValid = false;
    //   });
    //   return;
    // }

    // final deckSlug = _db.collection(_collection).doc().id;
    // _deck = Deck(id: 1, slug: deckSlug, name: _filterForm.name!, leader: _leaderCard!, cards: []);
    // _db.collection(_collection).doc(_deck.slug).set(_deck.toJson());
    // Navigator.pop(context);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 1,
        actions: [
          TextButton(
            onPressed: _submit,
            child: !_isSaving
                ? const Text("Save")
                : const SizedBox(height: 24, width: 24, child: CircularProgressIndicator()),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Display Name",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.outline),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        TextFormField(
                          controller: _displayNameController,
                          maxLength: 32,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Display name is required';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Display Name',
                            counterText: '',
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
                            _displayNameController.text = value!;
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
