
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ugh/elements/StarElement.dart';
import 'package:ugh/game/UghGame.dart';
import 'package:ugh/players/GotaPlayer.dart';



class EmberPlayer extends SpriteAnimationComponent with HasGameRef<UghGame>, KeyboardHandler,CollisionCallbacks {
  EmberPlayer({
    required super.position,
  }) : super(size: Vector2.all(64), anchor: Anchor.center);

  int verticalDirection = 0;
  int horizontalDirection = 0;

  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200;

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

    hitbox=CircleHitbox();

    add(hitbox);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    //print("DEBUG: ----------->>>>>>>> BOTON PRESIONADO: "+keysPressed.toString());

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

    game.setDirection(horizontalDirection,verticalDirection);


    return true;
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


  @override
  void update(double dt) {
    // TODO: implement update
    //position.add(Vector2(10.0*horizontalDirection, 10.0*verticalDirection));
    //velocity.x = horizontalDirection * moveSpeed;
    //velocity.y = verticalDirection * moveSpeed;
    //game.mapComponent.position -= velocity * dt;

    if (horizontalDirection < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && scale.x < 0) {
      flipHorizontally();
    }

    if (position.x < -size.x || game.health <= 0) {
      game.setDirection(0,0);
      removeFromParent();

    }

    super.update(dt);
  }

}