import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vibration/vibration.dart';
import 'dart:async'; 


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InSight',
      theme: ThemeData(
        primaryColor: Colors.yellow[700],
        primaryColorDark: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
class HomePage extends StatelessWidget {
  Widget _buildClickableArea(BuildContext context, {required Icon icon, required String text, required VoidCallback onTap}) {
    Icon adjustedIcon = Icon(icon.icon, size: 40.0, color: icon.color ?? Colors.white);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 100.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            adjustedIcon,
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.visibility),
            SizedBox(width: 8),
            Text('InSight'),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildClickableArea(
            context,
            icon: Icon(Icons.route),
            text: 'Indoor Guidance',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => IndoorNavigationPage())),
          ),
          _buildClickableArea(
            context,
            icon: Icon(Icons.elevator_rounded),
            text: 'Floor Transition',
            onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => FloorTransitionPage())),
          ),
          _buildClickableArea(
            context,
            icon: Icon(Icons.directions_walk),
            text: 'Emergency',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EmergencyPage())),
          ),
        ],
      ),
    );
  }
}



//Indoor Navigation Page
class IndoorNavigationPage extends StatefulWidget {
  @override
  _IndoorNavigationPageState createState() => _IndoorNavigationPageState();
}
class _IndoorNavigationPageState extends State<IndoorNavigationPage> {
  final FlutterTts flutterTts = FlutterTts();
  final List<Beacon> beacons = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _currentField = '';
  List<String> locations = ['Main entrance', 'CE LAB', 'Cafe', '1F Toilet', '2F Toilet']; 
  String? from;
  String? to;
  String currentFloor = "Loading..."; // Default value before beacon is detected
  String getNavigationInstructions(String from, String to) {
     Map<String, String> navigationInstructions = {
    'Main entrance-Cafe': 'Go through the door, Turn left, It is on your left-hand side',
    'Main entrance-1F Toilet': 'Go through the door, Turn Left and go straight, Tap your UCL card at your right hand side in front of the door, Toilet is on your right hand side when you enter the door',
    'Main entrance-CE LAB': 'Go through the door, Turn Left and go straight find the lift, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk until the end and turn left, Tap your UCL card on your right hand side, Go straight till the end and push the door, CE LAB is on your right hand side',
    'Main entrance-2F Toilet': 'Go through the door, Turn Left and go straight find the lift, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk until the end and turn left,Tap your UCL card on your right hand side, Go straight about 7 meter, Toilet entrance is on the right',
    'Cafe-Main entrance':'Turn right and go straight, It is on your right hand side',
    'Cafe-1F Toilet':'Turn Left and go straight, There is a door and please tap your UCL card on the right side, Go through the door and it is on your left side',
    'Cafe-CE LAB':'Go Straight 2 meter there are lifts on your left side, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk until the end and turn left, Tap your UCL card on your right hand side, Go straight until the end and push the door, CE LAB is on your right hand side',
    'Cafe-2F Toilet':'Go Straight 2 meter there are lifts on your left side, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk till the end and turn left, Tap your UCL card on your right hand side, Go straight about 7 meter, Toilet entrance is on the right',
    '1F Toilet-Main entrance':'Turn right and push the button on your right side to open the door, Pass through the door and go straight 6 meter, Main Entrance is on your right hand side',
    '1F Toilet-Cafe':'Turn right and push the button on your right side to open the door, Pass through the door and go straight 2 meter, Main Entrance is on your right hand side',
    '1F Toilet-CE LAB':'Turn right and push the button on your right side to open the door, Pass through the door and turn left, Lifts are on your left hand side, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk until the end and turn left, Tap your UCL card on your right hand side, Go straight until the end and push the door, CE LAB is on your right hand side',
    '1F Toilet-2F Toilet':'Turn right and push the button on your right side to open the door, Pass through the door and turn left, Lifts are on your left hand side, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk until the end and turn left, Tap your UCL card on your right hand side, Go straight about 7 meter, Toilet entrance is on the right',
    'CE LAB-Main entrance':'Pass through the door on your left, Go straight until the end and press the button on your right side, Out of the door turn right and go straight 8 meter, Lifts are on your left side, Take the lift to first floor, Go straight 4 meter and turn right',
    'CE LAB-Cafe':'Pass through the door on your left, Go straight until the end and press the button on your right side, Out of the door turn right and go straight 8 meter, Lifts are on your left side,Take the lift to first floor, Go straight 2 meter and turn right',
    'CE LAB-1F Toilet':'Pass through the door on your left, Go straight until the end and press the button on your right side, Out of the door turn right and go straight 8 meter,Lifts are on your left side,Take the lift to first floor, Turn right and go forward 1m and turn right again, There is a door and please tap your UCL card on the right side, Go through the door and it is on ypur left side',
    'CE LAB-2F Toilet':'Pass through the door on your left, Go straight 3 meter, Toilet entrance is on your left hand side',
    '2F Toilet-Main entrance':'Turn left when you pass through the toilet entrance door, Go straight till the end and press the button on your right side, Out of the door turn right and go straight 8 meter, Lifts are on your left side, Take the lift to first floor, Go straight 4m and turn right',
    '2F Toilet-Cafe':'Turn left when you pass through the toilet entrance door, Go straight till the end and press the button on your right side, Out of the door turn right and go straight 8 meter, Lifts are on your left side, Take the lift to first floor, Go straight 2 meter and turn right',
    '2F Toilet-CE LAB':'Turn right when you pass through the toilet entrance door, Go straight until the end and pull the door, CE LAB is on your right hand side',
    '2F Toilet-1F Toilet':'Turn left when you pass through the toilet entrance door, Go straight till the end and press the button on your right side,Out of the door turn right and go straight 8 meter, Lifts are on your left side, Take the lift to first floor, Turn right and go forward 1m and turn right again, There is a door and please tap your UCL card on the right side, Go through the door and it is on ypur left side',
    'Main entrance-Mainentrance':'You are right here!',
    'Cafe-Cafe':'You are right here!',
    '1F Toilet-1F Toilet':'You are right here!',
    '2F Toilet-2F Toilet':'You are right here!',
    'CE LAB-CE LAB':'You are right here!',
  };

    String key = '$from-$to';
    return navigationInstructions[key] ?? 'No specific navigation instructions, available for this route.';
  }

