import 'package:flutter/material.dart';
import 'package:e14_station/providers/credentials.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 578,
        width: MediaQuery.of(context).size.width,
        child: const Column(children: [
          SizedBox(height: 40),
          Text("Đăng nhập", style: TextStyle(fontSize: 32)),
          LoginContainer(),
          Spacer(),
          Text("E14VN Station v1.0"),
          Text("Tài liệu - Hướng dẫn nhanh")
        ]));
  }
}

class LoginContainer extends StatefulWidget {
  const LoginContainer({super.key});

  @override
  State<StatefulWidget> createState() => _LoginContainerState();
}

class _LoginContainerState extends State<LoginContainer> {
  late TextEditingController accountNameController, passwordController;

  @override
  void initState() {
    super.initState();
    accountNameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    accountNameController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(48),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
              padding: EdgeInsets.only(left: 10), child: Text("Tên tài khoản")),
          const SizedBox(height: 5),
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline)),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                      controller: accountNameController,
                      decoration:
                          const InputDecoration(border: InputBorder.none)))),
          const SizedBox(height: 20),
          const Padding(
              padding: EdgeInsets.only(left: 10), child: Text("Mật khẩu")),
          const SizedBox(height: 5),
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline)),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(border: InputBorder.none)))),
          const SizedBox(height: 20),
          InkWell(
              onTap: () => Provider.of<LoginToken>(context, listen: false)
                  .login(accountNameController.text, passwordController.text, context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.primary),
                  child: Center(
                      child: Text("Đăng nhập",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color:
                                  Theme.of(context).colorScheme.onPrimary)))))
        ]));
  }
}
