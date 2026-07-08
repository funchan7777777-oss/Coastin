enum HarborPolicyChannel { userAgreement, privacyPolicy }

extension HarborPolicyChannelCopy on HarborPolicyChannel {
  String get title {
    return switch (this) {
      HarborPolicyChannel.userAgreement => 'Terms of Service',
      HarborPolicyChannel.privacyPolicy => 'Privacy Policy',
    };
  }

  Uri get publishedUri {
    return switch (this) {
      HarborPolicyChannel.userAgreement => Uri.parse(
        'https://sites.google.com/view/coastin-terms-of-service/home',
      ),
      HarborPolicyChannel.privacyPolicy => Uri.parse(
        'https://sites.google.com/view/coastin-privacy-policy/home',
      ),
    };
  }
}
