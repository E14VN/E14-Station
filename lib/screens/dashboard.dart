import 'package:e14_station/providers/credentials.dart';
import 'package:e14_station/providers/socket_station.dart';
import 'emergencies_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ValueNotifier<bool> menuToggle = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<SocketStation>(context, listen: false).establishConnection(
          Provider.of<LoginToken>(context, listen: false).token);
    });

    windowManager.maximize();
    windowManager.setMaximizable(true);
    windowManager.setResizable(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoginToken, SocketStation>(
        builder: (context, loginToken, socketStation, _) => Padding(
            padding: const EdgeInsets.all(18),
            child: Stack(children: [
              SizedBox(
                  height: 100,
                  width: 300,
                  child: Text(loginToken.name,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 20),
                      overflow: TextOverflow.ellipsis)),
              Align(
                  alignment: Alignment.center,
                  child: ShowOverall(
                      danger: socketStation.emergenciesContent.isNotEmpty,
                      dangersCount: socketStation.emergenciesContent.length)),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: ConnectionStatusWidget(
                      connected: socketStation.connected)),
              Align(
                  alignment: Alignment.topRight,
                  child: ValueListenableBuilder(
                      valueListenable: menuToggle,
                      builder: (context, _, __) => Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () =>
                                        menuToggle.value = !menuToggle.value,
                                    icon: Icon(menuToggle.value
                                        ? Icons.close
                                        : Icons.menu)),
                                AnimatedContainer(
                                    height: menuToggle.value ? 200 : 0,
                                    width: 400,
                                    duration: const Duration(milliseconds: 150),
                                    curve: Curves.ease,
                                    child: Card(
                                        child: ListView(children: [
                                      InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          onTap: () {},
                                          child: const ListTile(
                                              trailing: Icon(Icons.logout,
                                                  size: 24, color: Colors.red),
                                              title: Text("Đăng xuất",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red)),
                                              subtitle: Text(
                                                  "Không khuyến nghị! Chỉ đăng xuất khi có máy trực khác sẵn sàng đăng nhập.",
                                                  style: TextStyle(
                                                      color: Colors.red))))
                                    ])))
                              ])))
            ])));
  }
}

class ConnectionStatusWidget extends StatelessWidget {
  final bool connected;
  const ConnectionStatusWidget({super.key, required this.connected});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: connected ? Colors.green : Colors.red)),
      const SizedBox(width: 5),
      Text(connected ? "Đã kết nối đến máy chủ" : "Không kết nối với máy chủ")
    ]);
  }
}

class ShowOverall extends StatelessWidget {
  final bool danger;
  final int dangersCount;
  const ShowOverall(
      {super.key, required this.danger, required this.dangersCount});

  @override
  Widget build(BuildContext context) {
    return danger
        ? Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.local_fire_department_outlined, size: 100),
            const SizedBox(height: 10),
            Text("Hiện có $dangersCount báo cháy!",
                style: const TextStyle(fontSize: 32)),
            const Text("Vui lòng xử lí nhanh!"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EmergenciesView())),
                icon: const Icon(Icons.remove_red_eye_outlined),
                label: const Text("Xem tất cả"))
          ])
        : Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_outline, size: 100),
            const SizedBox(height: 10),
            const Text("Không có báo cháy", style: TextStyle(fontSize: 32)),
            const Text(
                "Hiện không có báo cháy nào trong khu vực tỉnh của trạm."),
            const SizedBox(height: 20),
            OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new),
                label: const Text("Tìm hiểu thêm"))
          ]);
  }
}
