import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneytrack/pages/home_page.dart';
import 'package:moneytrack/pages/category_page.dart';
import 'package:moneytrack/pages/transaction_page.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MainPage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex = 0;
  @override
  void initState() {
    updateView(0, DateTime.now());
    super.initState();
  }

  void onTapTapped(int index){
    setState(() {
      currentIndex = index;
    });
  }
  
  void updateView(int index, DateTime? date){
    setState(() {
      if (date != null){
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }
      currentIndex = index;
      _children = [HomePage(selectedDate: selectedDate,), CategoryPage()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: (currentIndex == 0) ? CalendarAppBar(
        backButton: false,
        accent: Colors.black,
        onDateChanged: (value){
          setState(() {
            selectedDate = value;
            updateView(0, selectedDate);
          });
        },
        firstDate: DateTime.now().subtract(Duration(days: 140)),
        lastDate: DateTime.now(),
      ) : PreferredSize(
          child: Container(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
          child: Text("Categories", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20))
        )),
        preferredSize: Size.fromHeight(100)),

      floatingActionButton: Visibility(
        visible: (currentIndex == 0) ? true : false,
        child: FloatingActionButton(
          onPressed: (){
            Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TransactionPage(transactionWithCategory: null,),))
            .then((value){
              setState(() {});
            });
          },
          backgroundColor: Colors.amber,
          child: Icon(Icons.add, color: Colors.black),
        ),
      ),

      body: _children[currentIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: (){
              updateView(0, DateTime.now());
            }, icon: Icon(Icons.home, color: Colors.white)),
            SizedBox(width: 20,), 
            IconButton(onPressed: (){
              updateView(1, null);
            }, icon: Icon(Icons.list, color: Colors.white)),
          ],
      ),
      )
    );
  }
}