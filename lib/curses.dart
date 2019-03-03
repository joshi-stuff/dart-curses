library curses;

import 'dart:async';
import 'dart:isolate';

import 'package:logging/logging.dart';

import 'dart-ext:dart_curses';

Screen _stdscr;
final Logger _log = new Logger('curses');

//final int COLORS = _get_curses_value("COLORS");
//final int COLOR_PAIRS = _get_curses_value("COLOR_PAIRS");

Screen get stdscr {
  if (_stdscr == null) {
    _stdscr = new Screen._(_initscr());
  }

  return _stdscr;
}

class Attribute {

  static const NONE = const Attribute._none();

  static final ALTCHARSET = new Attribute._fromCurses('ALTCHARSET');
  static final BLINK = new Attribute._fromCurses('BLINK');
  static final BOLD = new Attribute._fromCurses('BOLD');
  static final DIM = new Attribute._fromCurses('DIM');
  static final NORMAL = new Attribute._fromCurses('NORMAL');
  static final REVERSE = new Attribute._fromCurses('REVERSE');
  static final STANDOUT = new Attribute._fromCurses('STANDOUT');
  static final UNDERLINE = new Attribute._fromCurses('UNDERLINE');

  final String name;
  final int _value;

  Attribute._fromCurses(String _name)
      : name = _name,
        _value = _get_curses_value(_name);

  const Attribute._none()
      : name = 'NONE',
        _value = 0;

}

class Color extends Attribute {

  static const NONE = const Color._none();

  static final BLACK = new Color._fromCurses('BLACK');
  static final RED = new Color._fromCurses('RED');
  static final GREEN = new Color._fromCurses('GREEN');
  static final YELLOW = new Color._fromCurses('YELLOW');
  static final BLUE = new Color._fromCurses('BLUE');
  static final MAGENTA = new Color._fromCurses('MAGENTA');
  static final CYAN = new Color._fromCurses('CYAN');
  static final WHITE = new Color._fromCurses('WHITE');

  Color._fromCurses(String name) : super._fromCurses(name);

  const Color._none() : super._none();

}

class CursorVisibility {

  static const INVISIBLE = const CursorVisibility('INVISIBLE', 0);
  static const NORMAL = const CursorVisibility('NORMAL', 1);
  static const HIGH = const CursorVisibility('HIGH', 2);

  final String name;
  final int _value;

  const CursorVisibility(this.name, this._value);

}

class Key {

  static const _EXTRA_KEYS = const <String, int>{
    'ESC': 27,
  };

  static const _CURSES_KEYS = const <String>[
      'F1',
      'F2',
      'F3',
      'F4',
      'F5',
      'F6',
      'F7',
      'F8',
      'F9',
      'F10',
      'F11',
      'F12',
      'CODE_YES',
      'BREAK',
      'SRESET',
      'RESET',
      'DOWN',
      'UP',
      'LEFT',
      'RIGHT',
      'HOME',
      'BACKSPACE',
      'DL',
      'IL',
      'DC',
      'IC',
      'EIC',
      'CLEAR',
      'EOS',
      'EOL',
      'SF',
      'SR',
      'NPAGE',
      'PPAGE',
      'STAB',
      'CTAB',
      'CATAB',
      'ENTER',
      'PRINT',
      'LL',
      'A1',
      'A3',
      'B2',
      'C1',
      'C3',
      'BTAB',
      'BEG',
      'CANCEL',
      'CLOSE',
      'COMMAND',
      'COPY',
      'CREATE',
      'END',
      'EXIT',
      'FIND',
      'HELP',
      'MARK',
      'MESSAGE',
      'MOVE',
      'NEXT',
      'OPEN',
      'OPTIONS',
      'PREVIOUS',
      'REDO',
      'REFERENCE',
      'REFRESH',
      'REPLACE',
      'RESTART',
      'RESUME',
      'SAVE',
      'SBEG',
      'SCANCEL',
      'SCOMMAND',
      'SCOPY',
      'SCREATE',
      'SDC',
      'SDL',
      'SELECT',
      'SEND',
      'SEOL',
      'SEXIT',
      'SFIND',
      'SHELP',
      'SHOME',
      'SIC',
      'SLEFT',
      'SMESSAGE',
      'SMOVE',
      'SNEXT',
      'SOPTIONS',
      'SPREVIOUS',
      'SPRINT',
      'SREDO',
      'SREPLACE',
      'SRIGHT',
      'SRSUME',
      'SSAVE',
      'SSUSPEND',
      'SUNDO',
      'SUSPEND',
      'UNDO',
      'MOUSE',
      'RESIZE',
      'EVENT'];

