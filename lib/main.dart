import 'package:expenses/components/chart.dart';
import 'package:expenses/components/transaction_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'components/transaction_list.dart';
import 'models/transaction.dart';
import 'dart:io';

main() => runApp(ExpensesApp());

class ExpensesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Dessa forma o app funcionararia somente em modo retrato.
    /*  SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
    ]); */
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData(
          primarySwatch: Colors.purple,
          //MaterialColor - range de cores do mesmo tipo.
          accentColor: Colors.amber, //cor de realce (secondary)
          fontFamily: 'Quicksand',
          //ThemeData.light(): dá o tema padrão azul do Flutter
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                button: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// Mixins são recursos presentes no Dart que nos permitem adicionar um conjunto
// de “características” a uma classe sem a necessidade de utilizar uma herança.
class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final List<Transaction> _transactions = [];
  bool _showChart = false;

  @override
  initState() {
    super.initState();
    //Adicionando um observer para quando acontecer um evento.
    WidgetsBinding.instance.addObserver(this); //instancia atual
    //Registrar essa classe com um observer para ser notificado quando houver mudanças nesse estado da aplicação.
  }

  //Essa função é chamada quando muda o ciclo de vida da aplicação
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }
// inactive, paused, resumed, suspended

  @override
  dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  //Uma solução para IconButton no IOS
  Widget _getIconButton(IconData icon, Function fn) {
    return Platform.isIOS
        //semelhante ao botao
        ? GestureDetector(onTap: fn, child: Icon(icon))
        : IconButton(icon: Icon(icon), onPressed: fn);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    bool _isLandscape = mediaQuery.orientation == Orientation.landscape;
    //Pega a orientação

    final IconData iconList =
        Platform.isIOS ? CupertinoIcons.refresh : Icons.format_list_bulleted;

    final IconData chartList =
        Platform.isIOS ? CupertinoIcons.refresh : Icons.bar_chart;

    final actions = <Widget>[
      if (_isLandscape)
        _getIconButton(
          _showChart ? iconList : chartList,
          () {
            setState(() {
              _showChart = !_showChart;
            });
          },
        ),
      _getIconButton(
        Platform.isIOS ? CupertinoIcons.add : Icons.add,
        () => _openTransactionFormModal(context),
      ),
    ];

    //todo appBar impleta essa interface PreferredSizeWidgt
    final PreferredSizeWidget appBar = Platform.isIOS
        //semelhante ao AppBar()
        ? CupertinoNavigationBar(
            //semelhante ao title
            middle: const Text('Despesas Pessoais'),
            //Fica no final. Semelhante ao actions
            trailing: Row(
              //vai ocupar o mínimo espaço (tamanho do icone).
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
          )
        : AppBar(
            title: const Text('Despesas Pessoais'),
            actions: actions,
          );

    //Tamanho total da tela,
    final availableHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;
    //menos o tamanho da appBar, menos a altura do status bar.

    //creates a widget that avoid operating system intefaces.
    final bodyPage = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // if (_isLandscape)
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Text('Exibir Gráfico'),
            //       //Adapta o design entre cupertino e material
            //       Switch.adaptive(
            //         activeColor: Theme.of(context).accentColor,
            //         value: _showChart,
            //         onChanged: (value) {
            //           setState(() {
            //             _showChart = value;
            //           });
            //         },
            //       ),
            //     ],
            //   ),
            if (_showChart || !_isLandscape)
              Container(
                height: availableHeight * (_isLandscape ? 0.8 : 0.3),
                child: Chart(_recentTransactions),
              ),
            if (!_showChart || !_isLandscape)
              Container(
                height: availableHeight * (_isLandscape ? 1.0 : 0.7),
                child: TransactionList(_transactions, _removeTransaction),
              ),
          ],
        ),
      ),
    );

    return Platform.isIOS
        //cupertino style
        ? CupertinoPageScaffold(
            //semelhante ao appBar
            navigationBar: appBar,
            child: bodyPage,
          )
        : Scaffold(
            //AppBar extraído para uma variável.
            appBar: appBar,
            body: bodyPage,
            //Verifica se a plataforma é IOS. Importar dart:io.
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    onPressed: () => _openTransactionFormModal(context),
                    child: Icon(Icons.add),
                  ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
