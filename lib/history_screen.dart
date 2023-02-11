import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingHistoryPage extends StatefulWidget {
  @override
  _ReadingHistoryPageState createState() => _ReadingHistoryPageState();
}

class _ReadingHistoryPageState extends State<ReadingHistoryPage> {
  List<Reading> _readings = [];

  @override
  void initState() {
    super.initState();
    _getReadings();
  }

  _getReadings() async {
    var prefs = await SharedPreferences.getInstance();
    List<String> readingList = prefs.getStringList('readingList') ?? [];
    setState(() {
      _readings = readingList.map((reading) => Reading.fromString(reading)).toList();
    });
  }

  _sortReadings(SortCriteria criteria) {
    setState(() {
      _readings.sort((a, b) {
        switch (criteria) {
          case SortCriteria.date:
            return a.dateTime.compareTo(b.dateTime);
          case SortCriteria.reading:
            return a.reading.compareTo(b.reading);
          case SortCriteria.time:
            return a.reading.compareTo(b.time);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, // <-- SEE HERE
        ),
       backgroundColor: Colors.white,
        elevation: 2.0,
        title:      
      Text('Reading history', textAlign: TextAlign.center, style: TextStyle(
        color: Color.fromRGBO(42, 47, 45, 1),
        fontFamily: 'Poppins',
        fontSize: 16,
        letterSpacing: 1,
        fontWeight: FontWeight.bold,
        height: 1
      ),),
              centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<SortCriteria>(
            onSelected: _sortReadings,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Sort by Date"),
                value: SortCriteria.date,
              ),
              PopupMenuItem(
                child: Text("Sort by Reading"),
                value: SortCriteria.reading,
              ),
              PopupMenuItem(
                child: Text("Sort by Time"),
                value: SortCriteria.time,
              ),
            ],
          )
        ],
      ),
      body: _readings.isEmpty
          ? Center(child: Text("No readings found"))
          : DataTable(
              sortColumnIndex: 0,
              sortAscending: true,
              columns: [
                DataColumn(label: Text("Date"), onSort: (i, b) {
                  _sortReadings(SortCriteria.date);
                }),
                DataColumn(label: Text("Time"),),
                DataColumn(label: Text("Reading"), onSort: (i, b) {
                  _sortReadings(SortCriteria.reading);
                }),
              ],
              rows: _readings
                  .map((reading) => DataRow(cells: [
                        DataCell(Text(reading.date)),
                        DataCell(Text(reading.time)),
                        DataCell(Text(reading.reading)),
                      ]))
                  .toList(),
            ),
    );
  }
}

enum SortCriteria { date, reading, time }

class Reading {
  final DateTime dateTime;
  final String date;
  final String time;
  final String reading;

  Reading({required this.dateTime, required this.date, required this.time, required this.reading});

  factory Reading.fromString(String reading) {
    var parts = reading.split(" ");
    var date = parts[0];
var time = parts[1].substring(0, parts[1].length - 1);
var readingVal = parts.sublist(2).join(" ");
var dateArr = date.split("/");
var dateTime = DateTime(int.parse(dateArr[2]), int.parse(dateArr[1]), int.parse(dateArr[0]));
return Reading(dateTime: dateTime, date: date, time: time, reading: readingVal);
}
}
