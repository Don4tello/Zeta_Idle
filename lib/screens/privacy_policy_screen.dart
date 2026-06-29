import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = <(String, String)>[
    ('1. Introduction',
     'Razor Integrations ("we", "our", or "us") operates the mobile game '
     'Zeta Idle (the "App"). This Privacy Policy explains how we collect, use, '
     'disclose, and safeguard your information when you use the App.\n\n'
     'By using the App you agree to the practices described here.'),

    ('2. Information We Collect',
     '• Account Information: If you sign in with Google, we receive your '
     'display name, email address, and profile photo URL solely for cloud save '
     'synchronization.\n\n'
     '• Game Progress Data: Your in-game progress, settings, inventory, '
     'achievements, and preferences are stored locally and optionally synced '
     'to the cloud via Google Firebase Firestore.\n\n'
     '• Purchase Information: In-app purchase transactions are handled by '
     'Google Play. We do not collect or store payment card details.'),

    ('3. Information Collected Automatically',
     '• Device Information: Device type, OS version, and identifiers may '
     'be collected by the platform or third-party SDKs.\n\n'
     '• Usage Data: General usage patterns such as session duration may '
     'be collected by Firebase for operational purposes.\n\n'
     '• Crash Data: Crash reports and diagnostics may be transmitted '
     'through Firebase to help us fix bugs.\n\n'
     'The App does NOT collect location data, camera or microphone input, '
     'contacts, or any health or biometric data.'),

    ('4. How We Use Information',
     '• Provide, maintain, and improve the App.\n'
     '• Enable cloud save synchronization.\n'
     '• Process in-app purchases and verify entitlements.\n'
     '• Identify and resolve technical issues.\n'
     '• Respond to support requests.'),

    ('5. Data Sharing and Third Parties',
     'We do not sell, trade, or rent your personal information.\n\n'
     'We may share data with:\n'
     '• Google Firebase (Authentication, Cloud Firestore) for user auth '
     'and cloud storage.\n'
     '• Google Play Services for in-app purchases and Google Sign-In.\n\n'
     'We may also disclose information if required by law.'),

    ('6. Data Security',
     'We use HTTPS/TLS encryption for all data transmitted to Firebase, store '
     'local data in the app\'s private storage sandbox, and rely on Google\'s '
     'infrastructure security for cloud data.\n\n'
     'No method of storage or transmission is 100% secure.'),

    ('7. Data Retention',
     '• Local Data: Stored until you uninstall the App or clear app data.\n'
     '• Cloud Data: Retained until you request deletion.\n'
     '• Purchase Records: Managed by Google Play.'),

    ('8. Data Deletion Requests',
     'You may request deletion by:\n'
     '• Uninstalling the App to remove local data.\n'
     '• Emailing razorintegrations@gmail.com for cloud data deletion.\n'
     '• Revoking Google Sign-In via your Google Account permissions.\n\n'
     'Deletion requests are processed within 30 days.'),

    ('9. Children\'s Privacy',
     'The App is not directed at children under 13. We do not knowingly '
     'collect personal information from children under 13. Contact us if you '
     'believe we have inadvertently collected such information.'),

    ('10. Changes to This Policy',
     'We may update this Privacy Policy from time to time. The "Effective Date" '
     'at the top will be revised accordingly. Continued use of the App '
     'constitutes acceptance of the updated policy.'),

    ('11. Contact Us',
     'Developer: Razor Integrations\n'
     'App: Zeta Idle\n'
     'Email: razorintegrations@gmail.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('PRIVACY POLICY',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Zeta Idle',
              style: AppTheme.pixelHeading(
                  fontSize: 11, color: AppTheme.textMuted, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('Privacy Policy',
              style: AppTheme.pixelHeading(
                  fontSize: 20, color: AppTheme.accentGold, letterSpacing: 2)),
          const SizedBox(height: 4),
          const Text('Effective Date: January 1, 2025',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 20),
          for (final (heading, body) in _sections) ...[
            Text(heading,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFc9a84c),
                    height: 1.4)),
            const SizedBox(height: 6),
            Text(body,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textLight, height: 1.6)),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
