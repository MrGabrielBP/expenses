import 'dart:math';

import 'package:expenses/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatefulWidget {
  final Transaction tr;
  final void Function(String p1) onRemove;

  const TransactionItem({
    Key key, //Identificar um widget unicamente dentro de um determinado contexto.
    @required this.tr,
    @required this.onRemove,
  }) : super(key: key); //Chamando o construtor da classe pai.

  @override
  _TransactionItemState createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  //Nesse contexto o static indica que aquela lista de cores vai ser a mesma
  //pra classe em si, ou seja, ela não vai gerar uma lista nova para cada instância da classe.
  static const colors = [
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.blue,
    Colors.black,
  ];

  Color _backgroundColor;

  @override
  void initState() {
    super.initState();
    int i = Random().nextInt(5);
    _backgroundColor = colors[i];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 5,
      ),
      child: ListTile(
        //A widget to display before the title.
        leading: CircleAvatar(
          backgroundColor: _backgroundColor,
          radius: 30,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: FittedBox(
              child: Text('R\$${widget.tr.value.toStringAsFixed(2)}'),
            ),
          ),
        ),
        title: Text(
          '${widget.tr.title}',
          style: Theme.of(context).textTheme.headline6,
        ),
        subtitle: Text(
          DateFormat('d MMM y').format(widget.tr.date),
        ),
        //exclusão
        trailing: MediaQuery.of(context).size.width > 480
            ? FlatButton.icon(
                icon: const Icon(Icons.delete),
                onPressed: () => widget.onRemove(widget.tr.id),
                label: const Text('Excluir'),
                textColor: Theme.of(context).errorColor,
              )
            : IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).errorColor,
                onPressed: () => widget.onRemove(widget.tr.id),
              ),
      ),
    );
  }
}
