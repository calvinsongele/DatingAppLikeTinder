import 'package:WeFreak/includes/dbqueries.dart';
import 'package:flutter/widgets.dart';
import 'package:WeFreak/cards/profiles.dart';
import 'package:flutter/material.dart';
import 'package:WeFreak/includes/validatesession.dart';
class MatchEngine extends ChangeNotifier {
  final List<Match> _matches;
  int _currrentMatchIndex;
  int _nextMatchIndex;

  MatchEngine({
    List<Match> matches,
  }) : _matches = matches {
    _currrentMatchIndex = 0;
    _nextMatchIndex = 1;
  }
  Match get currentMatch => _matches[_currrentMatchIndex];
  Match get nextMatch => _matches[_nextMatchIndex];

  void cycleMatchs() {
    if (currentMatch.decision != Decision.indecided) {
      currentMatch.reset();
      _currrentMatchIndex = _nextMatchIndex;
      _nextMatchIndex = _nextMatchIndex < _matches.length - 1 ? _nextMatchIndex + 1 : 0;
      notifyListeners();
    }
  }

}

class Match extends ChangeNotifier {
  Profile profile;
  Decision decision = Decision.indecided;

  Match({this.profile}); 

  void like(myEmail) async {
    if (decision == Decision.indecided) {
      decision = Decision.like;
      String _userid = await ValidateSession("context").getAValueInSession('userID'); //email
      DbQueries('like_a_person', {'they_email': '$_userid', 'decision': 'Like', 'email': myEmail}).voidQuery();
      notifyListeners();
    }
  } 

  void nope(myEmail) async {
    if (decision == Decision.indecided) {
      decision = Decision.nope;
      String _userid = await ValidateSession("context").getAValueInSession('userID'); //its an email
      DbQueries('reject_a_person', {'they_email': '$_userid', 'decision': 'Nope', 'email': myEmail}).voidQuery();
      notifyListeners();
    }
  }

  void superLike(context, myEmail) async {
    
    if (decision == Decision.indecided) {
      decision = Decision.superLike;
      String _userid = await ValidateSession("context").getAValueInSession('userID'); //email
      var _feedback = await DbQueries('beforesuperlike', {'they_email': '$_userid', 'decision': 'SuperLike', 'email': myEmail}).query();
  
      if (_feedback == 'sp-null' || _feedback == 'sp-used') {
        ValidateSession('context').setSession('pleasepay', '$_feedback');        
        Navigator.pushReplacementNamed(context, '/paynow');
      }
      notifyListeners();
    }
  }

  void reset() {
    if (decision != Decision.indecided) {
      decision = Decision.indecided;
      notifyListeners();
    }
  }
}

enum Decision {
  indecided,
  nope,
  like,
  superLike,
}
