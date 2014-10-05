// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_curses;

import 'package:curses/curses.dart';

void main() {
  stdscr.setup(autoRefresh: true, cursorVisibility: CursorVisibility.INVISIBLE, escDelay: 1);

  stdscr.init_pair(1, Color.RED, Color.BLACK);

  stdscr.addstr('hola', location: new Point(1, 1), colorPair: 1, attributes: [Attribute.REVERSE]);
  stdscr.addstr('adios', location: new Point(2, 1));
  stdscr.addstr('mundo', location: new Point(3, 1), colorPair: 1, attributes: [Attribute.BOLD]);

  var size = stdscr.getmaxyx();
  stdscr.addstr('${size.rows} x ${size.columns}', location: new Point(4, 1));
  stdscr.addstr('XXX', location: new Point(size.rows-1, size.columns-4));

  var w = new Window(new Point(10, 10), new Size(10, 10), autoRefresh: true);
  w.border();
  w.addstr('Lili', location: new Point(1, 1));
  //w.clear();

  w.wgetch().then((key) {
    w.dispose();
    stdscr.dispose();

    var strKey = new String.fromCharCode(key);
    print("key = $strKey");
  });

}
