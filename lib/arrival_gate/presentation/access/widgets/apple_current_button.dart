import 'package:flutter/cupertino.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleCurrentButton extends StatelessWidget {
  const AppleCurrentButton({
    super.key,
    required this.onAppleCurrentPressed,
    this.isWorking = false,
  });

  final VoidCallback onAppleCurrentPressed;
  final bool isWorking;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 236,
        height: 44,
        child: isWorking
            ? Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x3317324A)),
                ),
                child: const CupertinoActivityIndicator(radius: 12),
              )
            : SignInWithAppleButton(
                height: 44,
                text: 'Sign in with Apple',
                style: SignInWithAppleButtonStyle.whiteOutlined,
                borderRadius: BorderRadius.circular(12),
                iconAlignment: SignInWithAppleIconAlignment.center,
                onPressed: onAppleCurrentPressed,
              ),
      ),
    );
  }
}
