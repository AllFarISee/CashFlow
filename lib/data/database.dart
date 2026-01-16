import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:moneytrack/data/transaction_with_category.dart';
import 'package:path_provider/path_provider.dart';
import 'package:moneytrack/data/category.dart';
import 'package:moneytrack/data/transaction.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Transactions])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ================= CATEGORY =================

  Future<List<Category>> getAllCategoryRepo(int type) {
    return (select(categories)..where((tbl) => tbl.type.equals(type))).get();
  }

  Future<void> updateCategoryRepo(int id, String name) {
    return (update(categories)..where((tbl) => tbl.id.equals(id))).write(
      CategoriesCompanion(name: Value(name)),
    );
  }

  Future<void> deleteCategoryRepo(int id) {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  // ================= TRANSACTION =================

  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final query = select(transactions).join([
      innerJoin(
        categories,
        categories.id.equalsExp(transactions.category_id),
      )
    ])
      ..where(transactions.transaction_date.isBetweenValues(start, end));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }

  Future<void> updateTransactionRepo(
    int id,
    int amount,
    int categoryId,
    DateTime transactionDate,
    String nameDetail,
  ) {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
      TransactionsCompanion(
        name: Value(nameDetail),
        amount: Value(amount),
        category_id: Value(categoryId),
        transaction_date: Value(transactionDate),
      ),
    );
  }
}

// ================= DATABASE CONNECTION =================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
