import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/models/vault.model.dart';

import 'package:rift/helpers/vault.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/widgets/vaults/vault-color-picker.widget.dart';

import 'package:rift/providers/vault.provider.dart';
import 'package:rift/providers/vaults.provider.dart';

class VaultFormScreen extends ConsumerStatefulWidget {
  const VaultFormScreen({super.key, required this.slug});

  final String? slug;

  @override
  ConsumerState<VaultFormScreen> createState() => _VaultFormScreenState();
}

class _VaultFormScreenState extends ConsumerState<VaultFormScreen> {
  String _title = 'New Vault';
  late Vault _vault;

  final _formKey = GlobalKey<FormState>();
  final _vaultForm = VaultForm(
      id: null, name: null, slug: null, category: 'actual', type: null, color: null, other: null, order: 1, cards: []);

  final _typeOptions = vaultTypeOptions;

  Color _pickerColor = Colors.red;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isCreate = true;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    if (widget.slug == null) {
      setState(() {
        _isLoading = false;
      });
    } else {
      _findVault();
      setState(() {
        _title = 'Update Vault';
        _isCreate = false;
      });
    }

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final isSubscribed = checkIfSubscribed(customerInfo);
      if (isSubscribed) setState(() => _isPro = isSubscribed);
    });

    super.initState();
  }

  Future<void> _findVault() async {
    setState(() {
      _isLoading = true;
    });

    final response = await findVault(widget.slug!);
    response.fold((l) {
      _vault = l['vault'];
      setState(() {
        _vaultForm.id = _vault.id;
        _vaultForm.name = _vault.name;
        _vaultForm.slug = _vault.slug;
        _vaultForm.category = _vault.category;
        _vaultForm.type = _vault.type;
        _vaultForm.color = _vault.color;
        _vaultForm.other = _vault.other;
        _vaultForm.order = _vault.order;

        _pickerColor = Color(int.parse(_vault.color!));

        _isLoading = false;
      });
    }, (r) {
      // TODO error handling
      print(r);
    });
  }

  Future<void> _submit(WidgetRef ref) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _isSaving) {
      return;
    }

    _isSaving = true;
    _formKey.currentState!.save();

    final vaultForm = {
      "id": _vaultForm.id,
      "name": _vaultForm.name,
      "slug": _vaultForm.slug,
      "category": _vaultForm.category,
      "type": _vaultForm.type,
      "color": _pickerColor.value.toString(),
      "other": _vaultForm.other,
      "tcgp_amount": 0,
      "yyt_amount": 0,
      "amount_updated_at": DateTime.now().toString(),
      "cards": [],
      "is_pro": _isPro,
      "created_at": DateTime.now().toString(),
      "updated_at": DateTime.now().toString(),
    };

    if (_isCreate) {
      final response = await storeVault(vaultForm);
      response.fold((l) {
        logEvent(name: 'vault_create', parameters: {'name': _vaultForm.name});
        final Vault vault = Vault.fromMap(l['vault']);

        ref.read(vaultListNotifierProvider.notifier).add(vault);
        // _goBack(vault);
        Navigator.pop(context);
      }, (r) {
        showSnackbar('Unable to create deck', subtitle: r['message']);
        _isSaving = false;
      });
    } else {
      vaultForm['created_at'] = _vault.createdAt.toString();
      vaultForm['updated_at'] = _vault.updatedAt.toString();

      final response = await updateVault(vaultForm, widget.slug!);
      response.fold((l) {
        logEvent(name: 'vault_update', parameters: {'name': _vaultForm.name});
        final Vault vault = Vault.fromMap(vaultForm);

        ref.read(vaultBuildNotifierProvider(widget.slug).notifier).updateColor(vault.color!);
        ref.read(vaultBuildNotifierProvider(widget.slug).notifier).updateName(vault.name);
        ref.read(vaultBuildNotifierProvider(widget.slug).notifier).updateType(vault.type);
        ref.read(vaultListNotifierProvider.notifier).patch(vault);
        ref.read(vaultListNotifierProvider.notifier).updateUpdatedAt(vault.slug);
        
        Navigator.pop(context);
      }, (r) {
        showSnackbar('Unable to edit deck');
        _isSaving = false;
      });
    }
  }

  void changeColor(Color color) {
    setState(() {
      _pickerColor = color;
    });
  }

  void _goBack(Vault? vault) {
    Navigator.pop(context, vault);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        elevation: 1,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: () => _submit(ref),
              child: const Text("Save"),
            )
        ],
      ),
      body: !_isLoading
          ? ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                "Vault Name",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.outline),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              TextFormField(
                                  initialValue: _vaultForm.name,
                                  decoration: InputDecoration(
                                    hintText: 'Name',
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
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_ ]")),
                                  ],
                                  maxLength: 32,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Name is required';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _vaultForm.updateName = value;
                                  }),
                            ]),
                            if (_vaultForm.category == 'actual')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "Type",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.outline),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  DropdownButtonFormField<String>(
                                      value: _vaultForm.type,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                      ),
                                      onChanged: (String? value) {
                                        setState(() {
                                          _vaultForm.updateType = value;
                                        });
                                      },
                                      onSaved: (value) {
                                        _vaultForm.updateType = value;
                                      },
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Type is required';
                                        }
                                        return null;
                                      },
                                      items: [
                                        const DropdownMenuItem<String>(
                                          value: null,
                                          child: Text(
                                            "Select Type",
                                          ),
                                        ),
                                        for (var i = 0; i < _typeOptions.length; i++)
                                          DropdownMenuItem<String>(
                                            value: _typeOptions[i].value,
                                            child: Text(_typeOptions[i].label),
                                          )
                                      ]),
                                ],
                              ),
                            if (_vaultForm.type == 'other')
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Type Name",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.outline),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                TextFormField(
                                    initialValue: _vaultForm.other,
                                    decoration: InputDecoration(
                                      hintText: 'Type Name',
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
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_ ]")),
                                    ],
                                    maxLength: 32,
                                    validator: (val) {
                                      if (_vaultForm.type == 'other' && (val == null || val.isEmpty)) {
                                        return 'Type name is required';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _vaultForm.updateOther = value;
                                    }),
                              ]),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Color",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.outline),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                VaultColorPicker(pickerColor: _pickerColor, onColorChanged: changeColor)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
