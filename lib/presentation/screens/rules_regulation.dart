import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:quick_mart/presentation/widgets/color.dart';

class RulesAndRegulationsPage extends StatefulWidget {
  const RulesAndRegulationsPage({super.key});

  @override
  _RulesAndRegulationsPageState createState() => _RulesAndRegulationsPageState();
}

class _RulesAndRegulationsPageState extends State<RulesAndRegulationsPage> {
  String _rulesContent = 'Loading Rules and Regulations...';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRulesContent();
  }

  Future<void> _loadRulesContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      _rulesContent = """
# QuickMart App: Rules and Regulations (Terms of Service)

*Last Updated: June 11, 2025*

Please read these Rules and Regulations ("Terms," "Terms of Service") carefully before using the QuickMart mobile application (the "App") operated by QuickMart ("us," "we," or "our").

Your access to and use of the Service is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all visitors, users, and others who access or use the Service.

By accessing or using the Service, you agree to be bound by these Terms. If you disagree with any part of the terms, then you may not access the Service.

---

## 1. Accounts

When you create an account with us, you must provide us with information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.

You are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password, whether your password is with our Service or a third-party service.

You agree not to disclose your password to any third party. You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.

You must be at least **18 years old** to create an account and use the QuickMart app.

---

## 2. User Conduct and Responsibilities

You agree to use the QuickMart app only for lawful purposes and in a way that does not infringe the rights of, restrict or inhibit anyone else's use and enjoyment of the App. Prohibited behavior includes:

* **Providing accurate information:** All information provided by you during registration, ordering, and interaction with the app must be truthful and accurate.
* **Responsible use:** You are responsible for all activity that occurs under your account.
* **No misuse:** You will not use the app for any fraudulent or unlawful activity, or in any way that could damage, disable, overburden, or impair the app's servers or networks.
* **No unauthorized access:** You will not attempt to gain unauthorized access to any part of the app, other user accounts, or computer systems or networks connected to the app.
* **Respectful communication:** When interacting with customer support or delivery personnel, you agree to be respectful and refrain from abusive, harassing, or offensive language.
* **Compliance with store policies:** When picking up orders from physical QuickMart locations, you must adhere to the store's rules and regulations.
* **Prohibition of resale:** You may not purchase items through the QuickMart app for the purpose of reselling them to others for commercial gain, unless explicitly authorized by QuickMart.

---

## 3. Orders and Payments

* **Order Acceptance:** All orders placed through the QuickMart app are subject to acceptance by us. We reserve the right to refuse or cancel any order for any reason, including but not limited to product availability, errors in pricing or product descriptions, or suspected fraudulent activity.
* **Pricing:** All prices displayed in the app are subject to change without notice. The price charged will be the price in effect at the time of your order.
* **Payment:** You agree to pay for all products and services ordered through the app using the available payment methods. You authorize us to charge your selected payment method for the total amount of your order, including any applicable taxes, delivery fees, and tips.
* **Cancellations and Refunds:** Our cancellation and refund policy is as follows: *[Clearly state your cancellation and refund policy here. For example: "Orders can be canceled within 5 minutes of placement. Refunds for canceled orders or incorrect items will be processed within 3-5 business days."]*
* **Voucher Expiration:** If applicable, any vouchers generated upon purchase must be utilized within **48 hours**. Unutilized vouchers may expire, and the money value may be returned to QuickMart's account or as per our refund policy.

---

## 4. Intellectual Property

The Service and its original content, features, and functionality are and will remain the exclusive property of QuickMart and its licensors. The Service is protected by copyright, trademark, and other laws of both the UAE and foreign countries. Our trademarks and trade dress may not be used in connection with any product or service without the prior written consent of QuickMart.

---

## 5. Termination

We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.

Upon termination, your right to use the Service will immediately cease. If you wish to terminate your account, you may simply discontinue using the Service or contact us to request account deletion.

All provisions of the Terms which by their nature should survive termination shall survive termination, including, without limitation, ownership provisions, warranty disclaimers, indemnity, and limitations of liability.

---

## 6. Links to Other Websites

Our Service may contain links to third-party websites or services that are not owned or controlled by QuickMart.

QuickMart has no control over and assumes no responsibility for, the content, privacy policies, or practices of any third-party websites or services. You further acknowledge and agree that QuickMart shall not be responsible or liable, directly or indirectly, for any damage or loss caused or alleged to be caused by or in connection with the use of or reliance on any such content, goods, or services available on or through any such websites or services.

We strongly advise you to read the terms and conditions and privacy policies of any third-party websites or services that you visit.

---

## 7. Disclaimer of Warranties

Your use of the Service is at your sole risk. The Service is provided on an "AS IS" and "AS AVAILABLE" basis. The Service is provided without warranties of any kind, whether express or implied, including, but not limited to, implied warranties of merchantability, fitness for a particular purpose, non-infringement, or course of performance.

QuickMart does not warrant that a) the Service will function uninterrupted, secure, or available at any particular time or location; b) any errors or defects will be corrected; c) the Service is free of viruses or other harmful components; or d) the results of using the Service will meet your requirements.

---

## 8. Limitation of Liability

In no event shall QuickMart, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from (i) your access to or use of or inability to access or use the Service; (ii) any conduct or content of any third party on the Service; (iii) any content obtained from the Service; and (iv) unauthorized access, use or alteration of your transmissions or content, whether based on warranty, contract, tort (including negligence) or any other legal theory, whether or not we have been informed of the possibility of such damage, and even if a remedy set forth herein is found to have failed of its essential purpose.

---

## 9. Governing Law

These Terms shall be governed and construed in accordance with the laws of UAE, without regard to its conflict of law provisions.

Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights. If any provision of these Terms is held to be invalid or unenforceable by a court, the remaining provisions of these Terms will remain in effect. These Terms constitute the entire agreement between us regarding our Service, and supersede and replace any prior agreements we might have between us regarding the Service.

---

## 10. Changes to Terms

We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days' notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.

By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms. If you do not agree to the new terms, please stop using the Service.

---

## 11. Contact Us

If you have any questions about these Terms, please contact us:

* **By email:** mubivnr@gmail.com
* **By visiting this page on your website:** https://www.yourwebsite.com/contact
""";
    } catch (e) {
      _errorMessage = 'Failed to load Rules and Regulations: $e';
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
          'Rules and Regulations',
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
                  padding: const EdgeInsets.all(16.0),
                  child: MarkdownBody(
                    data: _rulesContent,
                    styleSheet: MarkdownStyleSheet(
                      h1: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color:Theme.of(context).primaryColor,
                            fontSize: 24.0,
                          ),
                      h2: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 20.0,
                          ),
                      // The 'p' style applies to paragraphs, which also includes text within list items.
                      p: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 15.0,
                            height: 1.6, // Increased line height for readability
                          ),
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
    );
  }
}