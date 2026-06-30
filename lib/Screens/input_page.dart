import 'dart:io';
import 'landing_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Components/Action_Button.dart';
import '../Components/Icon_Content.dart';
import '../Components/Reusable_Bg.dart';
import '../Components/RoundIcon_Button.dart';
import '../constants.dart';
import 'Results_Page.dart';
import 'SavedResults_Page.dart';
import '../calculator_brain.dart';

class InputPage extends StatefulWidget {
  final Gender? preSelectedGender;
  final File? profileImage;

  const InputPage({this.preSelectedGender, this.profileImage});

  @override
  State<InputPage> createState() => _InputPageState();
}

enum Gender {
  male,
  female,
}

class _InputPageState extends State<InputPage> {
  late Gender selectedGender;
  int feet = 5;
  int inches = 10;
  int weight = 70;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.preSelectedGender ?? Gender.male;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A2F51),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LandingPage(),
              ),
              (route) => false,
            );
          },
        ),
        title: Center(
          child: Text('BMI CALCULATOR'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedResultsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.profileImage != null)
            Expanded(
              child: Center(
                child: Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: FileImage(widget.profileImage!),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: kactiveCardColor,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = Gender.male;
                        });
                      },
                      child: ReusableBg(
                        colour: selectedGender == Gender.male
                            ? kactiveCardColor
                            : kinactiveCardColor,
                        cardChild: IconContent(
                          myicon: FontAwesomeIcons.user,
                          text: 'MALE',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = Gender.female;
                        });
                      },
                      child: ReusableBg(
                        colour: selectedGender == Gender.female
                            ? kactiveCardColor
                            : kinactiveCardColor,
                        cardChild: IconContent(
                          myicon: FontAwesomeIcons.personDress,
                          text: 'FEMALE',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ReusableBg(
              colour: kactiveCardColor,
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'HEIGHT',
                    style: klabelTextStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        feet.toString(),
                        style: kDigitTextStyle,
                      ),
                      Text(
                        "'",
                        style: klabelTextStyle,
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        inches.toString(),
                        style: kDigitTextStyle,
                      ),
                      Text(
                        '"',
                        style: klabelTextStyle,
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Feet',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  color: Color(0xFF8D8E98),
                                ),
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: ksliderInactiveColor,
                                  thumbColor: Color(0xFFEB1555),
                                  overlayColor: Color(0x29EB1555),
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 10.0),
                                  overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 20.0),
                                ),
                                child: Slider(
                                  value: feet.toDouble(),
                                  min: 4,
                                  max: 7,
                                  divisions: 3,
                                  onChanged: (double newValue) {
                                    setState(() {
                                      feet = newValue.round();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Inches',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  color: Color(0xFF8D8E98),
                                ),
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: ksliderInactiveColor,
                                  thumbColor: Color(0xFFEB1555),
                                  overlayColor: Color(0x29EB1555),
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 10.0),
                                  overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 20.0),
                                ),
                                child: Slider(
                                  value: inches.toDouble(),
                                  min: 0,
                                  max: 11,
                                  divisions: 11,
                                  onChanged: (double newValue) {
                                    setState(() {
                                      inches = newValue.round();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ReusableBg(
              colour: kactiveCardColor,
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'WEIGHT',
                    style: klabelTextStyle,
                  ),
                  Text(
                    weight.toString(),
                    style: kDigitTextStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundIconButton(
                        icon: FontAwesomeIcons.minus,
                        onPressed: () {
                          setState(() {
                            weight--;
                          });
                        },
                      ),
                      SizedBox(width: 15.0),
                      RoundIconButton(
                        icon: FontAwesomeIcons.plus,
                        onPressed: () {
                          setState(() {
                            weight++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: ActionButton(
              label: 'CALCULATE',
              onTap: () {
                final heightInCm = (feet * 30.48 + inches * 2.54).round();
                final calc = Calculate(height: heightInCm, weight: weight);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultPage(
                      bmi: calc.result(),
                      resultText: calc.getText(),
                      advise: calc.getAdvise(),
                      textColor: calc.getTextColor(),
                      height: heightInCm,
                      weight: weight,
                      bmiValue: calc.getBMI(),
                      normalWeightRange: calc.getNormalWeightRange(),
                      profileImage: widget.profileImage,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
