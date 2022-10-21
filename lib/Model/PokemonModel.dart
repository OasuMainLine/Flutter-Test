class Pokemon {
  int id;
  String name;
  String sprite;

  Pokemon(this.id, this.name, this.sprite);

  Pokemon.fromJSON(Map<String, dynamic> json) : id = json['id'], name = json['name'], sprite = json['sprite'];
}