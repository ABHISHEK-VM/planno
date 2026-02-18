import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:planno/core/router/app_router.dart';

import 'package:planno/core/theme/app_colors.dart';
import 'package:planno/core/theme/app_text_styles.dart';
import 'package:planno/features/auth/presentation/bloc/auth_bloc.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.router.replace(const DashboardRoute());
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 80.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Welcome Back!',
                        style: AppTextStyles.heading1,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Sign in to continue to Planno',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 48.h),
                      _LoginForm(isLoading: state is AuthLoading),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final bool isLoading;
  const _LoginForm({required this.isLoading});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController(text: 'test@planno.com');
  final _passwordController = TextEditingController(text: 'password');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        SizedBox(height: 16.h),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: widget.isLoading
                ? null
                : () {
                    context.read<AuthBloc>().add(
                      LoginRequested(
                        email: _emailController.text,
                        password: _passwordController.text,
                      ),
                    );
                  },
            child: widget.isLoading
                ? SizedBox(
                    height: 24.h,
                    width: 24.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Login'),
          ),
        ),
        SizedBox(height: 16.h),
        TextButton(
          onPressed: () => context.router.push(const SignUpRoute()),
          child: const Text('Don\'t have an account? Sign Up'),
        ),
      ],
    );
  }
}
