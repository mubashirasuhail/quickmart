import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:quick_mart/presentation/widgets/color.dart'; // Import flutter_markdown

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String _policyContent = 'Loading Privacy Policy...';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPolicyContent();
  }

  Future<void> _loadPolicyContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // For demonstration, using a placeholder.
      // This content is now formatted using Markdown syntax.
      _policyContent = """
# QuickMart App: Privacy Policy

*Last Updated: June 11, 2025*

This Privacy Policy describes how QuickMart ("we," "us," or "our") collects, uses, and discloses your information when you use our QuickMart mobile application (the "App") and the services provided through it (collectively, the "Service").

By accessing or using our Service, you agree to the collection and use of information in accordance with this Privacy Policy. If you do not agree with the terms of this Privacy Policy, please do not use the Service.

---

## 1. Information We Collect

We collect various types of information to provide and improve our Service to you.

### a. Personal Data

While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you ("Personal Data"). Personal Data may include, but is not limited to:

* **Contact Information:** Email address, first name, last name, phone number, delivery address (including street, city, state, province, ZIP/postal code).
* **Account Information:** Username, password, and other registration details.
* **Payment Information:** Payment card details, bank account details (processed securely by third-party payment processors). We do not store full payment card numbers on our servers.
* **Demographic Information:** Age, date of birth, gender (optional, for personalization).
* **Images:** If you upload images (e.g., for profile picture or order-related issues).
* **Other details:** Any other information you voluntarily provide to us.

### b. Usage Data

We may also collect information that your device sends whenever you visit our Service or when you access Service by or through a mobile device ("Usage Data"). This Usage Data may include information such as:

* Your device's Internet Protocol address (e.g., IP address).
* Device type, unique device IDs, mobile operating system, mobile internet browser type.
* Pages of our Service that you visit, the time and date of your visit, the time spent on those pages.
* Unique device identifiers and other diagnostic data.
* Information about your interactions with the App (e.g., features used, items viewed, search queries).

### c. Location Data

We may use and store information about your location if you give us permission to do so ("Location Data"). We use this data to provide features of our Service, such as identifying nearby stores, enabling delivery services, and customizing your experience. You can enable or disable location services when you use our Service at any time, through your device settings.

### d. Information from Third Parties

We may receive information about you from third-party services, such as social media platforms if you choose to link your QuickMart account with them, or from our business partners.

---

## 2. How We Use Your Information

We use the collected data for various purposes:

* **To Provide and Maintain our Service:** To operate and deliver the core functionalities of the QuickMart app, including processing orders, managing your account, and facilitating deliveries.
* **To Personalize Your Experience:** To tailor product recommendations, offers, and content based on your preferences and usage patterns.
* **To Process Transactions:** To complete your purchases and manage your payment information.
* **To Improve Our Service:** To understand how users interact with our app, identify areas for improvement, and develop new features.
* **To Communicate with You:** To send you transaction confirmations, order updates, customer service messages, marketing and promotional materials (with your consent), and other important notices.
* **For Security and Fraud Prevention:** To protect against fraudulent transactions, unauthorized access, and other illegal activities.
* **To Enforce Our Terms:** To ensure compliance with our Rules and Regulations and resolve disputes.
* **For Legal Compliance:** To comply with applicable laws, regulations, legal processes, or governmental requests.

---

## 3. Disclosure of Your Information

We may share your information in the following situations:

* **With Service Providers:** We may employ third-party companies and individuals to facilitate our Service (e.g., payment processors, delivery partners, analytics providers, hosting services). These third parties have access to your Personal Data only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.
* **With Business Partners:** We may share your information with our trusted business partners to offer you specific products, services, or promotions, provided you have consented to such sharing.
* **For Business Transfers:** If we are involved in a merger, acquisition, or asset sale, your Personal Data may be transferred. We will provide notice before your Personal Data is transferred and becomes subject to a different Privacy Policy.
* **For Law Enforcement:** Under certain circumstances, we may be required to disclose your Personal Data if required to do so by law or in response to valid requests by public authorities (e.g., a court or a government agency).
* **To Protect Our Rights:** We may disclose your Personal Data where we believe it is necessary to investigate, prevent, or take action regarding potential violations of our policies, suspected fraud, situations involving potential threats to the safety of any person, or as evidence in legal proceedings.
* **With Your Consent:** We may disclose your personal information for any other purpose with your consent.

---

## 4. Data Security

The security of your data is important to us, but remember that no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security. We implement various technical and organizational measures to safeguard your information.

---

## 5. Data Retention

We will retain your Personal Data only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use your Personal Data to the extent necessary to comply with our legal obligations (for example, if we are required to retain your data to comply with applicable laws), resolve disputes, and enforce our legal agreements and policies.

Usage Data is generally retained for a shorter period, except when this data is used to strengthen the security or to improve the functionality of our Service, or we are legally obligated to retain this data for longer time periods.

---

## 6. Your Data Protection Rights

Depending on your location, you may have the following data protection rights:

* **The Right to Access:** You have the right to request copies of your Personal Data.
* **The Right to Rectification:** You have the right to request that we correct any information you believe is inaccurate or complete information you believe is incomplete.
* **The Right to Erasure:** You have the right to request that we erase your Personal Data, under certain conditions.
* **The Right to Restrict Processing:** You have the right to request that we restrict the processing of your Personal Data, under certain conditions.
* **The Right to Object to Processing:** You have the right to object to our processing of your Personal Data, under certain conditions.
* **The Right to Data Portability:** You have the right to request that we transfer the data that we have collected to another organization, or directly to you, under certain conditions.
* **The Right to Withdraw Consent:** You have the right to withdraw your consent at any time where QuickMart relied on your consent to process your personal information.

If you make a request, we have one month to respond to you. If you would like to exercise any of these rights, please contact us at `[Your Contact Email Address]`.

---

## 7. Children's Privacy

Our Service does not address anyone under the age of 13 ("Children"). We do not knowingly collect personally identifiable information from anyone under the age of 13. If you are a parent or guardian and you are aware that your child has provided us with Personal Data, please contact us. If we become aware that we have collected Personal Data from children without verification of parental consent, we take steps to remove that information from our servers.

---

## 8. Changes to This Privacy Policy

We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date at the top of this Privacy Policy. You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.

---

## 9. Contact Us

If you have any questions about this Privacy Policy, please contact us:

* **By email:** mubivnr@gmail.com
* **By visiting this page on your website:** https://www.yourwebsite.com/contact
""";
    } catch (e) {
      _errorMessage = 'Failed to load Privacy Policy: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.darkgreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0), // Consistent padding around content
                  child: MarkdownBody(
                    data: _policyContent,
                    styleSheet: MarkdownStyleSheet(
                      h1: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 26.0, // Slightly larger for main title
                          ),
                      h2: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 22.0, // Slightly larger for section titles
                          ),
                      h3: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w600, // For sub-headings
                            color: Theme.of(context).primaryColor,
                            fontSize: 18.0, // Adjusted font size for sub-headings
                          ),
                      p: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 16.0, // Increased default paragraph font size
                            height: 1.7, // Increased line height for better readability
                          ),
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
    );
  }
}