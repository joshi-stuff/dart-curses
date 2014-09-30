library curses;

import 'dart-ext:dart_curses';

Screen _stdscr;

//final int COLORS = _get_curses_value("COLORS");
//final int COLOR_PAIRS = _get_curses_value("COLOR_PAIRS");

Screen get stdscr {
  if (_stdscr == null) {
    _stdscr = new Screen._(_initscr());
  }

  return _stdscr;
}

class Attribute {

  static final ALTCHARSET = new Attribute(_get_curses_value('ALTCHARSET'));
  static final BLINK = new Attribute(_get_curses_value('BLINK'));
  static final BOLD = new Attribute(_get_curses_value('BOLD'));
  static final DIM = new Attribute(_get_curses_value('DIM'));
  static final NORMAL = new Attribute(_get_curses_value('NORMAL'));
  static final REVERSE = new Attribute(_get_curses_value('REVERSE'));
  static final STANDOUT = new Attribute(_get_curses_value('STANDOUT'));
  static final UNDERLINE = new Attribute(_get_curses_value('UNDERLINE'));

  static const _NONE = const Attribute(0);

  final int value;

  const Attribute(this.value);

}

class Color extends Attribute {

  static final BLACK = new Color(_get_curses_value('BLACK'));
  static final RED = new Color(_get_curses_value('RED'));
  static final GREEN = new Color(_get_curses_value('GREEN'));
  static final YELLOW = new Color(_get_curses_value('YELLOW'));
  static final BLUE = new Color(_get_curses_value('BLUE'));
  static final MAGENTA = new Color(_get_curses_value('MAGENTA'));
  static final CYAN = new Color(_get_curses_value('CYAN'));
  static final WHITE = new Color(_get_curses_value('WHITE'));

  static const _NONE = const Color(0);

  const Color(int value) : super(value);

}

class CursorVisibility {

  static const INVISIBLE = const CursorVisibility(0);
  static const NORMAL = const CursorVisibility(1);
  static const HIGH = const CursorVisibility(2);

  final int value;

  const CursorVisibility(this.value);

}

class Screen extends Window {

  Screen._(int window) : super._(window);

  void setup({bool autoRefresh: false, CursorVisibility cursorVisibility:
      CursorVisibility.NORMAL}) {
    noecho();
    cbreak();
    keypad(true);
    setAutoRefresh(autoRefresh);
    curs_set(cursorVisibility);
    start_color();
  }

  void dispose() {
    keypad(false);
    nocbreak();
    echo();
    _endwin();
    super.dispose();
  }

  void cbreak() {
    _window;
    _cbreak();
  }

  void curs_set(CursorVisibility visibility) {
    _window;
    _curs_set(visibility.value);
  }

  void echo() {
    _window;
    _echo();
  }

  void init_pair(int colorPair, Color fg, Color bg) {
    _window;
    _init_pair(colorPair, fg.value, bg.value);
  }

  void nocbreak() {
    _window;
    _nocbreak();
  }

  void noecho() {
    _window;
    _noecho();
  }

  void start_color() {
    _window;
    _start_color();
  }

}

class Size {

  final int rows;
  final int columns;

  const Size(this.rows, this.columns);

}

class Window {

  int __window;
  bool _autoRefresh = false;

  Window(int height, int width, int row, int col, {bool autoRefresh: false}) {
    __window = _newwin(height, width, row, col);
    _autoRefresh = autoRefresh;
  }

  Window._(this.__window);

  void setAutoRefresh([bool active = true]) {
    _autoRefresh = active;
  }

  void dispose() {
    _delwin(_window);
    __window = null;
  }

  void addstr(String str, {int row: -1, int col: -1, int maxLength: -1, int colorPair: null,
      List<Attribute> attributes: const [
      Attribute._NONE]}) {

    if (maxLength == -1) {
      maxLength = str.length;
    }

    int saved_attr = _attr_get(_window);

    stdscr.attrset(colorPair: colorPair, attributes: attributes);

    if ((row == -1) || (col == -1)) {
      if ((row != -1) || (col != -1)) {
        throw new ArgumentError('When using row and col both must be specified');
      }

      _waddnstr(_window, str, maxLength);
    } else {
      _mvwaddnstr(_window, row, col, str, maxLength);
    }

    _attrset(_window, saved_attr);

    _doAutoRefresh();
  }

  void attroff(Attribute attribute) {
    _window;
    _attroff(_window, attribute.value);
  }

  void attron(Attribute attribute) {
    _window;
    _attron(_window, attribute.value);
  }

  void attrset({int colorPair: null, List<Attribute> attributes: const [Attribute._NONE]}) {
    _window;

    var attr = 0;

    if (colorPair != null) {
      attr |= _COLOR_PAIR(colorPair);
    }

    for (var attribute in attributes) {
      attr |= attribute.value;
    }

    _attrset(_window, attr);
  }

  void border({String left: '', String right: '', String top: '', String bottom: '', String topLeft:
      '', String topRight: '', String bottomLeft: '', String bottomRight: ''}) {

    _border(_window, left, right, top, bottom, topLeft, topRight, bottomLeft, bottomRight);
  }

  void clear() {
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

  int get _window {
    if (__window == null) {
      throw new StateError('Window has been disposed');
    }
    return __window;
  }

  void _doAutoRefresh() {
    if (_autoRefresh) {
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
void _start_color() native '_start_color';
void _endwin() native '_endwin';

int _newwin(int height, int width, int row, int col) native '_newwin';
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
