import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:forge2d/src/dynamics/body.dart';

import '../game/UghGame.dart';

class SueloBody extends BodyComponent<UghGame>{

  TiledObject tiledBody;
  SueloBody({required this.tiledBody});

  @override
  Future<void> onLoad() {
    // TODO: implement onLoad
    renderBody=true;
    return super.onLoad();
  }

  @override
  Body createBody() {

    late FixtureDef fixtureDef;


    if(tiledBody.isRectangle){
      PolygonShape shape=PolygonShape();
      final vertices = [
        Vector2(0, 0),
        Vector2(tiledBody.width, 0),
        Vector2(tiledBody.width, tiledBody.height),
        Vector2(0, tiledBody.height),
      ];
      shape.set(vertices);
      fixtureDef=FixtureDef(shape);
    }


    else if(tiledBody.isPolygon){
      ChainShape shape = ChainShape();
      List<Vector2> vertices = [];

      for(final point in tiledBody.polygon){
        shape.vertices.add(Vector2(point.x, point.y));
      }
      Point point0=tiledBody.polygon[0];
      shape.vertices.add(Vector2(point0.x, point0.y));

      fixtureDef=FixtureDef(shape);
    }

    BodyDef definicionCuerpo= BodyDef(position: Vector2(tiledBody.x,tiledBody.y),type: BodyType.static);
    Body cuerpo= world.createBody(definicionCuerpo);


    //FixtureDef fixtureDef=FixtureDef(shape);
    cuerpo.createFixture(fixtureDef);
    return cuerpo;

  }

}