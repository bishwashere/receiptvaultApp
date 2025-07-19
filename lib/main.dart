import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class WebApp extends StatefulWidget {
  const WebApp({super.key});

  @override
  State<WebApp> createState() => _WebAppState();
}

class _WebAppState extends State<WebApp> {
  late InAppWebViewController webViewController;
   final String homeUrl = 'https://www.receiptvault.com/';
  final String logoutUrl = 'https://www.receiptvault.com/logout';
  bool isLoading = true;
  final String googleAuthRedirectUrl =
      "https://accounts.google.com/o/oauth2/v2/auth/";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(Uri.parse(homeUrl)),
              ),
              onCreateWindow: (controller, request) async {
                // Handle Google OAuth popup by launching in system browser
                if (request.request.url.toString().startsWith(googleAuthRedirectUrl)) {
                  final uri = request.request.url;
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication, // Use system browser
                    );
                    // Optionally, monitor for redirect URI if using custom scheme
                    // This requires deep linking setup in your app
                    return true;
                  }
                }
                return false; // Let other popups be handled normally
              },
              initialSettings: InAppWebViewSettings(
                userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36", // Standard browser user agent
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
                useShouldOverrideUrlLoading: true,
                clearSessionCache: false,
                cacheEnabled: true,
                sharedCookiesEnabled: true,
                supportZoom: false,
                mediaPlaybackRequiresUserGesture: false,
                supportMultipleWindows: true,
                thirdPartyCookiesEnabled: true, // For cross-domain OAuth
                domStorageEnabled: true,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStop: (controller, url) async {
                setState(() => isLoading = false);
              },
              // Handle navigation requests
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url;
                if (url.toString().startsWith(googleAuthRedirectUrl)) {
                  if (await canLaunchUrl(url!)) {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                    return NavigationActionPolicy.CANCEL; // Prevent WebView navigation
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
            if (isLoading) Center(child: Lottie.asset("assets/animation.json")),
          ],
        ),
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Vault',
      debugShowCheckedModeBanner: false,
      home: const WebApp(),
    );
  }
}