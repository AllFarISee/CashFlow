import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneytrack/data/database.dart';
import 'package:moneytrack/data/transaction_with_category.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory; 
  const TransactionPage({Key? key, required this.transactionWithCategory}) : super(key : key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final AppDb database = AppDb(); 
  bool isExpense = true;
  late int type; 
  List<String> list = ["Makan", "Tiket Persib", "Futsal"];
  late String dropDownValue = list.first;
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  Category? selectedCategory;

  Future insert(int amount, DateTime date, String nameDetail, int categoryId) async{
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(TransactionsCompanion.insert(
      name: nameDetail, 
      category_id: categoryId, 
      transaction_date: date,
       amount: amount, 
       createdAt: now, 
       updatedAt: now));
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
    }
  Future update(
  int transactionId,
  int amount,
  int categoryId,
  DateTime transactionDate,
  String nameDetail
) async {
  return await database.updateTransactionRepo(
    transactionId,
    amount,
    categoryId,
    transactionDate,
    nameDetail,
  );
}

  @override
  void initState() {
    if (widget.transactionWithCategory != null){
      updateTransactionView(widget.transactionWithCategory!);
    } else{
      type = 2;
    }
    super.initState();
  }

  void updateTransactionView(TransactionWithCategory transactionWithCategory){
    amountController.text = transactionWithCategory.transaction.amount.toString();
    detailController.text = transactionWithCategory.transaction.name;
    dateController.text = DateFormat('dddd-MM-yyyy').format(transactionWithCategory.transaction.transaction_date);
    type = transactionWithCategory.category.type;
    (type == 2) ? isExpense = true : isExpense = false;
    selectedCategory = transactionWithCategory.category; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Add Transaction", style: TextStyle(color: Colors.white),)),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
              children: [
                CupertinoSwitch(
                  value: isExpense,
                  onChanged: (value) {
                    setState(() {
                      isExpense = value;
                      type = (isExpense) ? 2 : 1;
                      selectedCategory = null;
                    });
                  },
                  activeColor: Colors.red,
                  trackColor: Colors.green,
                ),
                Text(isExpense ? "Expense" : "Income", style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white),)
              ],
              ),
            ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(28),
            child: TextFormField(
              controller: amountController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Amount",
                labelStyle: TextStyle(color: Colors.grey)
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Text(
              "Category",
              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
            ),
          ),
          FutureBuilder<List<Category>>(
            future: getAllCategory(type),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting){
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else{
                if (snapshot.hasData){
                   if(snapshot.data!.length > 0){
                    selectedCategory = (selectedCategory == null) ? snapshot.data!.first : selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: DropdownButton<Category>(
                        value: (selectedCategory == null) ? snapshot.data!.first : selectedCategory,
                        isExpanded: true,
                        style: const TextStyle(color: Colors.grey),
                        dropdownColor: Colors.grey[850],
                        icon: Icon(Icons.arrow_downward),
                        items: snapshot.data!.map((Category item){
                          return DropdownMenuItem<Category>(
                            value: item,
                            child: Text(item.name),);
                      }).toList(),
                      onChanged: (Category ? value){
                        setState(() {
                          selectedCategory = value;
                        });
                      }),
                    );
                   } else{
                    return Center(
                    child: Text("No Data"),);
                   }
                } else{
                  return Center(
                    child: Text("No Data"),
                  );
                }
              }
            }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            child: TextFormField(
              readOnly: true,
              controller: dateController,
              style:  TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter Date",
                labelStyle: TextStyle(color: Colors.grey)),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context, 
                    initialDate: DateTime.now(), 
                    firstDate: DateTime(2020),  
                    lastDate: DateTime(2099));
                  if(pickedDate != null){
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

                    dateController.text = formattedDate;
                  }
                }
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(28),
            child: TextFormField(
              controller: detailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Detail",
                labelStyle: TextStyle(color: Colors.grey)
              ),
            ),
          ),
          SizedBox(height: 18),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                (widget.transactionWithCategory == null) 
                ? insert(
                  int.parse(amountController.text), 
                  DateTime.parse(dateController.text), 
                  detailController.text, 
                  selectedCategory!.id) 
                : await update(
                    widget.transactionWithCategory!.transaction.id,
                    int.parse(amountController.text), 
                    selectedCategory!.id, 
                    DateTime.parse(dateController.text), 
                    detailController.text);
                setState(() {
                });
                Navigator.pop(context, true);
              }, 
              child: Text("Save"), 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber
              )
              )
            )
          ],
        )),
      ),
    );
  }
}