class CampaignStage {
  CampaignStage({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.goldReward,
    required this.experienceReward,
  });

  final String id;
  final String title;
  final String description;
  final int difficulty;
  final int goldReward;
  final int experienceReward;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'difficulty': difficulty,
        'goldReward': goldReward,
        'experienceReward': experienceReward,
      };

  factory CampaignStage.fromJson(Map<String, dynamic> json) {
    return CampaignStage(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as int,
      goldReward: json['goldReward'] as int,
      experienceReward: json['experienceReward'] as int,
    );
  }
}
