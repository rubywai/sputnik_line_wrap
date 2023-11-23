import 'package:flutter/material.dart';
import 'package:spunik_line_wrap/spunik_render/sputnik_wrap.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SputnikWrap(
        spacing: 8,
        onShowCount: (int showCount) {},
        children: [
          for (int i = 0; i < 30; i++)
            Container(
              color: Colors.red,
              width: 100,
              height: 30,
              child: Text('Item $i'),
            )
        ],
      ),
    );
  }
}