  static final _keysByKeyCode = <int, Key>{};
  static final _keysByName = <String, Key>{};

  static void _registerNamedKeys() {
    if (_keysByKeyCode.isEmpty) {
      _CURSES_KEYS.forEach((name) {
        new Key._(name, _get_curses_value('KEY_${name}'));
      });

      _EXTRA_KEYS.forEach((name, keyCode) {
        new Key._(name, keyCode);
      });
    }
  }

  final String name;
  final int _keyCode;

  factory Key(String name) {
    _registerNamedKeys();

    var key;

    if (name.length == 1) {
      int keyCode = name.codeUnits[0];

      key = _keysByKeyCode[keyCode];

      if (key == null) {
        key = new Key._(name, keyCode);
      }
    } else {
      key = _keysByName[name];

      if (key == null) {
        throw new ArgumentError("No key with name '${name}' exists");
      }
    }

    return key;
  }

  factory Key._fromKeyCode(int keyCode) {
    _registerNamedKeys();

    var key = _keysByKeyCode[keyCode];

    if (key == null) {
      key = new Key._(new String.fromCharCode(keyCode), keyCode);
    }

    return key;
  }

  Key._(this.name, this._keyCode) {
    _keysByKeyCode[_keyCode] = this;
    _keysByName[name] = this;
  }

  String toString() => 'Key(${name}, ${_keyCode})';

  int get keyCode => _keyCode;
}

class Screen extends Window {

  Screen._(int window) : super._(window);

  void setup({bool autoRefresh: true, CursorVisibility cursorVisibility: CursorVisibility.NORMAL,
      escDelay: null}) {
    noecho();
    cbreak();
    keypad(true);
    curs_set(cursorVisibility);
    start_color();
    if (escDelay != null) {
      set_escdelay(escDelay);
    }
    this.autoRefresh = autoRefresh;
  }

  void dispose({bool clear: true}) {
    if (clear) {
      this.clear();
    }
    keypad(false);
    nocbreak();
    echo();
    _endwin();
    super.dispose(clear: false);
  }

  void cbreak() {
    _window;
    _cbreak();
  }

  void curs_set(CursorVisibility visibility) {
    _window;
    _curs_set(visibility._value);
  }

  void echo() {
    _window;
    _echo();
  }

  void init_pair(int colorPair, Color fg, Color bg) {
    _window;
    _init_pair(colorPair, fg._value, bg._value);
  }

  void nocbreak() {
    _window;
    _nocbreak();
  }

  void noecho() {
    _window;
    _noecho();
  }

  void set_escdelay(int delay) {
    _window;
    _set_escdelay(delay);
  }

  void start_color() {
    _window;
    _start_color();
  }

}

class Point {

  final int row;
  final int col;

  const Point(this.row, this.col);

  String toString() => "Point($row, $col)";

}

class Size {

  final int rows;
  final int columns;

  const Size(this.rows, this.columns);

  String toString() => "Size($rows x $columns)";

}

class Window {

  int __window;
  bool autoRefresh = false;

  Window(Point location, Size size, {bool autoRefresh: true}) {
    __window = _newwin(size.rows, size.columns, location.row, location.col);
    _log.fine("Window: ${__window}");
    this.autoRefresh = autoRefresh;
  }

  Window._(this.__window);

  String toString() => 'Window(${_window})';

  int get _window {
    if (__window == null) {
      throw new StateError('Window has been disposed');
    }
    return __window;
  }

