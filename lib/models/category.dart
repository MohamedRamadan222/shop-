import 'package:flutter/material.dart';

enum Categories{
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
}
class Category{
final String name;
final Color category;

  const Category(this.name, this.category);
}