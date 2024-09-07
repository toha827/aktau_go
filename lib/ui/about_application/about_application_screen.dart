import 'package:aktau_go/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../widgets/text_locale.dart';

class AboutApplicationScreen extends StatefulWidget {
  const AboutApplicationScreen({Key? key}) : super(key: key);

  @override
  State<AboutApplicationScreen> createState() => _AboutApplicationScreenState();
}

class _AboutApplicationScreenState extends State<AboutApplicationScreen> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      packageInfo = await PackageInfo.fromPlatform();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('О приложении'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          if (packageInfo != null)
            ListTile(
              title: TextLocale(
                'app_name',
                style: text500Size24Greyscale90,
              ),
              subtitle: Text(
                packageInfo!.appName,
                style: text400Size16Greyscale90,
              ),
            ),
          if (packageInfo != null)
            ListTile(
              title: TextLocale(
                'app_version',
                style: text500Size24Greyscale90,
              ),
              subtitle: Text(
                packageInfo!.version,
                style: text400Size16Greyscale90,
              ),
            ),
          if (packageInfo != null)
            ListTile(
              title: TextLocale(
                'app_build_number',
                style: text500Size24Greyscale90,
              ),
              subtitle: Text(
                packageInfo!.buildNumber,
                style: text400Size16Greyscale90,
              ),
            ),
        ],
      ),
    );
  }
}
