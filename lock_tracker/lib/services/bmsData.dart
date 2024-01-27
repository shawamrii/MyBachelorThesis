// ignore_for_file: file_names

import 'package:flutter/foundation.dart';

import 'configData.dart';


class BmsQuestion {
  late String question;
  late int answer;

  BmsQuestion({this.question="", this.answer = 4});
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
        BmsQuestion(question: "I feel physically fatigued or exhausted."),
        BmsQuestion(question: "I am able to focus and maintain mental concentration."),
        BmsQuestion(question: "I am motivated to use technology."),
        BmsQuestion(question: "I am in a positive emotional state or good mood."),
      ];
    } else if (ln == Language.DE) {
      bmsQuestions = [
        BmsQuestion(question: "Ich fühle mich körperlich müde oder erschöpft."),
        BmsQuestion(question: "Ich kann mich gut konzentrieren und aufmerksam bleiben."),
        BmsQuestion(question: "Ich bin motiviert, Technologie zu nutzen."),
        BmsQuestion(question: "Ich befinde mich in einem positiven emotionalen Zustand oder einer guten Stimmung."),
      ];
    }
    return bmsQuestions;
  }

}
