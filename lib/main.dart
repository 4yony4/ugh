



import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:ugh/ux/joypad.dart';
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
        //'Joypad': (_, game) => Joypad(onDirectionChanged: game.joypadMoved),
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