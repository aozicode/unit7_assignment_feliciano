import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Digimon {
  final String name;
  final String imageUrl;

  Digimon({required this.name, required this.imageUrl});

  factory Digimon.fromJson(Map<String, dynamic> json) {
    return Digimon(
      name: json['name'] ?? 'Unknown',  // If ever the name is unknown
      imageUrl: json['image'] ?? '',    // If ever image is missing
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Digimon>> futureDigimons;

  Future<List<Digimon>> fetchDigimons() async {
    final response = await http.get(Uri.parse('https://digi-api.com/api/v1/digimon?pageSize=20'));

    if (response.statusCode == 200) {
      print('API Response: ${response.body}');  // Check raw response
      
      try {
        final jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['content'];  // Change content instead of data
        
        return data.map((json) => Digimon.fromJson(json)).toList();
      } catch (e) {
        print('Error parsing JSON: $e');  
        throw Exception('Failed to parse Digimons');
      }
    } else {
      throw Exception('Failed to load Digimons');
    }
  }

  @override
  void initState() {
    super.initState();
    futureDigimons = fetchDigimons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder<List<Digimon>>(
        future: futureDigimons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Missing Digimons!'));
          } else {
            final digimons = snapshot.data!;

            return ListView.builder(
              itemCount: digimons.length,
              itemBuilder: (context, index) {
                final digimon = digimons[index];

                // Use a placeholder image if theres no image
                final imageUrl = digimon.imageUrl.isNotEmpty
                    ? digimon.imageUrl
                    : 'https://via.placeholder.com/150';

                return ListTile(
                  leading: Image.network(imageUrl),
                  title: Text(digimon.name),
                );
              },
            );
          }
        },
      ),
    );
  }
}
