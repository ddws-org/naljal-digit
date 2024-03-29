import 'package:flutter/material.dart';

class TermsAndConditionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions (TNC) for NalJalSeva',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Last updated: Nov 24th, 2023', style: TextStyle(fontSize: 12)),
            SizedBox(height: 16),
            buildSection('1. Acceptance of Terms', '''
              By accessing and using NalJalSeva, you agree to be bound by these Terms of Service/Use. If you do not consent to these Terms or any part thereof, refrain from downloading/accessing NalJalSeva and using its services. Your consent to these Terms is mandatory.
            '''),
            buildSection('2. Scope and Offered Services', '''
              NalJalSeva is designed to provide citizens with single point access to Panchayat level services. The scope of services will evolve over time.
            '''),
            buildSection('3. Responsibility and Ownership of Information', '''
              Users are responsible for the authenticity of personal information provided during registration. NalJalSeva and its registered Service Providers may store information electronically for service delivery, personalization, analytics, and legal requirements. NalJalSeva reserves the right to refuse or remove unlawful, offensive, or violative content.
            '''),
            buildSection('4. Consent for Aadhaar Registration', '''
              By registering with Aadhaar, users authorize NalJalSeva to use Aadhaar information for authentication and fetching eKYC data from UIDAI servers for service delivery.
            '''),
            buildSection('5. Limitation on Liability', '''
              NalJalSeva does not guarantee specific requirements, uninterrupted availability, 100% security, or error-free operation. In no event will NalJalSeva, or the Government of Bharat be liable for any loss or damage arising from the use of NalJalSeva.
            '''),
            buildSection('6. Limitation on Use', '''
              NalJalSeva is for Employees of DDWS use only, and commercial exploitation is prohibited. Users shall not decompile, reverse engineer, or engage in unauthorized use. Unauthorized software/tools to access, monitor, or copy NalJalSeva is prohibited.
            '''),
            buildSection('7. Right to Modify or Terminate', '''
              NalJalSeva reserves the right to modify or discontinue the service, with or without notice. NalJalSeva may terminate user accounts and refuse future use without prior notice. Such termination may result in the loss of account content.
            '''),
            buildSection('8. Applicable Law', '''
              These Terms are governed by Indian law. Any dispute arising under these Terms is subject to the exclusive jurisdiction of the courts located in New Delhi, Bharat.
            '''),
            buildSection('9. Proprietary Rights and License', '''
              All trademarks, copyright, and intellectual property rights in NalJalSeva belong to, Government of Bharat. Unauthorized use may result in legal action.
            '''),
            buildSection('10. Conditions of Use', '''
              NalJalSeva and its services are not available to individuals previously removed from using NalJalSeva services by the Government of Bharat.
            '''),
            Text(
              'These Terms supersede all earlier versions, and users are encouraged to review the NalJalSeva website for further details and updates. Your continued use of NalJalSeva implies acceptance of any changes.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
  }

  Widget buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(content),
        SizedBox(height: 16),
      ],
    );
  }
}
