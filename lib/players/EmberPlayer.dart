
import 'dart:io';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:forge2d/src/dynamics/body.dart';
import 'package:ugh/elements/StarElement.dart';
import 'package:ugh/game/UghGame.dart';
import 'package:ugh/players/GotaPlayer.dart';

import '../ux/joypad.dart';



class EmberBody extends BodyComponent<UghGame> with KeyboardHandler{

  Vector2 position;
  Vector2 size=Vector2(64, 64);
  late EmberPlayer emberPlayer;
  int verticalDirection = 0;
  int horizontalDirection = 0;
  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200;
  double jumpSpeed=0;
  double iShowDelay=5;
  bool elementAdded=false;


  EmberBody({required this.position});

  @override
  Future<void> onLoad() async{
    // TODO: implement onLoad
    await super.onLoad();
    //sleep(Duration(mi));
    //Future.delayed(Duration(seconds: 3));

    emberPlayer=EmberPlayer(position: Vector2.zero());
    emberPlayer.size=size;
    add(emberPlayer);
    renderBody=true;

    game.overlays.addEntry('Joypad', (_, game) => Joypad(onDirectionChanged:joypadMoved));

  }

  @override
  Body createBody() {
    // TODO: implement createBody
    BodyDef definicionCuerpo= BodyDef(position: position,
        type: BodyType.dynamic,fixedRotation: true);
    Body cuerpo= world.createBody(definicionCuerpo);


    final shape=CircleShape();
    shape.radius=size.x/2;

    FixtureDef fixtureDef=FixtureDef(
        shape,
      //density: 10.0,
      //friction: 0.2,
      restitution: 0.5,
    );
    cuerpo.createFixture(fixtureDef);

    return cuerpo;
  }

  @override
  void onMount() {
    super.onMount();
    camera.followBodyComponent(this);
  }

  void joypadMoved(Direction direction){

    if(direction==Direction.none) {
      horizontalDirection = 0;
      verticalDirection = 0;
    }

    if(direction==Direction.left){
      horizontalDirection=-1;
    }
    else if(direction==Direction.right){
      horizontalDirection=1;
    }


    if(direction==Direction.up){
      verticalDirection=-1;
    }
    else if(direction==Direction.down){
      verticalDirection=1;
    }

  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    //print("DEBUG: ----------->>>>>>>> BOTON PRESIONADO: "+keysPressed.toString());
    //final isKeyDown = event is RawKeyDownEvent;
    //final isKeyUp = event is RawKeyUpEvent;

    horizontalDirection = 0;
    verticalDirection = 0;

    if((keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft))){
      horizontalDirection=-1;
    }
    else if((keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight))){
      horizontalDirection=1;
    }


    if((keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp))){
      verticalDirection=-1;
    }
    else if((keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown))){
      verticalDirection=1;
    }

    /*
    if(keysPressed.contains(LogicalKeyboardKey.space) && (event is RawKeyDownEvent) && jumpSpeed==0){
      jumpSpeed=2000;
    }

    if(keysPressed.contains(LogicalKeyboardKey.space) && (event is RawKeyUpEvent) && jumpSpeed==2000){
      jumpSpeed=0;
    }
    */
    game.setDirection(horizontalDirection,verticalDirection);


    return true;
  }


  @override
  void update(double dt) {

    /*if(!elementAdded) {
      iShowDelay -= dt;
      if (iShowDelay < 0) {
        add(emberPlayer);
        elementAdded=true;
      }
    }*/

    // TODO: implement update
    //position.add(Vector2(10.0*horizontalDirection, 10.0*verticalDirection));
    velocity.x = horizontalDirection * moveSpeed;
    velocity.y = verticalDirection * moveSpeed;
    velocity.y += -1 * jumpSpeed;

    //game.mapComponent.position -= velocity * dt;

    /**
     * IMPORTANTE! Para mover el personaje debemos APLICAR FUERZAS al CUERPO
     * NO mover las coordenadas usando el center ya que luego cuando el objeto REPOSA en el suelo,
     * este pasa a modo "dormido" y para despertarle DEBEMOS usar FUERZAS y no tocar el center.
     * Ver documentacion sobre BOX2D (https://www.iforce2d.net/b2dtut/forces)
     */
    //center.add((velocity * dt));
    body.applyLinearImpulse(velocity*dt);
    body.applyAngularImpulse(3);

    if (horizontalDirection < 0 && emberPlayer.scale.x > 0) {
      //flipAxisDirection(AxisDirection.left);
      //flipAxis(Axis.horizontal);
      emberPlayer.flipHorizontallyAroundCenter();
    } else if (horizontalDirection > 0 && emberPlayer.scale.x < 0) {
      //flipAxisDirection(AxisDirection.left);
      emberPlayer.flipHorizontallyAroundCenter();
    }

    if (position.x < -size.x || game.health <= 0) {
      game.setDirection(0,0);
      removeFromParent();

    }

    super.update(dt);
  }

}

class EmberPlayer extends SpriteAnimationComponent with HasGameRef<UghGame>, CollisionCallbacks {
  EmberPlayer({
    required super.position,
  }) : super(anchor: Anchor.center);





  late CircleHitbox hitbox;

  bool hitByEnemy = false;

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('ember.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2(16,16),
        stepTime: 0.12,
      ),
    );

    //hitbox=CircleHitbox();

    //add(hitbox);
  }



  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    print("DEBUG: COLLISION!!!!!!! ");

    if (other is StarElement) {
      other.removeFromParent();
      game.starsCollected++;
    }

    if (other is GotaPlayer) {
      hit();
    }

    super.onCollision(intersectionPoints, other);
  }

  void hit() {
    if (!hitByEnemy) {
      hitByEnemy = true;
      game.health--;
      add(
        OpacityEffect.fadeOut(
          EffectController(
            alternate: true,
            duration: 0.1,
            repeatCount: 6,
          ),
        )..onComplete = () {
          hitByEnemy = false;
        },
      );

    }
  }




}