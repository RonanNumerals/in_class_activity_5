/*
  Author: Ronan pelot
  Assignment: In-Class Activity 5
  Description: A digital pet app where users can interact with their pet by playing, feeding, sleeping, and running. The pet's happiness, hunger, and energy levels are displayed and updated based on user interactions and time. The game has win and loss conditions based on the pet's happiness and hunger levels.
*/

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
  // Pet attributes
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
    // Start the hunger timer to increase hunger over time
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

  // Playing with the pet increases happiness but also increases hunger and reduces energy
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

  // Feeding the pet reduces hunger and can increase energy and happiness
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

  // Sleeping increases energy and can increase happiness if the pet is not too hungry
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

  // Running increases happiness but also increases hunger and reduces energy
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

  // Update happiness based on hunger level
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

  // Update hunger level based on time and actions
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

  // Update energy level based on actions
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

  // Determine the color of the pet image based on happiness level
  Color _moodColor(int happinessLevel) {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  // Set the pet's name based on user input
  void _petName() {
    setState(() {
      petName = _textController.text;
    });
  }

  void _checkGameState() {
  // Loss Condition: Hunger reaches 100 and happiness is 10 or below
    if (hungerLevel >= 100 && happinessLevel <= 10 && !_isGameOver) {
      _isGameOver = true;
      _hungerTimer?.cancel();
      _winTimer?.cancel();
      _showEndDialog("Game Over");
    }

    // Win Condition: Happiness above 80 for 3 minutes
    if (happinessLevel > 80 && !_isWinner) {
      _startWinTimer();
    } else {
      _stopWinTimer();
    }
  }

  // Start a timer to track how long the pet has been happy
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

  // Stop the win timer if happiness drops below the threshold
  void _stopWinTimer() {
    _winTimer?.cancel();
    _winTimer = null;
    _highHappinessSeconds = 0;
  }

  // Show a dialog at the end of the game with the final stats
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
                // Text field for entering the pet's name
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
            // Display the pet image with a color filter based on happiness level
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                _moodColor(happinessLevel),
                BlendMode.modulate,
              ),
              child: Image.asset('assets/pet_image.png', width: 150, height: 150),
            ),
            SizedBox(height: 16.0),
            // Display the energy level as a progress bar
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
            // Display the pet's mood based on happiness level
            if (happinessLevel > 70)
              Text('Happy! 😄', style: TextStyle(fontSize: 18.0, color: Colors.green)),
            if (happinessLevel >= 30 && happinessLevel <= 70)
              Text('Neutral 😐', style: TextStyle(fontSize: 18.0, color: Colors.yellow)),
            if (happinessLevel < 30)
              Text('Sad 😢', style: TextStyle(fontSize: 18.0, color: Colors.red)),
            // Display the happiness and hunger levels
            Text('Happiness Level: $happinessLevel', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            Text('Hunger Level: $hungerLevel', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 32.0),
            // Dropdown menu to select between sleeping and running actions
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
            // Buttons to play with and feed the pet
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