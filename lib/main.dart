import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}


class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int energyLevel = 50;
  Timer? _hungerTimer;
  Timer? _winTimer;
  final _textController = TextEditingController();
  int _highHappinessSeconds = 0;
  bool _isGameOver = false;
  bool _isWinner = false;
  String _selectedAction = "Sleep";

  @override
  void initState() {
    super.initState();
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        _updateHunger();
      });
      _checkGameState();
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    super.dispose();
  }

  void _playWithPet() {
    setState(() {
      if (happinessLevel < 100) {
        happinessLevel += 10;
        if (happinessLevel > 100) {
          happinessLevel = 100;
        }
      }
      _updateHunger();
      _updateEnergy();
    });
  }

  void _feedPet() {
    setState(() {
      if (hungerLevel > 0) {
        hungerLevel -= 10;
        if (hungerLevel < 0) {
          hungerLevel = 0;
        }
      }
      _updateHappiness();
      if (energyLevel < 100) {
        energyLevel += 5;
        if (energyLevel > 100) {
          energyLevel = 100;
        }
      }
    });
  }

  void _petSleep() {
    setState(() {
      if (happinessLevel > 0) {
        happinessLevel += 5;
        if (happinessLevel > 100) {
          happinessLevel = 100;
        }
      }
      if (energyLevel < 100) {
        energyLevel += 20;
        if (energyLevel > 100) {
          energyLevel = 100;
        }
      }
      _updateHunger();
    });
  }

  void _petRun() {
    setState(() {
      if (happinessLevel < 100) {
        happinessLevel += 15;
        if (happinessLevel > 100) {
          happinessLevel = 100;
        }
      }
      _updateHunger();
      _updateEnergy();
    });
  }

  void _updateHappiness() {
    if (hungerLevel > 70) {
      happinessLevel -= 20;
      if (happinessLevel < 0) {
        happinessLevel = 0;
      }
    } else {
      happinessLevel += 10;
    }
  }

  void _updateHunger() {
    setState(() {
      hungerLevel += 5;
      if (hungerLevel > 100) {
        hungerLevel = 100;
        happinessLevel -= 20;
        if (happinessLevel < 0) {
          happinessLevel = 0;
        }
      }
    });
  }

  void _updateEnergy() {
    setState(() {
      energyLevel -= 5;
      if (energyLevel < 0) {
        energyLevel = 0;
        happinessLevel -= 20;
        if (happinessLevel < 0) {
          happinessLevel = 0;
        }
      }
    });
  }

  Color _moodColor(int happinessLevel) {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  void _petName() {
    setState(() {
      petName = _textController.text;
    });
  }

  void _checkGameState() {
  // LOSS CONDITION
    if (hungerLevel >= 100 && happinessLevel <= 10 && !_isGameOver) {
      _isGameOver = true;
      _hungerTimer?.cancel();
      _winTimer?.cancel();
      _showEndDialog("Game Over");
    }

    // WIN CONDITION
    if (happinessLevel > 80 && !_isWinner) {
      _startWinTimer();
    } else {
      _stopWinTimer();
    }
  }

  void _startWinTimer() {
  if (_winTimer != null) return;

    _winTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _highHappinessSeconds++;

      if (_highHappinessSeconds >= 180) {
        _isWinner = true;
        _hungerTimer?.cancel();
        _winTimer?.cancel();
        _showEndDialog("You Win!");
      }
    });
  }

  void _stopWinTimer() {
    _winTimer?.cancel();
    _winTimer = null;
    _highHappinessSeconds = 0;
  }

  void _showEndDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('Your pet\'s final stats:\nHappiness: $happinessLevel\nHunger: $hungerLevel'),
        alignment: Alignment.center
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200.0,
                  height: 50.0,
                  child:
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your pet\'s name',
                      ),
                    )
                  ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    _petName();
                  },
                  child: const Text('Enter'),
                ),
              ]
            ),   
            Text('Name: $petName', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                _moodColor(happinessLevel),
                BlendMode.modulate,
              ),
              child: Image.asset('assets/pet_image.png', width: 150, height: 150),
            ),

            SizedBox(height: 16.0),
            SizedBox(
              width: 250,
              child: LinearProgressIndicator(
                value: energyLevel / 100,
                minHeight: 20,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            
            SizedBox(height: 16.0),

            if (happinessLevel > 70)
              Text('Happy! 😄', style: TextStyle(fontSize: 18.0, color: Colors.green)),
            if (happinessLevel >= 30 && happinessLevel <= 70)
              Text('Neutral 😐', style: TextStyle(fontSize: 18.0, color: Colors.yellow)),
            if (happinessLevel < 30)
              Text('Sad 😢', style: TextStyle(fontSize: 18.0, color: Colors.red)),
            Text('Happiness Level: $happinessLevel', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            Text('Hunger Level: $hungerLevel', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 32.0),
            DropdownButton<String>(
              value: _selectedAction,
              items: const [
                DropdownMenuItem(
                  value: "Sleep",
                  child: Text("Sleep"),
                ),
                DropdownMenuItem(
                  value: "Run",
                  child: Text("Run"),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAction = newValue!;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_selectedAction == "Sleep") {
                  _petSleep();
                } else if (_selectedAction == "Run") {
                  _petRun();
                }
                _checkGameState();
              },
              child: Text("Do Action"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _playWithPet();
                _checkGameState();
              },
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _feedPet();
                _checkGameState();
              },
              child: Text('Feed Your Pet'),
            ),
          ],
        ),
      ),
    );
  }
}