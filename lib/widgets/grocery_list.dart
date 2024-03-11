import 'dart:convert';
import 'package:fleehshop/data/categores.dart';
import 'package:fleehshop/models/grocery_item.dart';
import 'package:fleehshop/widgets/new_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  void _loadData() async {
    final Uri url = Uri.https(
        'flutterfoleah-default-rtdb.firebaseio.com', 'shopping-list.json');
    try{
    final http.Response res = await http.get(url).catchError((_)
    {
      return http.Response('',400);
    }
    );
    if (res.statusCode >= 400) {
      setState(() {
        _error = 'Field to fetch data. pleas rty again later';
      });
      return;
    }
    if(json.decode(res.body )== null){
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> loadedData = jsonDecode(res.body);
    final List<GroceryItem> loadedItems = [];
    for (var item in loadedData.entries) {
      final Map<String, dynamic> itemData = item.value;
      loadedItems.add(GroceryItem(
        id: item.key,
        name: itemData['name'],
        quantity: itemData['quantity'],
        category: categories.entries
            .firstWhere((element) => element.value.name == itemData['category'])
            .value,
      ));
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    }}catch(err){
      setState(() {
        _error = 'Field to fetch data. pleas rty again later';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No Item Right Now '),
    );
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(_groceryItems[index].id),
                onDismissed: (_) {
                  _removeItem(_groceryItems[index]);
                },
                child: ListTile(
                  title: Text(_groceryItems[index].name),
                  leading: Container(
                    height: 24,
                    width: 24,
                    color: _groceryItems[index].category.category,
                  ),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                ),
              ));
    }
    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('mohamed Ramadan'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final Uri url = Uri.https('flutterfoleah-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('cant delet this item'),
      ));
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  _addItem() async {
    final newItem =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (ctx) => const NewItem(),
    ));
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }
}
