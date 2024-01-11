class Recipe {
  final String uri;
  final String recipeName;
  final String image;
  final String thumbnail;
  final String source;
  final String recipeUrl;
  final int? calories;
  final int? totalTime;
  final List<String>? ingredientLines;
  final List<String>? dietLabels;
  final List<String>? healthLabels;
  final List<String>? cautions;
  final List<String>? cuisineType;
  final List<String>? mealType;
  final List<String>? dishType;
  final Map<String, dynamic>? totalNutrients;
  final Map<String, dynamic>? dailyNutrients;

  Recipe({
    required this.uri,
    required this.recipeName,
    required this.image,
    required this.thumbnail,
    required this.source,
    required this.recipeUrl,
    required this.calories,
    required this.totalTime,
    this.ingredientLines,
    this.dietLabels,
    this.healthLabels,
    this.cautions,
    this.cuisineType,
    this.mealType,
    this.dishType,
    this.totalNutrients,
    this.dailyNutrients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final recipe = json['recipe']; // Directly access 'recipe' from the provided JSON

    if (recipe != null) {
      // print("recipe name: ${recipe['label']}");
      // print("large image: ${recipe['images']['LARGE']['url']}");
      // print("source: ${recipe['source']}");
      // print("calories: ${recipe['calories'].round()}");
      // print("totalNutrients: ${recipe['totalNutrients']}");


      return Recipe(
        uri: recipe['uri'],
        recipeName: recipe['label'] ?? '',
        image: recipe['images']['LARGE']['url'] ?? recipe['image'] ?? '',
        thumbnail: recipe['images']['THUMBNAIL']['url'],
        source: recipe['source'],
        recipeUrl: recipe['url'],
        calories: recipe['calories'].round(),
        totalTime: recipe['totalTime'].round(),
        ingredientLines: (recipe['ingredientLines'] as List<dynamic>?)?.map((ingredient) => ingredient.toString()).toList(),
        dietLabels: (recipe['dietLabels'] as List<dynamic>?)?.map((label) => label.toString()).toList(),
        healthLabels: (recipe['healthLabels'] as List<dynamic>?)?.map((label) => label.toString()).toList(),
        cautions: (recipe['cautions'] as List<dynamic>?)?.map((caution) => caution.toString()).toList(),
        cuisineType: (recipe['cuisineType'] as List<dynamic>?)?.map((type) => type.toString()).toList(),
        mealType: (recipe['mealType'] as List<dynamic>?)?.map((type) => type.toString()).toList(),
        dishType: (recipe['dishType'] as List<dynamic>?)?.map((type) => type.toString()).toList(),
        totalNutrients: recipe['totalNutrients'],
        dailyNutrients: recipe['totalDaily'],
      );
    }

    throw Exception('Invalid JSON structure or no recipe found');
  }
}