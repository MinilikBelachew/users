class PredictedPlaces {
  String? place_id;
  String? main_text;
  String? secondery_text;

  PredictedPlaces({
    this.main_text,this.place_id,this.secondery_text
});
  PredictedPlaces.fromJson (Map<String,dynamic>jsonData) {
    place_id=jsonData["place_id"];
    main_text=jsonData["structured_formatting"]["main_text"];
    secondery_text=jsonData["structured_formatting"]["secondery_text"];
  }

}