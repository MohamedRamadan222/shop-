import 'dart:convert';
import 'package:fleehshop/data/categores.dart';
import 'package:fleehshop/models/grocery_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/category.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var enteredName = '';
  int enteredQuantity = 0;
  var selectedCategory = categories[Categories.fruit]!;
  bool _isLoading = false;
  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final Uri url = Uri.https(
          'flutterfoleah-default-rtdb.firebaseio.com', 'shopping-list.json');
      http.post(url, headers: {'Content-Type': 'application/json',},
        body: json.encode({
          'name': enteredName,
          'quantity': enteredQuantity,
          'category': selectedCategory.name,
        }),).then((res) {
        final Map<String, dynamic> resData = json.decode(res.body);
        if (res.statusCode == 200) {
          Navigator.of(context).pop(GroceryItem(id: resData['name'],
            name: enteredName,
            quantity: enteredQuantity,
            category: selectedCategory,));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Add new item'),),
      body: Padding(padding: const EdgeInsets.all(12),
        child: Form(key: _formKey,
          child: Column(children: [
            TextFormField(onSaved: (newValue) {
              enteredName = newValue!;
            },
                initialValue: '1',
                decoration: const InputDecoration(
                  hintMaxLines: 50, labelText: 'Name',),
                validator: (String? value) {
                  if (value == null || value.isEmpty || value
                      .trim()
                      .length <= 1 || value
                      .trim()
                      .length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  return null;
                }),
            Row(crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: TextFormField(onSaved: (newValue) {
                  enteredQuantity = int.parse(newValue!);
                },
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintMaxLines: 50, labelText: 'quantity',),
                    validator: (String? value) {
                      if (value == null || value.isEmpty || int.tryParse(
                          value) == null || int.tryParse(value)! <= 0) {
                        return 'Must be a valid ,positive number';
                      }
                      return null;
                    }),),
                const SizedBox(width: 8,),
                Expanded(child: DropdownButtonFormField(value: selectedCategory,
                    items: [
                      for (final category in categories
                          .entries)DropdownMenuItem(
                        value: category.value, child: Row(children: [
                        Container(
                          height: 16, width: 16, color: category.value.category,),
                        const SizedBox(width: 6,),
                        Text(category.value.name),
                      ],),)
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    })),
              ],),
            const SizedBox(height: 16,),
            Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: _isLoading ? null : () {
                  _formKey.currentState!.reset();
                }, child: const Text('Reset')),
                ElevatedButton(onPressed: _saveItem,
                    child: _isLoading ? const SizedBox(height: 16,
                      width: 16,
                      child: CircularProgressIndicator(),) : const Text(
                        'Add Item')),
              ],)
          ],),),),);
  }
}