  void dispose({bool clear: true}) {
    if (clear) {
      this.clear();
    }
    _delwin(_window);
    __window = null;
  }

  void addstr(String str, {Point location: null, int maxLength: -1, int colorPair: null,
      List<Attribute> attributes: const [
      Attribute.NONE]}) {

    if (maxLength == -1) {
      maxLength = str.length;
    }

    int saved_attr = _attr_get(_window);

    stdscr.attrset(colorPair: colorPair, attributes: attributes);

    if (location == null) {
      _waddnstr(_window, str, maxLength);
    } else {
      _mvwaddnstr(_window, location.row, location.col, str, maxLength);
    }

    _attrset(_window, saved_attr);

    _doAutoRefresh();
  }

  void attroff(Attribute attribute) {
    _window;
    _attroff(_window, attribute._value);
  }

  void attron(Attribute attribute) {
    _window;
    _attron(_window, attribute._value);
  }

  void attrset({int colorPair: null, List<Attribute> attributes: const [Attribute.NONE]}) {
    _window;

    var attr = 0;

    if (colorPair != null) {
      attr |= _COLOR_PAIR(colorPair);
    }

    for (var attribute in attributes) {
      attr |= attribute._value;
    }

    _attrset(_window, attr);
  }

  void border({String left: '', String right: '', String top: '', String bottom: '', String topLeft:
      '', String topRight: '', String bottomLeft: '', String bottomRight: ''}) {

    _log.fine('border: this=${this}');
    _border(_window, left, right, top, bottom, topLeft, topRight, bottomLeft, bottomRight);
    _doAutoRefresh();
  }

  void clear() {
    _log.fine('clear: this=${this}');
    _wclear(_window);
    _doAutoRefresh();
  }

  Size getmaxyx() {
    int value = _getmaxyx(_window);

    int rows = value & 0xFFFFFFFF;
    int columns = (value >> 32) & 0xFFFFFFFF;

    return new Size(rows, columns);
  }

  void keypad(bool active) {
    _keypad(_window, active);
  }

  void refresh() {
    _wrefresh(_window);
  }

  Future<Key> wgetch() {
    final completer = new Completer<Key>();

    final receivePort = new ReceivePort();

    receivePort.listen((keyCode) {
      receivePort.close();
      completer.complete(new Key._fromKeyCode(keyCode as int));
    });

    _wgetch.send([_window, receivePort.sendPort]);

    return completer.future;
  }

  void _doAutoRefresh() {
    if (autoRefresh) {
      _log.fine('_doAutoRefresh: this=${this}');
      refresh();
    }
  }

}

int _get_curses_value(String tag) native '_get_curses_value';
int _COLOR_PAIR(int colorPair) native '_COLOR_PAIR';

int _initscr() native '_initscr';
void _cbreak() native '_cbreak';
void _curs_set(int visibility) native '_curs_set';
void _echo() native '_echo';
void _init_pair(int colorPair, int fg, int bg) native "_init_pair";
void _nocbreak() native '_nocbreak';
void _noecho() native '_noecho';
void _set_escdelay(int delay) native '_set_escdelay';
void _start_color() native '_start_color';
void _endwin() native '_endwin';

int _newwin(int rows, int columns, int row, int col) native '_newwin';
int _attr_get(int window) native '_attr_get';
void _attroff(int window, int attr) native '_attroff';
void _attron(int window, int attr) native '_attron';
void _attrset(int window, int attr) native '_attrset';
void _border(int window, String left, String right, String top, String bottom, String topLeft,
    String topRight, String bottomLeft, String bottomRight) native '_border';
int _getmaxyx(int window) native '_getmaxyx';
void _keypad(int window, bool active) native '_keypad';
void _mvwaddnstr(int window, int row, int col, String str, int maxLength) native '_mvwaddnstr';
void _waddnstr(int window, String str, int maxLength) native '_waddnstr';
void _wclear(int window) native '_wclear';
void _wrefresh(int window) native '_wrefresh';
void _delwin(int window) native '_delwin';

SendPort _new_wgetch() native "_new_wgetch";
final _wgetch = _new_wgetch();
