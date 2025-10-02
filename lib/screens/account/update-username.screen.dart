import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/helpers/profile.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/util.helper.dart';

import 'package:rift/models/profile.model.dart';

const List<String> regions = [
  'Africa',
  'Asia',
  'Europe',
  'North America',
  'Oceania',
  'South America',
];

class UpdateUsername extends StatefulWidget {
  const UpdateUsername({super.key});

  @override
  State<UpdateUsername> createState() => _UpdateUsernameState();
}

class _UpdateUsernameState extends State<UpdateUsername> {
  Session? session = supabase.auth.currentSession;

  bool _isLoading = true;
  Profile? _profile;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStorage();
  }

  void _fetchStorage() async {
    _profile = await fetchProfile();
    setState(() {
      _isLoading = false;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    _showConfirmationDialog();
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure with this username?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You are only allowed to update your username once'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Change Username',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                _updateUsername();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateUsername() async {
    final Map<String, dynamic> payload = {
      "username": _usernameController.text,
    };

    final response = await updateUsername(payload);
    response.fold((l) {
      _profile!.username = payload['username'];
      _profile!.usernameChanges = _profile!.usernameChanges! + 1;
      saveProfile(_profile!);

      logEvent(name: 'account_update_username');

      Navigator.pop(context, true);
    }, (r) {
      showSnackbar('Unable to update username', subtitle: r['message']);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Username'),
        elevation: 1,
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text("Save"),
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
                          "Change Username",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.outline),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        TextFormField(
                          autofocus: true,
                          controller: _usernameController,
                          maxLength: 16,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                          ],
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Username is required';
                            }
                            final regex = RegExp(r'^[a-zA-Z0-9_]+$');
                            if (!regex.hasMatch(val)) {
                              return 'Only letters, numbers and underscores are allowed';
                            }
                            if (val.length < 3) {
                              return 'Username is too short';
                            }
                            if (val.length > 16) {
                              return 'Username is too long';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Username',
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
                            _usernameController.text = value!;
                          },
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
