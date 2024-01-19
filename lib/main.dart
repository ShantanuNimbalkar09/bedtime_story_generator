import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});





  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  String generatedStory="Tap below to generate Story";

  Future<void>generatestory(String inputText)async{
    final apiUrl='https://api-inference.huggingface.co/models/Tincando/fiction_story_generator';

    final response =await http.post(
     Uri.parse(apiUrl),
  headers: {'Authorization': 'Bearer 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'},
  body: jsonEncode({'inputs': inputText}),
    );

   if (response.statusCode == 200) {
    try {
     final List<dynamic> dataList = jsonDecode(response.body);

      if (dataList.isNotEmpty && dataList[0] is Map<String, dynamic>) {

         final String rawGeneratedText = dataList[0]['generated_text'];
          final String cleanedGeneratedText = cleanGeneratedText(rawGeneratedText);
         
        // Check if the first element is a Map
        setState(() {
          // generatedStory = dataList[0]['generated_text'];
          generatedStory = cleanedGeneratedText;
        
          print(generatedStory);
        });
      } else {
        print('Unexpected data format: $dataList');
      }
    } catch (e) {
      print('Error decoding response: $e');
    }
    }else if(response.statusCode == 503){
      final errorMessage = 'Error ${response.statusCode}: ${response.body}';
       final Map<String, dynamic> errorData = jsonDecode(response.body);
  
      final double estimatedTime = errorData['estimated_time'];
    print('Model is loading. Retrying after ${estimatedTime} seconds.');
    await Future.delayed(Duration(seconds: estimatedTime.toInt()));
  print(errorMessage);
      setState(() {
        generatedStory='Error generating story.please try again';
      });
    }

    
  }
  
  String cleanGeneratedText(String rawText) {
    // Remove unwanted tokens, you can customize this based on your specific needs
    final cleanedText = rawText
        .replaceAll('[ WP ] <sep>', '')
        .replaceAll('[ WP ]', '')
        .replaceAll('<sep>', '')
        .trim();
    return cleanedText;
  }
  
  
  @override
  Widget build(BuildContext context) {
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(generatedStory,textAlign: TextAlign.center),
          SizedBox(height: 20),
          ElevatedButton(onPressed: ()=>generatestory('once upon a time'), 
          child:Text('Generate Story')
          ),
        ],
      ),
    );
  }
}

