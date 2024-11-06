import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';  // Importación para el portapapeles

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Summarizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SummaryScreen(),
    );
  }
}

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  TextEditingController urlController = TextEditingController();
  String summary = '';

  Future<void> getSummary(String videoUrl) async {
    // Reemplaza con tu clave de API de OpenAI
    const apiKey = 'API KEY';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': 'Resumi el contenido de los subtítulos del video, que sea conciso y en items, pero que contenga siempre la idea principal desarrollada (que no sea un resumen superfluo de solo titulos sin contenido): $videoUrl'
            }
          ],
          'temperature': 0.3, // Ajusta la temperatura aquí
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          summary = data['choices'][0]['message']['content'];
        });
      } else {
        setState(() {
          summary = 'Error al generar el resumen: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        summary = 'Error al conectar con la API: $e';
      });
    }
  }

  void copyToClipboard() {
    if (summary.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: summary));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resumen copiado al portapapeles')),
      );
    }
  }

  void clearAll() {
    setState(() {
      urlController.clear();
      summary = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Summarizer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'URL del video de YouTube',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final url = urlController.text;
                if (url.isNotEmpty) {
                  getSummary(url);
                }
              },
              child: Text('Obtener Resumen'),
            ),
            SizedBox(height: 16),
            Text(summary),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: copyToClipboard,
                  child: Text('Copiar Resumen'),
                ),
                ElevatedButton(
                    onPressed: clearAll,
                    child: Text('Borrar Todo'),
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
