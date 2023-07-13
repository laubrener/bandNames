import 'dart:io';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:band_names/models/band.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];
  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on("active-bands", _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(payload) {
    bands = (payload as List).map((e) => Band.fromMap(e)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off("active-bands");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "BandNames",
            style: TextStyle(color: Colors.black87),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.online
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [
          _showPieChart(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, index) => _bandTile(bands[index])),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id!),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        socketService.socket.emit("delete-band", {"id": band.id});
      },
      background: Container(
          color: Colors.red,
          padding: const EdgeInsets.only(left: 10),
          child: const Align(
              alignment: Alignment.centerLeft, child: Icon(Icons.delete))),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name!.substring(0, 2)),
        ),
        title: Text(band.name!),
        trailing: Text(
          "${band.votes}",
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {
          socketService.socket.emit("vote-band", {"id": band.id});
        },
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("New band name:"),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  elevation: 5,
                  textColor: Colors.blue,
                  onPressed: () => addBandToList(textController.text),
                  child: const Text("Add"),
                )
              ],
            );
          });
    } else {
      return showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: const Text("New band name:"),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text("Add"),
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Dismiss")),
              ],
            );
          });
    }
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketService.socket.emit("add-band", {"name": name});
      setState(() {});
    }
    Navigator.pop(context);
  }

  _showPieChart() {
    Map<String, double> dataMap = {};
    if (bands.length > 1) {
      for (var band in bands) {
        dataMap.putIfAbsent(band.name!, () => band.votes!.toDouble());
      }
    } else {
      dataMap.putIfAbsent("no bands", () => 1);
    }

    return Container(
        width: double.infinity,
        height: 220,
        child: PieChart(
          dataMap: dataMap,
          chartValuesOptions: const ChartValuesOptions(
            showChartValueBackground: false,
            showChartValuesInPercentage: true,
            decimalPlaces: 0,
          ),
        ));
  }
}
