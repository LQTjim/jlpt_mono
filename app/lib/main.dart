import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 類似於 React 的 Provider，提供 AuthProvider 實例給子元件使用
    return ChangeNotifierProvider(
      //..cascade operator 串接 tryAutoLogin 方法
      // 等價於
      // final tmp = AuthProvider();
      // tmp.tryAutoLogin();
      // return tmp;
      // 在 build 方法中，Provider 會自動呼叫 tryAutoLogin 方法

      // 這個 create 會在 Provider 第一次插入 widget tree、需要建立那個 AuthProvider instance 時被呼叫一次。
      //#region

      // return MultiProvider(
      /* providers: [
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..tryAutoLogin(),
    ),
    ChangeNotifierProvider(
      create: (_) => SomeOtherProvider(),
    ),
    // 再加其他 provider...
  ],
  child: MaterialApp(
    home: Consumer<AuthProvider>(
      builder: (context, auth, _) {
        ...
      },
    ),
  ),
); 
*/
      //#endregion
      create: (_) => AuthProvider()..tryAutoLogin(),
      child: MaterialApp(
        title: 'JLPT Mono',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return auth.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
