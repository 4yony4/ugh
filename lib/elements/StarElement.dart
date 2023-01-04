import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/UghGame.dart';

class StarElement extends SpriteComponent with HasGameRef<UghGame>{

  StarElement({required super.position}): super(size: Vector2.all(64), anchor: Anchor.bottomLeft);


  @override
  Future<void>? onLoad() async{
    // TODO: implement onLoad
    await super.onLoad();

    final platformImage = game.images.fromCache('star.png');
    sprite = Sprite(platformImage);

    add(RectangleHitbox()..collisionType = CollisionType.passive);
    //final Image spriteImage;
    //
  }

  @override
  void update(double dt) {
    super.update(dt);

    if ( game.health <= 0) {
      removeFromParent();
    }
  }



}