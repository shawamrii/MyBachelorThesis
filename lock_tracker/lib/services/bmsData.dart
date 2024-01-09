// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'configData.dart';

class BmsQuestion {
  late String question;
  late int answer;

  BmsQuestion({this.question="", this.answer = 1});
}

class BmsSurvey {
  List<BmsQuestion> bmsQuestions = [];
  void addBmsQuestion(BmsQuestion bmsQuestion) {
    bmsQuestions.add(bmsQuestion);
  }

  BmsQuestion getBmsQuestion(int index) {
    return bmsQuestions[index];
  }

  void setUserAnswer(int index, int value) {
    if (index >= 0 && index < bmsQuestions.length) {
      bmsQuestions[index].answer = value;
    } else {
      if (kDebugMode) {
        print('Index out of range');
      }
    }
  }

  List<BmsQuestion> initializeQuestions(Language ln) {
    if (ln == Language.EN) {
      bmsQuestions = [
        BmsQuestion(question: "Rate your current level of physical fatigue or exhaustion."),
        BmsQuestion(question: "Rate your current level of focus, attention, or mental concentration."),
        BmsQuestion(question: "Rate your current level of motivation to use technology."),
        BmsQuestion(question: "Rate your current emotional state or mood."),
      ];
    } else if (ln == Language.DE) {
      bmsQuestions = [
        BmsQuestion(question: "Bewerten Sie Ihr aktuelles Maß an körperlicher Müdigkeit oder Erschöpfung."),
        BmsQuestion(question: "Bewerten Sie Ihr aktuelles Maß an Fokus, Aufmerksamkeit oder geistiger Konzentration."),
        BmsQuestion(question: "Bewerten Sie Ihr aktuelles Maß an Motivation, die Technologie zu nutzen."),
        BmsQuestion(question: "Bewerten Sie Ihre aktuelle emotionale Verfassung oder Stimmung."),
      ];
    }
    return bmsQuestions;
  }
}
