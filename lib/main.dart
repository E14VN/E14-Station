import 'dart:io';

import 'package:e14_station/providers/credentials.dart';
import 'package:e14_station/providers/socket_station.dart';
import 'package:e14_station/screens/bone.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:system_tray/system_tray.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await localNotifier.setup(
      appName: "E14 Station", shortcutPolicy: ShortcutPolicy.requireCreate);

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
      title: "E14 Station",
      size: Size(450, 715),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  windowManager.setResizable(false);
  windowManager.setMaximizable(false);
  windowManager.setPreventClose(true);

  initSystemTray();

  runApp(const E14Station());
}

class E14Station extends StatelessWidget with WindowListener {
  const E14Station({super.key});

  @override
  Widget build(BuildContext context) {
    windowManager.addListener(this);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginToken()),
          ChangeNotifierProvider(
              create: (_) => SocketStation("https://e14.neursdev.tk"))
        ],
        builder: (context, _) => Consumer<SocketStation>(
            builder: (context, socketStation, _) => MaterialApp(
                theme: ThemeData(
                    colorSchemeSeed: socketStation.emergenciesContent.isEmpty
                        ? Colors.blue
                        : Colors.red,
                    useMaterial3: true),
                darkTheme: ThemeData(
                    colorSchemeSeed: socketStation.emergenciesContent.isEmpty
                        ? Colors.blue
                        : Colors.red,
                    brightness: Brightness.dark,
                    useMaterial3: true),
                themeMode: ThemeMode.system,
                home: const BackBone())));
  }

  @override
  void onWindowClose() {
    windowManager.hide();
    LocalNotification(
            title: "Chạy dưới nền",
            body: "Ứng dụng được chuyển sang System tray.")
        .show();
  }
}

Future<void> initSystemTray() async {
  String path = Platform.isWindows ? 'assets/app.ico' : 'assets/app_icon.png';

  final SystemTray systemTray = SystemTray();

  // We first init the systray menu
  await systemTray.initSystemTray(title: "system tray", iconPath: path);

  // create context menu
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(
        label: "Mở UI E14 Station",
        onClicked: (menuItem) => windowManager.show()),
    MenuItemLabel(
        label: "Thoát E14 Station",
        onClicked: (menuItem) async {
          await windowManager.setPreventClose(false);
          windowManager.close();
        }),
  ]);

  await systemTray.setContextMenu(menu);

  systemTray.registerSystemTrayEventHandler((eventName) {
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? windowManager.show() : systemTray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? systemTray.popUpContextMenu() : windowManager.show();
    }
  });
}
