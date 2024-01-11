import 'dart:convert';
import 'package:flutter/material.dart';
import 'parameters_screen.dart';
import 'profile_screen.dart';
import '../widgets/recipe_card.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  // Get list of URIs that match our search. These will be passed to the recipe card one by one.
  // List<String> savedRecipeURIs = [
  //   // List of saved recipe URIs...
  //   'http://www.edamam.com/ontologies/edamam.owl#recipe_4aeda14b435c3e99cea670755bd7cb51',
  //   'http://www.edamam.com/ontologies/edamam.owl#recipe_3ff9725681cefea1ddd589a59dd85ca1',
  //   // Add other URIs here
  // ];

  List<String> savedRecipeURIs = [];
  int currentIndex = 0; // Track the index of the currently displayed recipe
  bool loading = true; // New loading state

  @override
  void initState() {
    super.initState();
    _fetchSavedRecipeURIs();
  }

  Future<void> _fetchSavedRecipeURIs() async {
    // Your API endpoint for fetching recipe URIs
    final apiUrl = Uri.parse('https://api.edamam.com/api/recipes/v2?type=public&q=chicken&app_id=14943a2a&app_key=f9d27e0f49df8c4a0584e3f445e35aa6&diet=low-carb&health=egg-free&cuisineType=Italian&mealType=Lunch&imageSize=LARGE&random=true&field=uri');

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('hits') && jsonResponse['hits'] is List) {
          final List<dynamic> hits = jsonResponse['hits'];

          if (hits.isNotEmpty) {
            final List<String> uris = hits
                .map((hit) {
              final Map<String, dynamic> recipe = hit['recipe'];
              return recipe['uri'];
            })
                .where((uri) => uri != null)
                .cast<String>()
                .toList();

            setState(() {
              savedRecipeURIs = uris;
              print("savedRecipeURIs: $savedRecipeURIs");
              loading = false; // Data is loaded, set loading to false
            });
          } else {
            // Handle empty hits
            print('No recipes found in the response.');
            setState(() {
              loading = false; // No recipes found, set loading to false
            });
          }
        } else {
          // Handle invalid JSON structure
          print('Invalid JSON structure in the response.');
          setState(() {
            loading = false; // Invalid JSON structure, set loading to false
          });
        }
      } else {
        // Handle failed HTTP request
        print('Failed to fetch recipe URIs. Status code: ${response.statusCode}');
        setState(() {
          loading = false; // Failed HTTP request, set loading to false
        });
      }
    } catch (e) {
      // Handle exception
      print('An error occurred while fetching recipe URIs: $e');
      setState(() {
        loading = false; // Error occurred, set loading to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrambled Egg'),
        centerTitle: true, // Center-align the title text
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ParametersScreen()),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: GestureDetector(
                onTap: _expandInfo,
                child: RecipeCard(
                  recipeURI: savedRecipeURIs.isNotEmpty ? savedRecipeURIs[currentIndex] : '',
                  onDislike: _showNextRecipe, // Pass _showNextRecipe directly
                  onLike: _showNextRecipe,    // Pass _showNextRecipe directly
                ),
              ),
            ),
    );
  }


  // Function to show the next recipe card
  void _showNextRecipe() {
    setState(() {
      // Increment currentIndex to show the next recipe card
      currentIndex = (currentIndex + 1) % savedRecipeURIs.length;
    });
    print("Incremented currentIndex to $currentIndex");
  }

  // Function to expand recipe information
  void _expandInfo() {

  }
}