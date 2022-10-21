

import 'package:demo_investigacion/Model/PokemonModel.dart';
import 'package:flutter/material.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(ModalRoute.of(context)?.settings.arguments);
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    print(arguments);
    List<Pokemon> team = arguments['team'];

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Team"),),
      body: Padding(
        padding: EdgeInsets.all(2.0),
        child:
        ListView.builder(itemCount: team.length, itemBuilder: (ctx, i) {
          return ListTile(leading: Image.network(team[i].sprite), title: Text("$i - ${team[i].name}"),);
        }),
      ),
    );
  }
}
