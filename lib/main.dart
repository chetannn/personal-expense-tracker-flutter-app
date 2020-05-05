import 'dart:math';

import './models/expense.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.green,
          canvasColor: Color(0xFFE2E8F0),
          fontFamily: 'Raleway',
          textTheme: ThemeData.light()
              .textTheme
              .copyWith(title: TextStyle(fontSize: 24, fontFamily: 'Raleway'))),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  List<Expense> expenses = [];

  final priceController = TextEditingController();
  final productNameController = TextEditingController();

  Widget _buildExpenseForm(BuildContext context) {
    return Container(
      height: 300,
      width: 350,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextField(
            controller: productNameController,
            style: TextStyle(
                fontSize: 20,
                fontFamily: Theme.of(context).textTheme.title.fontFamily),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              hintText: 'Product Name',
            ),
          ),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            style: TextStyle(
                fontSize: 20,
                fontFamily: Theme.of(context).textTheme.title.fontFamily),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              hintText: 'Price',
            ),
          ),
          InkWell(
            onTap: () {
              Random rand = new Random();
              int randomNumber = rand.nextInt(20);
              Expense expense = new Expense(
                  'cool' + randomNumber.toString(),
                  productNameController.text,
                  DateTime.now().toString(),
                  double.parse(priceController.text));

              Firestore.instance.collection('expenses').reference().add({
                'name': expense.name,
                'price': expense.price,
                'addedDate': expense.addedDate
              });
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 50),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    size: 24,
                    color: Colors.white,
                  ),
                  Text('ADD',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontFamily:
                              Theme.of(context).textTheme.title.fontFamily)),
                ],
              ),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20)),
            ),
          )
        ],
      ),
    );
  }

  Future<bool> _showExpenseDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            title: const Text('Add an Expense'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            children: <Widget>[_buildExpenseForm(ctx)],
          );
        });
  }

  Widget _buildExpenseCard(DocumentSnapshot document) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 5),
      padding: EdgeInsets.all(10),
      height: 60,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                child: Icon(
                  Icons.arrow_upward,
                ),
                backgroundColor: Colors.green,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                '${document['name']}',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              'RS. ${document['price']}',
              style: TextStyle(fontFamily: 'Raleway', color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text('Settings')),
        ]),
        appBar: AppBar(
          title: Text('Expense Tracker'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                _showExpenseDialog(context);
              },
            )
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection('expenses').snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) return const Text('Loading...');

                  return ListView.builder(
                    itemBuilder: (ctx, i) {
                      return _buildExpenseCard(snapshot.data.documents[i]);
                    },
                    itemCount: snapshot.data.documents.length,
                  );
                }
              ),
            )));
  }
}
