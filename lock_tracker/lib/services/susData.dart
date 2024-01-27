// ignore_for_file: file_names
import 'bmsData.dart';
import 'configData.dart';

class SusQuestion{
  late String question;
  late int answer;
  SusQuestion({this.question="",this.answer=3});
}

class SusSurvey{
  List<SusQuestion> susQuestions = [];


  void addSusQuestion(SusQuestion susQuestion){
    susQuestions.add(susQuestion);
  }
  SusQuestion getSusQuestion(int index){
    return susQuestions[index];
  }
  List<SusQuestion> initialize(Language lng){
    if(lng == Language.EN){
      susQuestions = [
        SusQuestion(question: "I feel the desire to use this system frequently."),
        SusQuestion(question: "I perceive the system as unnecessarily complex."),
        SusQuestion(question: "I think the system is easy to use."),
        SusQuestion(question: "I feel in control when using this system."),
        SusQuestion(question: "I find the system cumbersome to use."),
        SusQuestion(question: "I really like the way this system is presented."),
        SusQuestion(question: "I feel that the system operates too quickly."),
        SusQuestion(question: "Using the system is enjoyable for me."),
        SusQuestion(question: "I needed to learn a lot before I could use this system effectively."),
        SusQuestion(question: "I think most people would learn to use this system quickly."),
      ];
    } else if(lng == Language.DE){
      susQuestions = [
        SusQuestion(question: "Ich möchte dieses System gerne häufiger nutzen."),
        SusQuestion(question: "Ich empfinde das System als unnötig komplex."),
        SusQuestion(question: "Ich finde, das System ist einfach zu bedienen."),
        SusQuestion(question: "Ich fühle mich beim Benutzen dieses Systems in Kontrolle."),
        SusQuestion(question: "Ich finde das System umständlich zu bedienen."),
        SusQuestion(question: "Mir gefällt die Darstellung dieses Systems sehr."),
        SusQuestion(question: "Ich habe das Gefühl, dass das System zu schnell arbeitet."),
        SusQuestion(question: "Die Nutzung des Systems macht mir Spaß."),
        SusQuestion(question: "Ich musste viel lernen, bevor ich dieses System effektiv nutzen konnte."),
        SusQuestion(question: "Ich denke, dass die meisten Menschen dieses System schnell erlernen würden."),
      ];
    }
    return susQuestions;
  }

}
