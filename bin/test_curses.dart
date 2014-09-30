// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_curses;

import 'dart:io';
import 'package:curses/curses.dart';

void main() {
  stdscr.setup(autoRefresh: true, cursorVisibility: CursorVisibility.INVISIBLE);

  stdscr.init_pair(1, Color.RED, Color.BLACK);

  stdscr.addstr('hola', row: 1, col: 1, colorPair: 1, attributes: [Attribute.REVERSE]);
  stdscr.addstr('adios', row: 2, col: 1);
  stdscr.addstr('mundo', row: 3, col: 1, colorPair: 1, attributes: [Attribute.BOLD]);

  var size = stdscr.getmaxyx();
  stdscr.addstr('${size.rows} x ${size.columns}', row: 4, col: 1);
  stdscr.addstr('XXX', row: size.rows-1, col: size.columns-4);

  var w = new Window(10, 10, 10, 10, autoRefresh: true);
  w.border();
  w.addstr('Lili', row: 1, col: 1);
  //w.clear();

  stdin.readByteSync();
  w.dispose();
  stdscr.dispose();
}
