import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class Model {
  String name='Default name';
  Image dressType = Image.asset('graphics/images/t-shirt.png',
    height: 80,
    width: 80,);

  //Model(this.name, this.dressType);
  Model();
}


class MyModels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)!.settings.arguments;
    final modelsList = <Model> [Model(), Model(), Model(), Model(), Model()];
    Future<XFile?> picture;


    Widget getModelsWidgetList(List<Model> myModelList)
    {
      List<Widget> list = <Widget>[];
      for(var i = 0; i < myModelList.length; i++){
        list.add(
          Container(
              margin:EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                color: Colors.white30,
                child: InkWell(
                  onTap: () => print("ciao"),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                        child: modelsList.elementAt(0).dressType,
                      ),

                      ListTile(
                        title: Text(modelsList.elementAt(0).name),
                      ),
                    ],
                  ),
                ),
              )
          ),
        );
      }
      return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: list
          );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Models'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getModelsWidgetList(modelsList),
            ],
          )
        ),
      ),
      floatingActionButton: Container(
        height: 100.0,
        width: 100.0,
        margin: const EdgeInsets.only(bottom: 20.0),
        child: FittedBox(
          child: FloatingActionButton(
            highlightElevation: 30,
            child : Image.asset('graphics/images/appareil-photo.png',
              height: 40,
              width: 40,),
            onPressed: () =>
              Navigator.pushNamed(
              context,
              '/camera',
              //arguments: ScreenArguments('arg-title', 'arg-message'),
              arguments: <String, String>{
                'title':"Deuxième page",
              },
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(

        )

      ),
    );
  }
}