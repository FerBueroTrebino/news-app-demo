import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/bloc/auth/auth_cubit.dart';
import '../../../auth/presentation/widgets/google_sign_in_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.allGiant,
      child: Center(
        child: Card(
          elevation: 8,
          child: Padding(
            padding: AppPadding.allXxl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You need to sign in to create an article.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                GoogleSignInButton(
                  onPressed: () {
                    context.read<AuthCubit>().signInWithGoogle();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
