import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ledger',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: LedgerPage(),
    );
  }
}

class LedgerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("General Ledger",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            elevation: 7),
        drawer: NavigationDrawer(
            elevation: 0.5, children: [Column(children: <Widget>[])]),
        body: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      flex: 1,
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 5, 10),
                          child: ListView(
                                  controller: ScrollController(),
                                  children: [
                                    ListTile(
                                      textColor: Color(0xff000000),
                                      splashColor: Colors.red.shade700,
                                      onTap: () => print("button tapped"),
                                      titleTextStyle: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16),
                                      selected: true,
                                      title: Text("General Ledger"),
                                    ),
                                  ]))),
                  Flexible(flex: 6, child: Ledger())
                ])));
  }
}

enum TransactionType { dr, cr }

class Transaction {
  DateTime? date;
  String description;
  TransactionType? transactionType;
  double amount;
  double balance;

  Transaction(
      {this.date,
      this.description = "",
      this.transactionType,
      this.amount = 0.0,
      this.balance = 0.0});
}


class Ledger extends StatefulWidget {
  const Ledger({super.key});

  @override
  State<Ledger> createState() => _LedgerState();
}

class _LedgerState extends State<Ledger> {

  List<Transaction> _transactions = List<Transaction>.empty(growable: true);

  void _onSubmit(Transaction transaction) {
    setState(() {
      _transactions += [transaction];
    });
  }

  final TextStyle cellTextStyle = TextStyle(fontSize: 24);

  @override
  Widget build(BuildContext ctx) {
    TableRow tableHeader = TableRow(
        decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(15), bottom: Radius.zero)),
        children: ["DATE", "DESCRIPTION", "DR", "CR", "BALANCE"]
            .map((str) => TableCell(
                child: Text(str,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 22))))
            .toList());
    return Padding(
        padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                border: Border.all(width: 2, color: Colors.blueGrey.shade200),
                borderRadius: BorderRadius.circular(15)),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      flex: 7,
                      child: Table(
                          columnWidths: {
                            0: FlexColumnWidth(1.5),
                            1: FlexColumnWidth(5),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                            4: FlexColumnWidth(1)
                          },
                          border: TableBorder.all(
                            color: Colors.blueGrey.shade700,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15), bottom: Radius.zero),
                          ),
                          children: [
                            tableHeader,
                            ..._transactions.map((transaction) {
                              return TableRow(children: [
                                TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Align(alignment: Alignment(-0.25, 0), child: Text("${transaction.date!.toLocal().day}/${transaction.date!.toLocal().month}/${transaction.date!.toLocal().year}", style: cellTextStyle))),
                                TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Align(alignment: Alignment(-0.9, 0), child: Text(transaction.description, style: cellTextStyle))),
                                TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Align(alignment: Alignment(0.8, 0), child:Text(transaction.transactionType ==
                                        TransactionType.dr
                                    ? "(${transaction.amount.toStringAsFixed(2)})"
                                    : "", style: TextStyle(fontSize: 24, color: Colors.red.shade700)))),
                                TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Align(alignment: Alignment(0.8, 0), child:Text(transaction.transactionType ==
                                        TransactionType.cr
                                    ? transaction.amount.toStringAsFixed(2)
                                    : "", style: cellTextStyle))),
                                TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Align(alignment: Alignment(0.8, 0), child: Text(transaction.balance.toStringAsFixed(2), style: cellTextStyle)))
                              ]);
                            }).toList()
                          ])),
                  Flexible(
                      flex: 1,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                    child: TransactionForm(onSubmit: _onSubmit))
                              ])))
                ])));
  }
}

class TransactionForm extends StatefulWidget {
  final void Function(Transaction transaction)? onSubmit;

  TransactionForm({super.key, this.onSubmit});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TransactionType _transactionType = TransactionType.cr;
  TextEditingController _amountController = TextEditingController();

  double balance = 0.0;

  String description = "";
  double? _amount = 0.0;

  Transaction _transaction() {

      if (_transactionType == TransactionType.cr) {
        balance += _amount as double;
      } else if (_transactionType == TransactionType.dr) {
        balance -= _amount as double;
      }

    return Transaction(
        date: _date,
        description: _descriptionController.text,
        transactionType: _transactionType,
        amount: _amount as double,
        balance: balance
    );
  }

  void updateDate(DateTime? date) {
    
    setState(() {
        _date = date as DateTime;
      });
    _dateController.value = TextEditingValue(text: "${date!.toLocal().day}/${date.toLocal().month}/${date.toLocal().year}");
  }

  void updateTransactionType(TransactionType transactionType) => setState(() {
        _transactionType = transactionType;
      });

  @override
  void initState() {
    super.initState();
    _dateController.value = TextEditingValue(text: "${_date.toLocal().day}/${_date.toLocal().month}/${_date.toLocal().year}");
    _descriptionController.addListener(() {
      description = _descriptionController.text;
    });
    _amountController.addListener(() {
      setState(() {
        _amount = double.tryParse(_amountController.text);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
            color: Colors.blueGrey.shade100,
            borderRadius: BorderRadius.circular(15)),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                  child: TextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () async => updateDate(await showDatePicker(
                          context: context,
                          currentDate: _date,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(3000))),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          labelText: "Date"))),
              Flexible(
                  flex: 4,
                  child: TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          labelText: "Description"))),
              Flexible(
                  flex: 1,
                  child: TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixText: "\$ ",
                          labelText: "Amount"))),
              Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          flex: 1,
                          child: ListTile(
                              minVerticalPadding: 0,
                              dense: true,
                              title: Text("DR"),
                              leading: Radio(
                                  value: TransactionType.dr.toString(),
                                  groupValue: _transactionType.toString(),
                                  onChanged: (str) => updateTransactionType(
                                      TransactionType.dr)))),
                      Flexible(
                          flex: 1,
                          child: ListTile(
                              minVerticalPadding: 0,
                              dense: true,
                              title: Text("CR"),
                              leading: Radio(
                                  value: TransactionType.cr.toString(),
                                  groupValue: _transactionType.toString(),
                                  onChanged: (str) => updateTransactionType(
                                      TransactionType.cr)))),
                    ],
                  )),
              Flexible(
                  flex: 1,
                  child: ElevatedButton(
                      onPressed: () => widget.onSubmit!(_transaction()),
                      child: Text("Confirm")))
            ]));
  }
}
