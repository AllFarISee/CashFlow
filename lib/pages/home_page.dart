import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneytrack/data/database.dart';
import 'package:moneytrack/data/transaction_with_category.dart';
import 'package:moneytrack/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key : key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        child: Icon(Icons.download, color: Colors.green),
                        decoration: BoxDecoration(
                          color: Colors.black, 
                          borderRadius: BorderRadius.circular(8))
                          ),
                          SizedBox(width: 15,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Income",
                                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16)), 
                              Text("Rp.3.800.000",
                                style: GoogleFonts.montserrat(color: Colors.black))
                                ],)
                    ],),
                    Row(children: [
                      Container(
                        child: Icon(Icons.upload, color: Colors.red),
                        decoration: BoxDecoration(
                          color: Colors.black, 
                          borderRadius: BorderRadius.circular(8))
                          ),
                          SizedBox(width: 15,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Outcome",
                                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16)), 
                              Text("Rp.3.800.000",
                                style: GoogleFonts.montserrat(color: Colors.black))
                                ],)
                    ],)
                  ],
                ),
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(16)
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Transactions", 
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                } else{
                  if (snapshot.hasData){
                    if (snapshot.data!.length > 0){
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              color: Colors.grey[900],
                              child: ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.delete),
                                    SizedBox(width: 10),
                                    IconButton(icon: Icon(Icons.edit), onPressed: (){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransactionPage(transactionWithCategory: snapshot.data![index])));
                                    },)
                                    ],
                                  ),
                                  title: Text("Rp." + snapshot.data![index].transaction.amount.toString(), style: TextStyle(color: Colors.white),),
                                  subtitle: Text(snapshot.data![index].category.name + "(" + snapshot.data![index].transaction.name + ")", style: TextStyle(color: Colors.white),),
                                  leading: Container(
                                            child: (snapshot.data![index].category.type == 2) ? 
                                            Icon(Icons.upload, color: Colors.red) : 
                                            Icon(Icons.download, color: Colors.green),
                                            decoration: BoxDecoration(
                                              color: Colors.black, 
                                              borderRadius: BorderRadius.circular(8))
                                              ),
                              ),
                            ),
                          );
                        });
                    } else{
                      return Center(child: Text("Empty Data"),);
                    }
                  } else{
                    return Center(child: Text("No Data"),);
                  }
                }
            }),
      ],)
      ),
    );
  }
}