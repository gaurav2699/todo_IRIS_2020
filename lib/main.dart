import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hivetodoteach/todo_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
const String todoBoxName = "todo";

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<TodoModel>(todoBoxName);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum TodoFilter {ALL, COMPLETED, INCOMPLETED}

class _MyHomePageState extends State<MyHomePage> {
  CalendarController _calendarController;
  Box<TodoModel> todoBox;
  DateTime _dateTime;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  TodoFilter filter = TodoFilter.ALL;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dateTime=DateTime.now();
   _calendarController = CalendarController();
    todoBox = Hive.box<TodoModel>(todoBoxName);
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hive Todo"),
        actions: <Widget>[
          RaisedButton(
            child: Text('Change Date'),
            onPressed: (){
              showDatePicker(
                  context: context,
                  initialDate: _dateTime==null? DateTime.now(): _dateTime,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2222)
              ).then((date){
                setState(() {
                  _dateTime=date;
                });
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              ///Todo : Take action accordingly
              ///
              if(value.compareTo("All") == 0){
                setState(() {
                  filter = TodoFilter.ALL;
                });
              }else if (value.compareTo("Compeleted") == 0){
                setState(() {
                  filter = TodoFilter.COMPLETED;
                });
              }else{
                setState(() {
                  filter = TodoFilter.INCOMPLETED;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return ["All", "Compeleted", "Incompleted"].map((option) {
                return PopupMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList();
            },
          )
        ],
      ),

      body: Column(
        children: <Widget>[

          ValueListenableBuilder(

            valueListenable: todoBox.listenable(),

            builder: (context, Box<TodoModel> todos, _){

              List<int> keys;

              if(filter == TodoFilter.ALL){
                keys = todos.keys.cast<int>().toList();
              }else if(filter == TodoFilter.COMPLETED){
                keys = todos.keys.cast<int>().where((key) => todos.get(key).isCompleted).toList();
              }else{
                keys = todos.keys.cast<int>().where((key) => !todos.get(key).isCompleted).toList();
              }

              return ListView.builder(


                  itemBuilder:(_, index)
                  {

                    final int key = keys[index];
                    final TodoModel todo = todos.get(key);
                    return Dismissible(

                      key: UniqueKey(),

                      onDismissed: (DismissDirection direction){
                        setState(() {

                          todos.deleteAt(index);
                        });
                      },

                    child: _dateTime==todo.date ? ListTile(

                    title: Text(todo.title, style: TextStyle(fontSize: 24),),
                    subtitle: Text(todo.detail,style: TextStyle(fontSize: 20)),
                    leading: Text("$key"),

                    trailing: Icon(Icons.check, color: todo.isCompleted ? Colors.green : Colors.red,),

                      onTap: (){
                        showDialog(
                            context: context,
                            child: Dialog(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[

                                      FlatButton(
                                        child: Text("Mark as completed"),
                                        onPressed: () {
                                          TodoModel mTodo = TodoModel(
                                              title: todo.title,
                                              detail: todo.detail,
                                              isCompleted: true
                                          );

                                          todoBox.put(key, mTodo);

                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text("Edit"),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              child: Dialog(
                                                child: Container(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                     mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                          TextField(
                                          decoration: InputDecoration(hintText: 'new title'),
                                          controller: titleController,
                                          ),
                                          SizedBox(
                                          height: 8,
                                          ),
                                          TextField(
                                          decoration: InputDecoration(hintText: 'new details'),
                                          controller: detailController,
                                          ),
                                          SizedBox(
                                          height: 8,
                                          ),
                                          FlatButton(
                                          child: Text("Add Todo"),
                                          onPressed: () {
                                          ///Todo : Add Todo in hive
                                          final String title = titleController.text;
                                          final String detail = detailController.text;
                                          titleController.clear();
                                          detailController.clear(); 
                                          TodoModel todo = TodoModel(title: title, detail: detail, isCompleted: false);

                                          todoBox.putAt(index,todo);

                                          Navigator.pop(context);
                                          },
                                          )
                                          ],
                                          ),
                                          )
                                          )
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                )
                            )
                        );
                      },
                    ): new Container()
                    );
                  },

                  itemCount: keys.length,
                shrinkWrap: true,
              );
            },
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(
              context: context,
              child: Dialog(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(hintText: "Title"),
                          controller: titleController,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextField(
                          decoration: InputDecoration(hintText: "Detail"),
                          controller: detailController,
                        ),
                        SizedBox(
                          height: 8,
                        ),

                        FlatButton(
                          child: Text("Add Todo"),
                          onPressed: () {
                            ///Todo : Add Todo in hive
                            final String title = titleController.text;
                            final String detail = detailController.text;
                              titleController.clear();
                              detailController.clear();
                            TodoModel todo = TodoModel(title: title, detail: detail, isCompleted: false, date: _dateTime);

                            todoBox.add(todo);

                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  )
              )
          );
        },
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
