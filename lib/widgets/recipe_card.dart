import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeCard extends StatefulWidget {
  final String recipeURI;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  RecipeCard({
    required this.recipeURI,
    required this.onLike,
    required this.onDislike,
  });

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  late Future<Recipe> recipeDetails;

  @override
  void initState() {
    super.initState();
    recipeDetails = fetchRecipeDetails(widget.recipeURI);
  }

  Future<Recipe> fetchRecipeDetails(String uri) async {
    final formattedURI = Uri.encodeFull(uri); // Encode the URI

    final apiUrl = Uri.https(
      'api.edamam.com',
      '/api/recipes/v2/by-uri',
      {'type': 'public', 'uri': formattedURI, 'app_id': '14943a2a', 'app_key': 'f9d27e0f49df8c4a0584e3f445e35aa6'},
    );

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('hits') && jsonResponse['hits'].isNotEmpty) {
          final recipeData = jsonResponse['hits'][0];

          if (recipeData != null) {
            Recipe recipe = Recipe.fromJson(recipeData);
            return recipe;
          } else {
            throw Exception('Recipe data is null');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch recipe');
      }
    } catch (e) {
      throw Exception('Failed to fetch recipe: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Recipe>(
      future: fetchRecipeDetails(widget.recipeURI),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the data is being fetched, show a loading indicator
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If there's an error fetching the data, display an error message
          return const Center(child: Text('Error fetching recipe details'));
        } else if (snapshot.hasData) {
          // If data is available, use it to construct your card UI
          Recipe recipe = snapshot.data!;
          return Card(
            margin: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: AspectRatio(
                      aspectRatio: 1, // Square aspect ratio
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
                        child: Image.network(
                          recipe.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.recipeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            recipe.totalTime != null && recipe.totalTime! > 0
                                ? Column(
                                  children: [
                                    Text(
                                      '~${recipe.totalTime} min',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                  ],
                                )
                                : const SizedBox(),
                                Text(
                                  '${recipe.cuisineType?.isNotEmpty == true ? recipe.cuisineType![0] : ''} - ${recipe.mealType?.isNotEmpty == true ? recipe.mealType![0] : ''}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8.0),

                                // Render ingredient list as bullet points
                                if (recipe.ingredientLines?.isNotEmpty == true)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ingredients:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      for (String ingredient in recipe.ingredientLines!)
                                        Text(
                                          '• $ingredient',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 32.0,
                            color: Colors.red,
                          ),
                          onPressed: widget.onDislike, // Call the dislike callback
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            size: 32.0,
                            color: Colors.green,
                          ),
                          onPressed: widget.onLike, // Call the like callback
                        ),
                      ),
                    ],
                  ),

                ],
              ),
          );
        } else {
          // If there's no data, show a placeholder or empty container
          return const SizedBox();
        }
      },
    );
  }
}