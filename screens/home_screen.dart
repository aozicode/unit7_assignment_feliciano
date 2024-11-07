import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Future<List<dynamic>> futureDigimons;

  @override
  void initState() {
    super.initState();
    futureDigimons = fetchDigimons(); 
  }

  
  Future<List<dynamic>> fetchDigimons() async {
    final url = Uri.parse('https://digi-api.com/api/v1/digimon?pageSize=20');
    final response = await http.get(url);

    if (response.statusCode == 200) {
     
      var data = json.decode(response.body);
      return data['data']; 
    } else {
      throw Exception('Failed to load Digimons');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digimons List"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureDigimons, 
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          
          if (snapshot.hasData) {
            var digimons = snapshot.data!;

           
            return ListView.builder(
              itemCount: digimons.length,
              itemBuilder: (context, index) {
                return ExpandedTile(
                  title: Text(digimons[index]['name']), 
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Type: ${digimons[index]['type'] ?? 'N/A'}'), 
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(digimons[index]['img']), // Display  image
                    ),
                  ],
                );
              },
            );
          }

          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

        
          return Center(child: Text('No Digimons available.'));
        },
      ),
    );
  }
}
