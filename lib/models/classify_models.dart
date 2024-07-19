class ClassifyModels {
  String? status;
  String? predictedClass;
  double? probability;
  String? imagePath;

  ClassifyModels(
      {this.status, this.predictedClass, this.probability, this.imagePath});

  ClassifyModels.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    predictedClass = json['predicted_class'];
    probability = json['probability'];
    imagePath = json['image_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['predicted_class'] = this.predictedClass;
    data['probability'] = this.probability;
    data['image_path'] = this.imagePath;
    return data;
  }
}
