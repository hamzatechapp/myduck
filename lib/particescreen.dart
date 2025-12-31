import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myduck/model/productmodel.dart';
import 'package:http/http.dart' as http;

class particescreen extends StatefulWidget {
  const particescreen({super.key});

  @override
  State<particescreen> createState() => _particescreenState();

}

class _particescreenState extends State<particescreen> {

  late Future<ProductModel>  futuremodel;

@override
  void initState() {

    super.initState();
    futuremodel = getapiproduct();
  }


  Future<ProductModel> getapiproduct() async {

final response = await http.get(Uri.parse('http://dummyjson.com/products'));
if(response.statusCode==200) {
  final data = jsonDecode(response.body);

  return ProductModel.fromJson(data);
}
else {
  throw Exception('this is an error');

}
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ProductModel>(
          future: futuremodel,
          builder: (context,snapshot)
          {
        if(snapshot.connectionState==ConnectionState.waiting)
        {
          return Center(child: CircularProgressIndicator(),);
        }
        else if(snapshot.hasError){
          return Center(child: Text('${snapshot.error}'),);
        }
        else if(snapshot.hasData){
          final products = snapshot.data!.products;
          return ListView.builder(itemCount: products!.length,
              itemBuilder: (context,index)

          {              final product = products[index];


          return Column(children: [
              /// Basic Info
              Text("ID: ${product.id}"),
              Text("Title: ${product.title}"),
              Text("Description: ${product.description}"),
              Text("Category: ${product.category}"),
              Text("Brand: ${product.brand}"),
              Text("Price: \$${product.price}"),
              Text("Discount: ${product.discountPercentage}%"),
              Text("Rating: ${product.rating}"),
              Text("Stock: ${product.stock}"),

            ],);





          }

          );
        }
        return const SizedBox();




      },
      ),
    );
  }

}
