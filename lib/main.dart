import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MaterialApp(home: Habits()));
class Habits extends StatefulWidget {
  const Habits({super.key});
  @override
  State<Habits> createState() => _HabitsState();
}
class _HabitsState extends State<Habits> {
  final input = TextEditingController();
  Map<String,String> habits = {};
  SharedPreferences? prefs;
  String get today => DateTime.now().toIso8601String().substring(0,10);
  @override
  void initState(){super.initState();load();}
  Future<void> load() async {
    final p=await SharedPreferences.getInstance();
    if(!mounted)return;
    setState((){prefs=p;habits=Map<String,String>.from(jsonDecode(p.getString('habits')??'{}'));});
  }
  void save(){prefs?.setString('habits',jsonEncode(habits));}
  @override
  void dispose(){input.dispose();super.dispose();}
  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Habit Tracker')),
    body:prefs==null?const Center(child:CircularProgressIndicator()):Column(children:[
      Padding(padding:const EdgeInsets.all(16),child:Row(children:[
        Expanded(child:TextField(controller:input,decoration:const InputDecoration(labelText:'New habit'))),
        IconButton(icon:const Icon(Icons.add),onPressed:(){final name=input.text.trim();if(name.isNotEmpty&&!habits.containsKey(name)){setState(()=>habits[name]='');input.clear();save();}})
      ])),
      Text('${habits.values.where((d)=>d==today).length} / ${habits.length} completed today'),
      Expanded(child:ListView(children:habits.keys.map((name)=>CheckboxListTile(
        title:Text(name),value:habits[name]==today,onChanged:(v){setState(()=>habits[name]=v==true?today:'');save();},
        secondary:IconButton(icon:const Icon(Icons.delete_outline),onPressed:(){setState(()=>habits.remove(name));save();})
      )).toList()))
    ]));
}
