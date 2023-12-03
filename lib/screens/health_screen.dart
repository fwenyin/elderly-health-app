import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../widget/app_bar.dart';
import '../widget/bmi.dart';
import '../widget/navigation_bar.dart';

class HealthPage extends StatefulWidget {
  @override
  _HealthPageState createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController heartRateController = TextEditingController();
  TextEditingController systolicController = TextEditingController();
  TextEditingController diastolicController = TextEditingController();
  double _bmi = 0.0;
  List<FlSpot> systolicChartData = [];
  List<FlSpot> diastolicChartData = [];
  List<FlSpot> heartRateData = [];
  List<DateTime> chartDates = [];
  Future? _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchBmi();
    _fetchDataFuture = fetchHealthData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}')); // Show error message
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //HeadingText('My Health Log'),
                //SizedBox(height: 20.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildHumanFigure(),
                    ),
                    SizedBox(width: 30.0),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.logMeasurement,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          _buildEntryField(AppLocalizations.of(context)!.pulse,
                              heartRateController),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildEntryField(
                                      AppLocalizations.of(context)!.systolic,
                                      systolicController)),
                              SizedBox(width: 10),
                              Expanded(
                                  child: _buildEntryField(
                                      AppLocalizations.of(context)!.diastolic,
                                      diastolicController)),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          ElevatedButton(
                              onPressed: _saveDataToFirestore,
                              child:
                                  Text(AppLocalizations.of(context)!.logData)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    AppLocalizations.of(context)!.bmi,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 30.0),
                  BMIGaugeChart(bmi: _bmi),
                ]),
                SizedBox(height: 20.0),
                Text(
                  AppLocalizations.of(context)!.bloodPressure,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                _buildLegend(),
                SizedBox(height: 5.0),
                systolicChartData.isEmpty || diastolicChartData.isEmpty
                    ? Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30.0, bottom: 40.0),
                              child: Text(AppLocalizations.of(context)!.noBloodPressure),
                            )
                          ]))
                    : Container(
                        height: 200,
                        child: LineChart(_buildBloodPressure(
                            systolicChartData, diastolicChartData, chartDates)),
                      ),
                SizedBox(height: 20.0),
                Text(
                  AppLocalizations.of(context)!.pulsebpm,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                systolicChartData.isEmpty || diastolicChartData.isEmpty
                    ? Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30.0),
                              child: Text(AppLocalizations.of(context)!.noPulse),
                            )
                          ]))
                    : Container(
                        height: 200,
                        child:
                            LineChart(_buildPulse(heartRateData, chartDates)),
                      ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildHumanFigure() {
    return Container(
      height: 200.0,
      child: Image.asset('lib/asset/human_figure.png'),
    );
  }

  Widget _buildEntryField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number, // Set the keyboard type to number
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly, // Only allow digits
      ],
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }

  Future<void> _saveDataToFirestore() async {
    String userId = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('healthLogs')
        .doc(DateTime.now().toIso8601String().split('T')[0])
        .set({
      'heartRate': heartRateController.text,
      'systolic': systolicController.text,
      'diastolic': diastolicController.text,
    });

    // Clear the controllers after saving the data
    heartRateController.clear();
    systolicController.clear();
    diastolicController.clear();

    await fetchHealthData();
  }

  Future<void> _fetchBmi() async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(userId).get();

    if (snapshot.exists && snapshot.data() is Map<String, dynamic>) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _bmi = (data['weight'] / (data['height'] * data['height'])) * 10000;
      });
    }
  }

  Future<void> fetchHealthData() async {
    String userId = _auth.currentUser!.uid;
    var healthLogs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('healthLogs')
        .get();
    List<FlSpot> systolicData = [];
    List<FlSpot> diastolicData = [];
    List<FlSpot> hrData = [];
    List<DateTime> dates = []; // Store dates for x-axis labels

    for (var doc in healthLogs.docs) {
      var data = doc.data();
      var sys = double.parse(data['systolic']);
      var dia = double.parse(data['diastolic']);
      var hr = double.parse(data['heartRate']);
      DateTime date =
          DateTime.parse(doc.id); // Parse the document ID to DateTime

      dates.add(date); // Add date to the list
      double xValue = dates.length.toDouble() - 1; // Use index as x-value

      systolicData.add(FlSpot(xValue, sys));
      diastolicData.add(FlSpot(xValue, dia));
      hrData.add(FlSpot(xValue, hr));
    }
    if (healthLogs.docs.isNotEmpty) {
      setState(() {
        systolicChartData = systolicData;
        diastolicChartData = diastolicData;
        heartRateData = hrData;
        chartDates = dates;
      });
    }
  }

  LineChartData _buildPulse(List<FlSpot> pulseData, List<DateTime> dates) {
    const double normalPulseUpperBound = 100;
    const double normalPulseLowerBound = 60;

    return LineChartData(
      minY: normalPulseLowerBound - 20,
      maxY: normalPulseUpperBound + 20,
      titlesData: FlTitlesData(
        show: true,
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 30,
            reservedSize: 30,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value % 30 == 0) {
                return Text('${value.toInt()}',
                    style: TextStyle(color: Colors.grey, fontSize: 12));
              }
              return Container(); // Return empty container for non-specified intervals
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final date = dates[value.toInt()];
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(DateFormat('MM/dd').format(date),
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              );
            },
            interval: 1,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
          show: true, border: Border.all(color: Colors.grey, width: 1)),
      lineBarsData: [
        LineChartBarData(
          spots: pulseData,
          isCurved: true,
          color: Colors.blue,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.blue.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            cutOffY: normalPulseLowerBound,
            applyCutOffY: true,
          ),
          aboveBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.blue.withOpacity(0.0),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            cutOffY: normalPulseUpperBound,
            applyCutOffY: true,
          ),
        ),
      ],
    );
  }

  LineChartData _buildBloodPressure(List<FlSpot> systolicData,
      List<FlSpot> diastolicData, List<DateTime> dates) {
    const double systolicUpperBound = 140;
    const double diastolicUpperBound = 90;
    const double systolicLowerBound = 90;
    const double diastolicLowerBound = 60;
    const double maxY = systolicUpperBound + 25; // Extending the upper bound
    const double minY = diastolicLowerBound - 25; // Extending the lower bound

    return LineChartData(
      minY: minY,
      maxY: maxY,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final date = dates[value.toInt()];
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(DateFormat('MM/dd').format(date),
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              );
            },
            interval: 1,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles:
              SideTitles(showTitles: false), // Disable right y-axis labels
        ),
        topTitles: AxisTitles(
          sideTitles:
              SideTitles(showTitles: false), // Disable top x-axis labels
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value % 30 == 0) {
                return Text('${value.toInt()}',
                    style: TextStyle(color: Colors.grey, fontSize: 12));
              }
              return Container(); // Return empty container for non-specified intervals
            },
            interval: 30,
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
          show: true, border: Border.all(color: Colors.grey, width: 1)),
      lineBarsData: [
        // Systolic Line
        LineChartBarData(
          spots: systolicData,
          color: Colors.red,
          // ... other styling for systolic line ...
        ),
        // Diastolic Line
        LineChartBarData(
          spots: diastolicData,
          color: Colors.blue,
          // ... other styling for diastolic line ...
        ),
        // Systolic Upper and Lower Bound Area
        LineChartBarData(
          spots: createBoundsSpots(systolicData, systolicUpperBound),
          isCurved: true,
          color: Colors.transparent,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.red.withOpacity(0.3),
                Colors.red.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0], // Stops for gradient
            ),
            cutOffY: systolicLowerBound,
            applyCutOffY: true,
          ),
        ),
        // Diastolic Upper and Lower Bound Area
        LineChartBarData(
          spots: createBoundsSpots(diastolicData, diastolicUpperBound),
          isCurved: true,
          color: Colors.transparent,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.blue.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0], // Stops for gradient
            ),
            cutOffY: diastolicLowerBound,
            applyCutOffY: true,
          ),
        ),
      ],
    );
  }

  List<FlSpot> createBoundsSpots(List<FlSpot> data, double boundValue) {
    double firstX = data.first.x;
    double lastX = data.last.x;
    return [
      FlSpot(firstX, boundValue),
      FlSpot(lastX, boundValue),
    ];
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.red, AppLocalizations.of(context)!.systolic),
        SizedBox(width: 10),
        _legendItem(Colors.blue, AppLocalizations.of(context)!.diastolic),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 10,
          color: color,
        ),
        SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}
