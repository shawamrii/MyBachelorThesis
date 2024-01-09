// ignore_for_file: file_names
import 'configData.dart';

class SusQuestion{
  late String question;
  late int answer;
  SusQuestion({this.question="",this.answer=1});
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
        SusQuestion(question: "I would like to use the system more often", ),
        SusQuestion(question: "I find the system unnecessarily complex", ),
        SusQuestion(question: "I find the system was easy to operate", ),
        SusQuestion(question: "I felt that I had control over the system during operation",),
        SusQuestion(question: "I find the system was cumbersome to operate", ),
        SusQuestion(question: "I really liked the presentation of the system",),
        SusQuestion(question: "I felt that the system was much too fast", ),
        SusQuestion(question: "I had fun using the system", ),
        SusQuestion(question: "I had to learn many things before I could get started with this system",),
        SusQuestion(question: "I could imagine that most people would learn very quickly to use this system",),
      ];
    } else if(lng == Language.DE){
      susQuestions = [
        SusQuestion(question: "Ich würde das System gerne häufiger verwenden", ),
        SusQuestion(question: "Ich finde das System unnötig komplex", ),
        SusQuestion(question: "Ich finde, das System war leicht zu bedienen", ),
        SusQuestion(question: "Ich hatte das Gefühl, bei der Bedienung die Kontrolle über das System zu haben", ),
        SusQuestion(question: "Ich finde, das System war umständlich zu bedienen", ),
        SusQuestion(question: "Mir hat die Darstellung des Systems sehr gut gefallen",),
        SusQuestion(question: "Ich hatte das Gefühl, dass das System viel zu schnell ablief",),
        SusQuestion(question: "Die Benutzung hat mir Spaß gemacht", ),
        SusQuestion(question: "Ich musste viele Dinge lernen, bevor ich mit diesem System loslegen konnte",),
        SusQuestion(question: "Ich könnte mir vorstellen, dass die meisten Menschen sehr schnell lernen würden, mit diesem System umzugehen", ),
      ];
    }
    return susQuestions;
  }

}
