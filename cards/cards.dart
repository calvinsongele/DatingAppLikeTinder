import 'dart:math';
import 'package:WeFreak/includes/validatesession.dart';
import 'package:WeFreak/includes/dbqueries.dart';
import 'package:flutter/material.dart';
import 'package:fluttery_dart2/layout.dart';
import 'package:WeFreak/cards/profiles.dart';
import 'package:WeFreak/cards/photos.dart';
import 'package:WeFreak/cards/matches.dart';
import 'package:WeFreak/includes/loader.dart';

class CardStack extends StatefulWidget {
  final MatchEngine matchEngine;
  final dynamic contexty;
  final dynamic globEmail;

  CardStack({this.matchEngine, this.contexty, this.globEmail});


  @override
  _CardStackState createState() => _CardStackState(contexty: contexty, globEmail: globEmail);
}

class _CardStackState extends State<CardStack> {
  Key _frontCard;
  Match _currentMatch;
  double _nextCardScale = 0.0;
  final dynamic contexty;
  final dynamic globEmail;
  _CardStackState({this.contexty, this.globEmail});

  @override
  void initState() {
    super.initState();
    widget.matchEngine.addListener(_onMatchEngineChange);

    _currentMatch = widget.matchEngine.currentMatch;
    _currentMatch.addListener(_onMatchChange);

    _frontCard = Key(_currentMatch.profile.name);
  }

  @override
  void didUpdateWidget(CardStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.matchEngine != oldWidget.matchEngine) {
      oldWidget.matchEngine.removeListener(_onMatchEngineChange);
      widget.matchEngine.addListener(_onMatchEngineChange);

      if (_currentMatch != null) {
        _currentMatch.removeListener(_onMatchChange);
      }

      _currentMatch = widget.matchEngine.currentMatch;
      if (_currentMatch != null) {
        _currentMatch.addListener(_onMatchChange);
      }
    }
  }

  @override
  void dispose() {
    if (_currentMatch != null) {
      _currentMatch.removeListener(_onMatchChange);
    }

    widget.matchEngine.removeListener(_onMatchEngineChange);
    super.dispose();
  }

  _onMatchEngineChange() {
    setState(() {
      if (_currentMatch != null) {
        _currentMatch.removeListener(_onMatchChange);
      }

      _currentMatch = widget.matchEngine.currentMatch;
      if (_currentMatch != null) {
        _currentMatch.addListener(_onMatchChange);
      }

      _frontCard = Key(_currentMatch.profile.name);
    });
  }

  _onMatchChange() {
    setState(() {});
  }

  Widget _buildBackCard() {
    return Transform(
      transform: Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: ProfileCard(
        profile: widget.matchEngine.nextMatch.profile,
      ),
    );
  }

  Widget _buildFrontCard() {
    return ProfileCard(
      key: _frontCard,
      profile: widget.matchEngine.currentMatch.profile,
    );
  }

  SlideDirection _desiredSlideOutDirection() {
    switch (widget.matchEngine.currentMatch.decision) {
      case Decision.nope:
        return SlideDirection.left;
        break;
      case Decision.like:
        return SlideDirection.right;
        break;
      case Decision.superLike:
        return SlideDirection.up;
        break;
      default:
        return null;
    }
  }

  void _onSlideUpdate(double distance) {
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  void _onSlideComplete(SlideDirection direction) {
    Match currenMatch = widget.matchEngine.currentMatch;
    switch (direction) {
      case SlideDirection.left:
        currenMatch.nope(globEmail);
        break;
      case SlideDirection.right:
        currenMatch.like(globEmail);
        break;
      case SlideDirection.up:
        currenMatch.superLike(contexty, globEmail);
        break;
    }

    widget.matchEngine.cycleMatchs();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget> [
        DraggableCard(
          screenHeight: MediaQuery.of(context).size.height,
          screenWidth: MediaQuery.of(context).size.width,
          isDraggable: false,
          card: _buildBackCard(),
        ),
        DraggableCard(
          screenHeight: MediaQuery.of(context).size.height,
          screenWidth: MediaQuery.of(context).size.width,
          card: _buildFrontCard(),
          slideTo: _desiredSlideOutDirection(),
          onSlideUpdate: _onSlideUpdate,
          onSlideComplete: _onSlideComplete,
        )
      ],
    );
  }
}

enum SlideDirection {
  left,
  right,
  up,
}

class DraggableCard extends StatefulWidget {
  final Widget card;
  final bool isDraggable;
  final SlideDirection slideTo;
  final Function(double distance) onSlideUpdate;
  final Function(SlideDirection direction) onSlideComplete;
  final double screenWidth;
  final double screenHeight;

