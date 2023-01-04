



import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:ugh/widgets/GameOver.dart';
import 'package:ugh/widgets/MainMenu.dart';

import 'game/UghGame.dart';

/*
void main() {
  final game = UghGame();
  runApp(GameWidget(game: game));
}
 */

void main() {
  runApp(
    GameWidget<UghGame>.controlled(
      gameFactory: UghGame.new,
      overlayBuilderMap: {
        'MainMenu': (_, game) => MainMenu(game: game),
        'GameOver': (_, game) => GameOver(game: game),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );

  /*runApp(
    const GameWidget<UghGame>.controlled(
      gameFactory: UghGame.new,
    ),
  );*/
}