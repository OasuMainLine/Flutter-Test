import 'dart:convert';

import 'package:demo_investigacion/Model/PokemonModel.dart';
import 'package:demo_investigacion/Pages/TeamPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:fluttertoast/fluttertoast.dart';
void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: "Pokemon Team Builder",
      initialRoute: "/",
      routes:
      {
        "/": (context) => const PokemonHome(),
        "/team": (context) => const TeamPage(),
      }
    );
  }
}

class PokemonHome extends StatefulWidget {
  const PokemonHome({Key? key}) : super(key: key);

  @override
  State<PokemonHome> createState() => _PokemonHomeState();
}

class _PokemonHomeState extends State<PokemonHome> {


  List<Pokemon> pokemonList = [];
  List<Pokemon> tempList = [];
  List<Pokemon> team = [];
  int loadCount = 0;
  bool error = false;

  void setError(){
    setState(() => {
      error = true
    });
  }


  Future<List<Pokemon>> getPokemonList() async{

      final response = await get(Uri.parse("https://pokeapi.co/api/v2/pokemon?limit=100"));

      if(response.statusCode == 200){
          Map<String, dynamic> json = jsonDecode(response.body);

          List<dynamic> jsonList = json['results'];
          List<Pokemon> pokemonList = [];

          for (var element in jsonList)  {
              Map<String, dynamic> pokemonJson = Map();

              pokemonJson['name'] = element['name'];

              final pokedexEntryResponse = await get(Uri.parse(element['url']));

              if(pokedexEntryResponse.statusCode == 200) {
                Map pokemonInfo = jsonDecode(pokedexEntryResponse.body);
                pokemonJson['id'] = pokemonInfo['id'];
                pokemonJson['sprite'] = pokemonInfo['sprites']['front_default'];

                pokemonList.add(Pokemon.fromJSON(pokemonJson));
                setState(() => loadCount++);
              } else {
                setError();
                return [];
              }
          }

          return pokemonList;
      } else {
        setError();
        return [];
      }
  }

  @override
  void initState(){
    super.initState();

    getPokemonList().then((value) => {
      setState(() {
        pokemonList.addAll(value);
        tempList.addAll(value);
    })
    });
  }

  void onChange(String text, TextEditingController controller) async{

    if(pokemonList.isEmpty){
        return;
      }

      if(text.trim().isEmpty){
        setState( () {
          pokemonList = tempList;
        });
      }
      List<Pokemon> newList = pokemonList.where((element) => element.name.toLowerCase().contains(text.trim().toLowerCase())).toList();

      setState(() {
        pokemonList = newList;
      });
  }

  void onFavorite(int index){
      Pokemon pokemon = pokemonList[index];
      if((team.length + 1) > 6 && team.indexOf(pokemon) == -1){
        Fluttertoast.showToast(msg: "Solo se pueden unir 6 pokemon al equipo!");
        return;
      }


      setState(() {
        if(team.indexOf(pokemon) > -1){
          team.remove(pokemon);
        } else {
          team.add(pokemon);
        }

      });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Pokemon Team Builder"), actions: [IconButton(onPressed: () => Navigator.pushNamed(context, '/team', arguments: {"team": team}), icon: Icon(Icons.list_alt_rounded))]),
        body: Column(
          children: [
              SearchInput(onChange: onChange,),

              Expanded(child:
                  Builder(builder: (ctx) {
                    if(pokemonList.isEmpty){
                      return Text("Cargando datos $loadCount / 100");
                    } else if(error){
                      return Text("Hubo un error al cargar los datos");
                    }

                    return ListView.builder(itemCount: pokemonList.length, itemBuilder: (ctx, i) {
                        Pokemon pokemon = pokemonList[i];

                        return ListTile(leading: Image.network(pokemon.sprite), title: Text("#${pokemon.id} ${pokemon.name}"), trailing: IconButton(icon: Icon(team.indexOf(pokemon) > -1? Icons.favorite : Icons.favorite_border), onPressed: () => onFavorite(i),),);
                    });
                  },)
              )
          ],
        ),
    );
  }
}

class SearchInput extends StatelessWidget {

  TextEditingController controller = TextEditingController();
  final void Function(String, TextEditingController) onChange;

  SearchInput({Key? key, required this.onChange}) : super(key: key);


  void onChanged(String text){
    onChange(text, controller);
  }
  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Theme.of(context).primaryColor,
      child: Padding(padding: EdgeInsets.all(4.0), child: ListTile(
        leading: const Icon(Icons.search),
        title: TextField(
          onChanged: onChanged,
          decoration: const InputDecoration(hintText: "Buscar...", border: InputBorder.none),
        ),
      )),
    );
  }
}