  @override
  void initState() {
    super.initState();
    initBeaconScanning();
    flutterTts.setLanguage("en-UK");
    flutterTts.setSpeechRate(0.5);
  }



  void initBeaconScanning() async {
  try {
    await flutterBeacon.initializeScanning; 
    final regions = [Region(identifier: 'all')]; // Scanning all beacons
    flutterBeacon.ranging(regions).listen((RangingResult result) {
      if (result.beacons.isNotEmpty) {
        setState(() {
          beacons.clear();
          beacons.addAll(result.beacons);
          beacons.sort((a, b) => a.rssi.compareTo(b.rssi)); // Sorting by signal strength
          currentFloor = "Floor ${beacons.first.major}"; // Updating the floor number
          speak("Closest beacon at ${beacons.first.proximityUUID}, major: ${beacons.first.major}, minor: ${beacons.first.minor}");
        });
      } else {
        print('No beacons detected');
      }
    });
  } catch (e) {
    print('Error initializing beacon scanning: $e');
  }
}


  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  void _listen(String field) {
    _currentField = field; // Set current input field
    if (!_isListening) {
      _speech.initialize(onStatus: (val) => print('onStatus: $val'), onError: (val) => print('onError: $val')).then((available) {
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(onResult: (val) => setState(() {
            if (_currentField == 'from') {
              from = val.recognizedWords;
            } else if (_currentField == 'to') {
              to = val.recognizedWords;
            }
          }));
        }
      });
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> vibratePhone() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Indoor Navigation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Current Floor: $currentFloor', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            buildDropdownWithMic('From', from, 'from'),
            SizedBox(height: 20),
            buildDropdownWithMic('To', to, 'to'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: (){
                  if (from == null || to == null || from!.isEmpty || to!.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Incomplete Selection"),
                          content: Text("Please select both a 'From' and 'To' location."),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Dismiss the alert dialog
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    String temp = from ?? '';
                    from = to;
                    to = temp;
                    setState(() {});
                  }
                  },
                  style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor, 
                  onPrimary: Colors.white, 
                  ),
                  child: Icon(Icons.swap_horiz, size: 30),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (from != null && to != null && !from!.isEmpty && !to!.isEmpty) {
                      String instructions = getNavigationInstructions(from!, to!);
                      speak(instructions);
                      vibratePhone();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResultsPage(instructions: instructions)),
                      );
                    } else {
                      speak("Please select both a starting and ending location");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Colors.white,
                  ),
                  child: Icon(Icons.search, size: 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  

  Widget buildDropdownWithMic(String label, String? value, String field) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
            items: locations.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                if (field == 'from') {
                  from = newValue;
                } else if (field == 'to') {
                  to = newValue;
                }
              });
            },
          ),
        ),
        IconButton(
          icon: Icon(_isListening && _currentField == field ? Icons.mic : Icons.mic_none),
          onPressed: () => _listen(field),
        ),
      ],
    );
  }
}
  // Result Page
class ResultsPage extends StatelessWidget {
  final String instructions;

  ResultsPage({required this.instructions});

  @override
  Widget build(BuildContext context) {
    List<String> steps = instructions.split(', '); // Splits the instructions into steps based on commas.
    return Scaffold(
      appBar: AppBar(
        title: Text('Follow Me'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: steps.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text(
                steps[index],
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            );
          },
        ),
      ),
    );
  }
}

//Floor Transition Page
class FloorTransitionPage extends StatefulWidget {
  @override
  _FloorTransitionPageState createState() => _FloorTransitionPageState();
}

class _FloorTransitionPageState extends State<FloorTransitionPage> {
  String currentFloor = "Scanning...";
  StreamSubscription<RangingResult>? beaconSubscription;

  @override
  void initState() {
    super.initState();
    initBeaconScanning();
  }

  void initBeaconScanning() async {
    try {
      // Ensure the beacon scanning is initialized
      await flutterBeacon.initializeScanning; 
      // Define the regions here, inside the try block after initializing scanning
      final regions = [Region(identifier: 'all')]; // Scanning all beacons
      beaconSubscription = flutterBeacon.ranging(regions).listen((RangingResult result) {
        if (result.beacons.isNotEmpty) {
          setState(() {
            result.beacons.sort((a, b) => a.rssi.compareTo(b.rssi)); // Sorting by signal strength
            currentFloor = "Floor ${result.beacons.first.major}"; // Updating the floor number
          });
        } else {
          print('No beacons detected');
        }
      });
    } catch (e) {
      print('Error initializing beacon scanning: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Floor Transition')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You are current in \n $currentFloor floor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => navigateToStairs(context), child: Text('Take Lift')),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () => navigateToElevator(context), child: Text('Take Stairs')),
          ],
        ),
      ),
    );
  }

  void navigateToStairs(BuildContext context) {
    // Logic for navigating with stairs
  }

  void navigateToElevator(BuildContext context) {
    // Logic for navigating with lift
  }

  @override
  void dispose() {
    // Cancel the beacon subscription to prevent memory leaks
    beaconSubscription?.cancel();
    super.dispose();
  }
}


//Emergency Page
class EmergencyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Emergency')),
      body: Center(
        child: Text('Emergency Page'),
      ),
    );
  }
}