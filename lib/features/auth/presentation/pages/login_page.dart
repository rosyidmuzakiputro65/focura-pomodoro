import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/demo_account.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _fillDemo() {
    _emailController.text = DemoAccount.email;
    _passwordController.text = DemoAccount.password;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current.error != null && previous.error != current.error,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(s.error(state.error!))));
      },
      child: AuthLayout(
        title: s.welcomeBack,
        subtitle: s.loginSubtitle,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('login_email'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  hintText: s.emailHint,
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                ),
                validator: (v) => s.errorOrNull(Validators.email(v)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('login_password'),
                controller: _passwordController,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: s.passwordHint,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscure ? s.showPassword : s.hidePassword,
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => s.errorOrNull(Validators.requiredPassword(v)),
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
                builder: (context, state) => SubmitButton(
                  label: s.login,
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s.noAccount,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthCubit>().clearError();
                      Navigator.of(context).pushNamed(AppRoutes.register);
                    },
                    child: Text(s.register),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _fillDemo,
                icon: const Icon(Icons.person_outline_rounded),
                label: Text(s.fillDemoAccount(DemoAccount.email)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
