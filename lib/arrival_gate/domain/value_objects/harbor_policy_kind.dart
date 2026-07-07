enum HarborPolicyKind { userAgreement, privacyPolicy }

extension HarborPolicyKindCopy on HarborPolicyKind {
  String get title {
    return switch (this) {
      HarborPolicyKind.userAgreement => 'User Agreement',
      HarborPolicyKind.privacyPolicy => 'Privacy Policy',
    };
  }

  Uri get publishedUri {
    return switch (this) {
      HarborPolicyKind.userAgreement => Uri.parse(
        'https://sites.google.com/view/coastin-terms-of-service/home',
      ),
      HarborPolicyKind.privacyPolicy => Uri.parse(
        'https://sites.google.com/view/coastin-privacy-policy/home',
      ),
    };
  }
}
