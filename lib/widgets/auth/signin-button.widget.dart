import 'package:flutter/material.dart';

import 'package:rift/helpers/auth.helper.dart';

class SigninButton extends StatelessWidget {
  const SigninButton({
    super.key,
    Function()? fetchStorage,
  }) : _fetchStorage = fetchStorage;

  final Function()? _fetchStorage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Get the most out of',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              Text(
                'RIFT TCG Dex!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: () {
                    showSignInModal(context, title: 'Access Features!', fetchStorage: _fetchStorage);
                  },
                  child: const Text(
                    'Sign in',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
