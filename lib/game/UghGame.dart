

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:ugh/elements/StarElement.dart';

import '../overlays/Hud.dart';
import '../players/EmberPlayer.dart';
import '../players/GotaPlayer.dart';

class UghGame extends FlameGame with HasKeyboardHandlerComponents,HasCollisionDetection{

  late TiledComponent mapComponent;
  int verticalDirection = 0;
  int horizontalDirection = 0;
  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200;
  int starsCollected = 0;
  int health = 3;
  late EmberPlayer _emberPlayer;

  List<PositionComponent> objetosVisuales = [];

  UghGame();

  @override
  Future<void>? onLoad() async{
    // TODO: implement onLoad
    await super.onLoad();
    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'water_enemy.png',
    ]);
    mapComponent = await TiledComponent.load('mapa1.tmx', Vector2(32,32));
    add(mapComponent);


    //initializeGame(true);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  @override
  void update(double dt) {
    // TODO: implement update
    //position.add(Vector2(10.0*horizontalDirection, 10.0*verticalDirection));
    velocity.x = horizontalDirection * moveSpeed;
    velocity.y = verticalDirection * moveSpeed;
    mapComponent.position -= velocity * dt;
    for(final objVisual in objetosVisuales){
      objVisual.position -= velocity * dt;
    }

    if (health <= 0) {
      overlays.add('GameOver');
    }

    super.update(dt);
  }

  void setDirection(int horizontalDirection, int verticalDirection){
    this.horizontalDirection=horizontalDirection;
    this.verticalDirection=verticalDirection;
  }

  void initializeGame(bool loadHud) async{
    // Assume that size.x < 3200
    objetosVisuales.clear();
    mapComponent.position=Vector2(0, 0);

    ObjectGroup? estrellas=mapComponent.tileMap.getLayer<ObjectGroup>("estrellas");
    ObjectGroup? gotas = mapComponent.tileMap.getLayer<ObjectGroup>("gotas");
    ObjectGroup? posinitplayer = mapComponent.tileMap.getLayer<ObjectGroup>("posinitplayer");


    for(final estrella in estrellas!.objects){
      //print("DEBUG: ----->>>>  "+estrella.x.toString()+"    "+estrella.y.toString());
      //EmberPlayer estrellaComponent = EmberPlayer(position: Vector2(estrella.x,estrella.y));
      StarElement estrellaComponent = StarElement(position: Vector2(estrella.x,estrella.y));
      objetosVisuales.add(estrellaComponent);
      add(estrellaComponent);
    }

    for(final gota in gotas!.objects){
      //print("DEBUG: ----->>>>  "+estrella.x.toString()+"    "+estrella.y.toString());
      GotaPlayer gotaComponent = GotaPlayer(position: Vector2(gota.x,gota.y));
      objetosVisuales.add(gotaComponent);
      add(gotaComponent);
    }

    _emberPlayer = EmberPlayer(position: Vector2(posinitplayer!.objects.first.x,posinitplayer!.objects.first.y));

    add(_emberPlayer);

    if (loadHud) {
      add(Hud());
    }
  }

  void reset() {
    starsCollected = 0;
    health = 3;
    initializeGame(false);
  }

}