import 'package:flutter/material.dart';

class PrivacyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Last updated: Nov 24th, 2023', style: TextStyle(fontSize: 12)),
            SizedBox(height: 16),
            Text(
              'This privacy policy ("Privacy Policy") is in this context governs the access and usage of the mGramSeva mobile application and web portal (https://mgramseva-dwss.punjab.gov.in), an initiative of the DWSS,'
                  '\n Department of Water Supply and Sanitation, Government of Punjab, Bharat.'
                  '\n This policy outlines how mGramSeva handles personal and usage information in accordance with applicable Indian laws.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              '1. Types of Information Collected:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We collect various types of information, including personal, demographic, location, and device-related data. The information collected depends on the services used and may vary over time.',
            ),
            SizedBox(height: 16),
            Text(
              '2. Use of Personal Information and Collected Data:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('   • Personal Information is used to customize service offerings and enhance user experience.'),
                Text('   • Device and location information helps in adapting content/display based on user preferences and recommending relevant services.'),
                Text('   • Aadhaar-related information provided for Department Services is not stored at mGramSeva.'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '3. Management of Personal Information:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('   • Personal information is stored in encrypted form and shared with registered Service Providers only when necessary for delivering requested services.'),
                Text('   • Information is not shared with any other individual or party without express consent, except as required by applicable laws.'),
                Text('   • Collected information is primarily used for user categorization and analytics purposes.'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '4. User Control:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('   • Users can control cookies through browser settings and are advised to close sessions after use.'),
                Text('   • Users can review and opt-out of communications.'),
                Text('   • Personal Information is retained in encrypted form for legal requirements/compliances for a minimum of three years after deletion/termination.'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '5. Use of Personal Information:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('   • Personal information may be used for providing services and facilitating service deliveries.'),
                Text('   • Sending promotional features/materials regarding mGramSeva and services offered by government and private organizations.'),
                Text('   • Enhancing the efficiency/quality of services.'),
                Text('   • Resolving disputes, monitoring user activity, and preventing unlawful activities.'),
                Text('   • Conducting research or analyzing user preferences and demographics.'),
                Text('   • Any other purpose required under applicable laws.'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '6. Information Sharing:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('   • Personal information may be shared with law enforcement and government departments for legal compliance and protection against harm.'),
                Text('   • All information is held in encrypted form, and communication channels are encrypted using SSL.'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '7. Grievance Redressal:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('In case of grievances, complaints can be sent to miscell.dwss@punjab.gov.in.'),
            Text('Or write us at:'),
            Text('   Head Office, Department of Water Supply & Sanitation, Punjab'),
            Text('   Phase 2, Sector 54, S.A.S. Nagar (Mohali), PIN: 160055'),
          ],
        ),
      );
  }
}