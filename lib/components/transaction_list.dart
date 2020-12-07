import 'package:expenses/components/transaction_item.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final void Function(String) onRemove;

  TransactionList(this.transactions, this.onRemove);

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
        ? LayoutBuilder(builder: (ctx, constraints) {
            return Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Nenhuma transação cadastrada',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 20),
                Container(
                  height: constraints.maxHeight * 0.6,
                  child: Image.asset(
                    'assets/images/waiting.png',
                    fit: BoxFit.cover,
                  ),
                )
              ],
            );
          })
        //SingleChildScrollView e ListView precisam de tamanho do pai definido.
        : ListView.builder(
            //Usado para carregar sob demanda.
            //O item builder vai receber um contexto (diferente do context do método build acima).
            //e um index (da lista).
            itemCount: transactions.length,
            itemBuilder: (ctx, index) {
              final tr = transactions[index];
              return TransactionItem(
                key: GlobalObjectKey(tr),
                tr: tr,
                onRemove: onRemove,
              );
            },
          );

    // ListView(
    //   children: transactions.map((tr) {
    //     return TransactionItem(
    //       key: ValueKey(tr.id),
    //       tr: tr,
    //       onRemove: onRemove,
    //     );
    //   }).toList(),
    // );
  }
}