  DraggableCard({
    Key key,
    this.card,
    this.isDraggable = true,
    this.slideTo,
    this.onSlideUpdate,
    this.onSlideComplete,
    this.screenWidth,
    this.screenHeight,
  });

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with TickerProviderStateMixin {
  Decision decision;
  GlobalKey profileCardKey = GlobalKey(debugLabel: 'profile_card_key');
  Offset cardOffset = const Offset(0.0, 0.0);
  Offset dragStart;
  Offset dragPosition;
  Offset slideBackStart;
  SlideDirection slideOutDirection;
  AnimationController slideBackAnimation;
  Tween<Offset> slideOutTween;
  AnimationController slideOutAnimation;

  @override
  void initState() {
    super.initState();
    slideBackAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )
      ..addListener(() => setState(() {
            cardOffset = Offset.lerp(slideBackStart, const Offset(0.0, 0.0),
                Curves.elasticOut.transform(slideBackAnimation.value));

            if (null != widget.onSlideUpdate) {
              widget.onSlideUpdate(cardOffset.distance);
            }
          }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStart = null;
            slideBackStart = null;
            dragPosition = null;
          });
        }
      });

    slideOutAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )
      ..addListener(() => setState(() {
            cardOffset = slideOutTween.evaluate(slideOutAnimation);

            if (null != widget.onSlideUpdate) {
              widget.onSlideUpdate(cardOffset.distance);
            }
          }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStart = null;
            dragPosition = null;
            slideOutTween = null;

            if (widget.onSlideComplete != null) {
              widget.onSlideComplete(slideOutDirection);
            }
          });
        }
      });
  }

  @override
  void didUpdateWidget(DraggableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.card.key != oldWidget.card.key) {
      cardOffset = const Offset(0.0, 0.0);
    }

    if (oldWidget.slideTo == null && widget.slideTo != null) {
      switch (widget.slideTo) {
        case SlideDirection.left:
          _slideLeft();
          break;
        case SlideDirection.right:
          _slideRight();
          break;
        case SlideDirection.up:
          _slideUp();
          break;
      }
    }
  }

  @override
  void dispose() {
    slideBackAnimation.dispose();
    slideOutAnimation.dispose();
    super.dispose();
  }

  void _slideLeft() {
    // final screenWidth = context.size.width;
    dragStart = _chooseRandomDragStart();
    slideOutTween = Tween(
      begin: const Offset(0.0, 0.0),
      end: Offset(-2 * widget.screenWidth, 0.0),
    );

    slideOutAnimation.forward(from: 0.0);
  }

  Offset _chooseRandomDragStart() {
    final cardContex = profileCardKey.currentContext;
    final cardTopLeft = (cardContex.findRenderObject() as RenderBox)
        .localToGlobal(const Offset(0.0, 0.0));
    final dragStartY =
        widget.screenHeight * (Random().nextDouble() < 0.5 ? 0.25 : 0.75) +
            cardTopLeft.dy;

    return Offset(widget.screenWidth / 2 + cardTopLeft.dx, dragStartY);
  }

  void _slideRight() {
    dragStart = _chooseRandomDragStart();
    slideOutTween = Tween(
      begin: const Offset(0.0, 0.0),
      end: Offset(2 * widget.screenWidth, 0.0),
    );

    slideOutAnimation.forward(from: 0.0);
  }

  void _slideUp() {
    // final screenHeight = context.size.height;
    dragStart = _chooseRandomDragStart();
    slideOutTween = Tween(
      begin: const Offset(0.0, 0.0),
      end: Offset(0.0, -2 * widget.screenHeight),
    );

    slideOutAnimation.forward(from: 0.0);
  }

  void _onPanStart(DragStartDetails details) {
    dragStart = details.globalPosition;

    if (slideBackAnimation.isAnimating) {
      slideBackAnimation.stop(canceled: true);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      dragPosition = details.globalPosition;
      cardOffset = dragPosition - dragStart;

      if (null != widget.onSlideUpdate) {
        widget.onSlideUpdate(cardOffset.distance);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final dragVector = cardOffset / cardOffset.distance;
    final isInLeftRegion = (cardOffset.dx / context.size.width) < -0.45;
    final isInRightRegion = (cardOffset.dx / context.size.width) > 0.45;
    final isInTopRegion = (cardOffset.dy / context.size.height) < -0.40;

    setState(() {
      if (isInLeftRegion || isInRightRegion) {
        slideOutTween = Tween(
            begin: cardOffset, end: dragVector * (2 * context.size.width));

        slideOutAnimation.forward(from: 0.0);

        slideOutDirection =
            isInLeftRegion ? SlideDirection.left : SlideDirection.right;
      } else if (isInTopRegion) {
        slideOutTween = Tween(
            begin: cardOffset, end: dragVector * (2 * context.size.height));
        slideOutAnimation.forward(from: 0.0);

        slideOutDirection = SlideDirection.up;
      } else {
        slideBackStart = cardOffset;
        slideBackAnimation.forward(from: 0.0);
      }
    });
  }

  double _rotation(Rect dragBounds) {
    if (dragStart != null) {
      final rotationCornerMultiplier =
          dragStart.dy >= dragBounds.top + (dragBounds.height / 2) ? - 1 : 1;
      return (pi / 8) *
          (cardOffset.dx / dragBounds.width) *
          rotationCornerMultiplier;
    } else {
      return 0.0;
    }
  }

  Offset _rotationOrigin(Rect dragBounds) {
    if (dragStart != null) {
      return dragStart - dragBounds.topLeft;
    } else {
      return const Offset(0.0, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AnchoredOverlay(
      showOverlay: true,
      child: Center(),
      overlayBuilder: (BuildContext context, Rect anchorBounds, Offset anchor) {
        return CenterAbout(
          position: anchor,
          child: Transform(
            transform:
               Matrix4.translationValues(cardOffset.dx, cardOffset.dy, 0.0)
                  ..rotateZ(_rotation(anchorBounds)),
            origin: _rotationOrigin(anchorBounds),
            child: Container(
              key: profileCardKey,
              width: anchorBounds.width,
              height: anchorBounds.height,
              padding: EdgeInsets.all(16.0),
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: widget.card,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProfileCard extends StatefulWidget {
  final Profile profile;

  ProfileCard({Key key, this.profile}) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String loggedEmail;
   _currentPerson() async {
     //return Future.delayed(const Duration(seconds: 1), () => "1");
     return await ValidateSession('context').getAValueInSession('email');
     
  }

   Widget _buildBackground(_photo) {  
    return PhotoBrowser(
      photoAssetPaths: [_photo], //_thisUser["user_dp"], //widget.profile.photos,
      visiblePhotoIndex: 0,
    );
  }

   @override
  void initState() {
    super.initState();
  }

  Widget _buildProfileSynopsis(name, bio, userEmail, _distance) {
    Map _mapBody = {'userEmail': userEmail, 'name': name, 'distance': _distance};
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ])
            ),
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
           Expanded(
              child: Column(
               // crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/viewuser', arguments: _mapBody);
                    },
                    child: Text((name + ' $_distance' + 'km'), textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontSize: 21.0,
                    fontFamily: 'Courier',  fontWeight: FontWeight.w900),),
                  ),
                 Text(bio,
                      style: TextStyle(color: Colors.white, fontSize: 17.0,
                      fontFamily: 'Courier',  fontWeight: FontWeight.w600))
                ],
              ),
            ),
          //  Icon(
          //     Icons.info,
          //     color: Colors.white,
          //   )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
           BoxShadow(
              color: Color(0x11000000),
              blurRadius: 5.0,
              spreadRadius: 2.0,
            )
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),        
              child: Container(
                child: FutureBuilder(
                  future:_currentPerson(),
                  builder: (BuildContext context, AsyncSnapshot snapshote) {
                    if (snapshote.data != null) {
                      _findUsers() async {
                        var _user = await DbQueries('getcardusers', {'email': snapshote.data}).query();
                        return _user;
                      }

                      return Container(
                        child: FutureBuilder(
                            future: _findUsers(),
                            builder: (BuildContext context, AsyncSnapshot snapshotx) {

                              if (snapshotx.hasData == true) {

                                if (snapshotx.data == 'zero users') {
                                    //Navigator.pushReplacementNamed(context, '/nouser');
                                    return Container();
                                } else {
                                  ValidateSession(context).setSession('userID', snapshotx.data['user_email']);
                                  String _usersName = snapshotx.data['user_names'] == null ? 'Nameless' : snapshotx.data['user_names'];
                                  String _usersBio = snapshotx.data['user_about'] == null ? ' ' : snapshotx.data['user_about'];
                                  String _distance = ((snapshotx.data['user_temp_dist'].toString()) == null) ? ' ' : (snapshotx.data['user_temp_dist'].toString());

                                    if (_usersName == 'Nameless') {
                                      return Container(
                                        child: Column(
                                          children: <Widget> [
                                            SizedBox(height: 60.0),    
                                            Loader().spinLoaderRippleLarge(),
                                            Text('No one new around you!', style: TextStyle(color: Colors.black,
                                            fontFamily: 'Courier',  fontWeight: FontWeight.w800
                                            ),),
                                          ],
                                        ),
                                      );
                                    } else {
                                    return Material(
                                      child: Stack(
                                      fit: StackFit.expand,
                                            children: <Widget>[
                                              _buildBackground(snapshotx.data['user_dp']),
                                              _buildProfileSynopsis(_usersName.trim(), _usersBio, snapshotx.data['user_email'], _distance),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              } else return Loader().spinLoaderRipple();   
                            }
                          ), 
                      );
                    } else return Loader().spinLoaderRipple();  
                  },
                ),
              ),
             
            
      ),
    );
  }
}

