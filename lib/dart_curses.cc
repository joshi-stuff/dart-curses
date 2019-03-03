#include <string.h>
#include <curses.h>

#include "include/dart_api.h"
#include "include/dart_native_api.h"


struct FunctionLookup {
	const char* name;
	Dart_NativeFunction function;
};

struct ValueLookup {
	const char* name;
	int value;
};

Dart_Handle HandleError(Dart_Handle handle);

bool _get_bool(Dart_NativeArguments args, int i) {
	bool value;

	Dart_Handle arg = HandleError(Dart_GetNativeArgument(args, i));
	Dart_BooleanValue(arg, &value);

	return value;
}

const char* _get_string(Dart_NativeArguments args, int i) {
	const char* value;

	Dart_Handle arg = HandleError(Dart_GetNativeArgument(args, i));
	Dart_StringToCString(arg, &value);

	return value;
}

int64_t _get_int(Dart_NativeArguments args, int i) {
	int64_t value;

	Dart_Handle arg = HandleError(Dart_GetNativeArgument(args, i));
	Dart_IntegerToInt64(arg, &value);

	return value;
}

#define EXPORT(name, body) void d_##name(Dart_NativeArguments args) {Dart_EnterScope(); body; Dart_ExitScope();}

#define ARG_WINDOW(i, var) WINDOW* var = (WINDOW*)_get_int(args, i);
#define ARG_BOOL(i, var) bool var = _get_bool(args, i);
#define ARG_STRING(i, var) const char* var = _get_string(args, i);
#define ARG_INT(i, var) int64_t var = _get_int(args, i);

#define RETURN_NULL Dart_SetReturnValue(args, Dart_Null());return;
#define RETURN_WINDOW(window) Dart_SetReturnValue(args, HandleError(Dart_NewInteger((int64_t)window)));return;
#define RETURN_INT(value) Dart_SetReturnValue(args, HandleError(Dart_NewInteger(value)));return;
#define RETURN_SEND_PORT(service_port) Dart_SetReturnValue(args, HandleError(Dart_NewSendPort(service_port)));return;

/*****************************************************************************/
ValueLookup value_list[] = {
	{"COLORS", COLORS},
	{"COLOR_PAIRS", COLOR_PAIRS},

	{"ALTCHARSET", A_ALTCHARSET},
	{"BLINK", A_BLINK},
	{"BOLD", A_BOLD},
	{"DIM", A_DIM},
	{"NORMAL", A_NORMAL}, 
	{"REVERSE", A_REVERSE}, 
	{"STANDOUT", A_STANDOUT}, 
	{"UNDERLINE", A_UNDERLINE}, 

	{"BLACK", COLOR_BLACK},
	{"RED", COLOR_RED},
	{"GREEN", COLOR_GREEN},
	{"YELLOW", COLOR_YELLOW},
	{"BLUE", COLOR_BLUE},
	{"MAGENTA", COLOR_MAGENTA},
	{"CYAN", COLOR_CYAN},
	{"WHITE", COLOR_WHITE},

	{"KEY_MIN", KEY_MIN},
	{"KEY_MAX", KEY_MAX},

	{"KEY_F0", KEY_F0},
	{"KEY_F1", KEY_F(1)},
	{"KEY_F2", KEY_F(2)},
	{"KEY_F3", KEY_F(3)},
	{"KEY_F4", KEY_F(4)},
	{"KEY_F5", KEY_F(5)},
	{"KEY_F6", KEY_F(6)},
	{"KEY_F7", KEY_F(7)},
	{"KEY_F8", KEY_F(8)},
	{"KEY_F9", KEY_F(9)},
	{"KEY_F10", KEY_F(10)},
	{"KEY_F11", KEY_F(11)},
	{"KEY_F12", KEY_F(12)},
	{"KEY_F13", KEY_F(13)},
	{"KEY_F14", KEY_F(14)},
	{"KEY_F15", KEY_F(15)},
	{"KEY_F16", KEY_F(16)},
	{"KEY_F17", KEY_F(17)},
	{"KEY_F18", KEY_F(18)},
	{"KEY_F19", KEY_F(19)},
	{"KEY_F20", KEY_F(20)},

	{"KEY_CODE_YES", KEY_CODE_YES},
	{"KEY_BREAK", KEY_BREAK},
	{"KEY_SRESET", KEY_SRESET},
	{"KEY_RESET", KEY_RESET},
	{"KEY_DOWN", KEY_DOWN},
	{"KEY_UP", KEY_UP},
	{"KEY_LEFT", KEY_LEFT},
	{"KEY_RIGHT", KEY_RIGHT},
	{"KEY_HOME", KEY_HOME},
	{"KEY_BACKSPACE", KEY_BACKSPACE},
	{"KEY_DL", KEY_DL},
	{"KEY_IL", KEY_IL},
	{"KEY_DC", KEY_DC},
	{"KEY_IC", KEY_IC},
	{"KEY_EIC", KEY_EIC},
	{"KEY_CLEAR", KEY_CLEAR},
	{"KEY_EOS", KEY_EOS},
	{"KEY_EOL", KEY_EOL},
	{"KEY_SF", KEY_SF},
	{"KEY_SR", KEY_SR},
	{"KEY_NPAGE", KEY_NPAGE},
	{"KEY_PPAGE", KEY_PPAGE},
	{"KEY_STAB", KEY_STAB},
	{"KEY_CTAB", KEY_CTAB},
	{"KEY_CATAB", KEY_CATAB},
	{"KEY_ENTER", KEY_ENTER},
	{"KEY_PRINT", KEY_PRINT},
	{"KEY_LL", KEY_LL},
	{"KEY_A1", KEY_A1},
	{"KEY_A3", KEY_A3},
	{"KEY_B2", KEY_B2},
	{"KEY_C1", KEY_C1},
	{"KEY_C3", KEY_C3},
	{"KEY_BTAB", KEY_BTAB},
	{"KEY_BEG", KEY_BEG},
	{"KEY_CANCEL", KEY_CANCEL},
	{"KEY_CLOSE", KEY_CLOSE},
	{"KEY_COMMAND", KEY_COMMAND},
	{"KEY_COPY", KEY_COPY},
	{"KEY_CREATE", KEY_CREATE},
	{"KEY_END", KEY_END},
	{"KEY_EXIT", KEY_EXIT},
	{"KEY_FIND", KEY_FIND},
	{"KEY_HELP", KEY_HELP},
	{"KEY_MARK", KEY_MARK},
	{"KEY_MESSAGE", KEY_MESSAGE},
	{"KEY_MOVE", KEY_MOVE},
	{"KEY_NEXT", KEY_NEXT},
	{"KEY_OPEN", KEY_OPEN},
	{"KEY_OPTIONS", KEY_OPTIONS},
	{"KEY_PREVIOUS", KEY_PREVIOUS},
	{"KEY_REDO", KEY_REDO},
	{"KEY_REFERENCE", KEY_REFERENCE},
	{"KEY_REFRESH", KEY_REFRESH},
	{"KEY_REPLACE", KEY_REPLACE},
	{"KEY_RESTART", KEY_RESTART},
	{"KEY_RESUME", KEY_RESUME},
	{"KEY_SAVE", KEY_SAVE},
	{"KEY_SBEG", KEY_SBEG},
	{"KEY_SCANCEL", KEY_SCANCEL},
	{"KEY_SCOMMAND", KEY_SCOMMAND},
	{"KEY_SCOPY", KEY_SCOPY},
	{"KEY_SCREATE", KEY_SCREATE},
	{"KEY_SDC", KEY_SDC},
	{"KEY_SDL", KEY_SDL},
	{"KEY_SELECT", KEY_SELECT},
	{"KEY_SEND", KEY_SEND},
	{"KEY_SEOL", KEY_SEOL},
	{"KEY_SEXIT", KEY_SEXIT},
	{"KEY_SFIND", KEY_SFIND},
	{"KEY_SHELP", KEY_SHELP},
	{"KEY_SHOME", KEY_SHOME},
	{"KEY_SIC", KEY_SIC},
	{"KEY_SLEFT", KEY_SLEFT},
	{"KEY_SMESSAGE", KEY_SMESSAGE},
	{"KEY_SMOVE", KEY_SMOVE},
	{"KEY_SNEXT", KEY_SNEXT},
	{"KEY_SOPTIONS", KEY_SOPTIONS},
	{"KEY_SPREVIOUS", KEY_SPREVIOUS},
	{"KEY_SPRINT", KEY_SPRINT},
	{"KEY_SREDO", KEY_REDO},
	{"KEY_SREPLACE", KEY_REPLACE},
	{"KEY_SRIGHT", KEY_SRIGHT},
	{"KEY_SRSUME", KEY_SRSUME},
	{"KEY_SSAVE", KEY_SSAVE},
	{"KEY_SSUSPEND", KEY_SSUSPEND},
	{"KEY_SUNDO", KEY_SUNDO},
	{"KEY_SUSPEND", KEY_SUSPEND},
	{"KEY_UNDO", KEY_UNDO},
	{"KEY_MOUSE", KEY_MOUSE},
	{"KEY_RESIZE", KEY_RESIZE},
	{"KEY_EVENT", KEY_EVENT},

	{NULL, NULL}
};
/*****************************************************************************/

EXPORT(get_curses_value, {
	ARG_STRING(0, tag)

	for (int i=0; value_list[i].name != NULL; ++i) {
		if (!strcmp(value_list[i].name, tag)) {
			RETURN_INT(value_list[i].value)
		}
	}

	RETURN_NULL
})

EXPORT(COLOR_PAIR, {
	ARG_INT(0, pair)

	int value = COLOR_PAIR(pair);

	RETURN_INT(value)
})

EXPORT(initscr, {
	WINDOW* window = initscr();

	RETURN_WINDOW(window)
})

EXPORT(cbreak, {
	cbreak();

	RETURN_NULL
})

EXPORT(curs_set, {
	ARG_INT(0, visibility);

	curs_set(visibility);

	RETURN_NULL
})

EXPORT(echo, {
	echo();

	RETURN_NULL
})

EXPORT(init_pair, {
	ARG_INT(0, pair);
	ARG_INT(1, fg);
	ARG_INT(2, bg);

	init_pair(pair, fg, bg);

	RETURN_NULL
})

EXPORT(nocbreak, {
	nocbreak();

	RETURN_NULL
})

EXPORT(noecho, {
	noecho();

	RETURN_NULL
})

EXPORT(set_escdelay, {
	ARG_INT(0, delay);

	set_escdelay(delay);

	RETURN_NULL
})

EXPORT(start_color, {
	start_color();

	RETURN_NULL
})

EXPORT(endwin, {
	endwin();

	RETURN_NULL
})

EXPORT(newwin, {
	ARG_INT(0, height)
	ARG_INT(1, width)
	ARG_INT(2, row)
	ARG_INT(3, col)

	WINDOW* window = newwin(height, width, row, col);

	RETURN_WINDOW(window)
})

EXPORT(attr_get, {
	ARG_WINDOW(0, window)
	
	attr_t attrs;
	short pair;

	wattr_get(window, &attrs, &pair, NULL);

	RETURN_INT(attrs | pair)
})

EXPORT(attroff, {
	ARG_WINDOW(0, window)
	ARG_INT(1, attr)

	wattroff(window, attr);

	RETURN_NULL
})

EXPORT(attron, {
	ARG_WINDOW(0, window)
	ARG_INT(1, attr)

	wattron(window, attr);

	RETURN_NULL
})

EXPORT(attrset, {
	ARG_WINDOW(0, window)
	ARG_INT(1, attr)

	wattrset(window, attr);

	RETURN_NULL
})

EXPORT(border, {
	ARG_WINDOW(0, window)
	ARG_STRING(1, left)
	ARG_STRING(2, right)
	ARG_STRING(3, top)
	ARG_STRING(4, bottom)
	ARG_STRING(5, topLeft)
	ARG_STRING(6, topRight)
	ARG_STRING(7, bottomLeft)
	ARG_STRING(8, bottomRight)

	wborder(window, left[0], right[0], top[0], bottom[0], 
			topLeft[0], topRight[0], bottomLeft[0], bottomRight[0]);

	RETURN_NULL
})

EXPORT(getmaxyx, {
	ARG_WINDOW(0, window)

	int rows = getmaxy(window);
	int columns = getmaxx(window);
	int64_t value = (((int64_t)columns) << 32) | rows;

	RETURN_INT(value)
})

EXPORT(keypad, {
	ARG_WINDOW(0, window)
	ARG_BOOL(1, active)

	keypad(window, active);

	RETURN_NULL
})

EXPORT(mvwaddnstr, {
	ARG_WINDOW(0, window)
	ARG_INT(1, row)
	ARG_INT(2, col)
	ARG_STRING(3, str)
	ARG_INT(4, maxLength)

	mvwaddnstr(window, row, col, str, maxLength);

	RETURN_NULL
})

EXPORT(waddnstr, {
	ARG_WINDOW(0, window)
	ARG_STRING(1, str)
	ARG_INT(2, maxLength)

	waddnstr(window, str, maxLength);

	RETURN_NULL
})

EXPORT(wclear, {
	ARG_WINDOW(0, window)

	wclear(window);

	RETURN_NULL
})

EXPORT(wrefresh, {
	ARG_WINDOW(0, window)

	wrefresh(window);

	RETURN_NULL
})

EXPORT(delwin, {
	ARG_WINDOW(0, window)

	delwin(window);

	RETURN_NULL
})

void wrapped_wgetch(Dart_Port dest_port_id, Dart_CObject* message) {
	Dart_CObject* _window = message->value.as_array.values[0];
	Dart_CObject* _receivePort = message->value.as_array.values[1];

	int64_t window = _window->value.as_int64;
	Dart_Port receivePort = _receivePort->value.as_send_port.id;
	
	int64_t key = wgetch((WINDOW*)window);

	Dart_CObject result;
	result.type = Dart_CObject_kInt64;
	result.value.as_int64 = key;
	Dart_PostCObject(receivePort, &result);
}

EXPORT(new_wgetch, {
	Dart_Port service_port = Dart_NewNativePort("_wgetch", wrapped_wgetch, true);

	if (service_port != ILLEGAL_PORT) {
		RETURN_SEND_PORT(service_port)
	} else {
		RETURN_NULL
	}
})


/*****************************************************************************/

FunctionLookup function_list[] = {
	{"_get_curses_value", d_get_curses_value},
	{"_COLOR_PAIR", d_COLOR_PAIR},

	{"_initscr", d_initscr},
	{"_cbreak", d_cbreak},
	{"_curs_set", d_curs_set},
	{"_echo", d_echo},
	{"_init_pair", d_init_pair},
	{"_nocbreak", d_nocbreak},
	{"_noecho", d_noecho},
	{"_set_escdelay", d_set_escdelay},
	{"_start_color", d_start_color},
	{"_endwin", d_endwin},

	{"_newwin", d_newwin},
	{"_attr_get", d_attr_get},
	{"_attroff", d_attroff},
	{"_attron", d_attron},
	{"_attrset", d_attrset},
	{"_border", d_border},
	{"_getmaxyx", d_getmaxyx},
	{"_keypad", d_keypad},
	{"_mvwaddnstr", d_mvwaddnstr},
	{"_waddnstr", d_waddnstr},
	{"_wclear", d_wclear},
	{"_wrefresh", d_wrefresh},
	{"_delwin", d_delwin},

	{"_new_wgetch", d_new_wgetch},

	{NULL, NULL}
};

FunctionLookup no_scope_function_list[] = {
	{NULL, NULL}
};


/*****************************************************************************/


Dart_Handle HandleError(Dart_Handle handle) {
	if (Dart_IsError(handle)) {
		Dart_PropagateError(handle);
	}
	return handle;
}

Dart_NativeFunction ResolveName(Dart_Handle name,
		int argc,
		bool* auto_setup_scope) {

	if (!Dart_IsString(name)) {
		return NULL;
	}

	if (auto_setup_scope == NULL) {
		return NULL;
	}

	Dart_NativeFunction result = NULL;

	Dart_EnterScope();
	const char* cname;
	HandleError(Dart_StringToCString(name, &cname));

	for (int i=0; function_list[i].name != NULL; ++i) {
		if (strcmp(function_list[i].name, cname) == 0) {
			*auto_setup_scope = true;
			result = function_list[i].function;
			break;
		}
	}

	if (result != NULL) {
		Dart_ExitScope();
		return result;
	}

	for (int i=0; no_scope_function_list[i].name != NULL; ++i) {
		if (strcmp(no_scope_function_list[i].name, cname) == 0) {
			*auto_setup_scope = false;
			result = no_scope_function_list[i].function;
			break;
		}
	}

	Dart_ExitScope();
	return result;
}

DART_EXPORT Dart_Handle dart_curses_Init(Dart_Handle parent_library) {
	if (Dart_IsError(parent_library)) {
		return parent_library;
	}

	Dart_Handle result_code =
		Dart_SetNativeResolver(parent_library, ResolveName, NULL);
	if (Dart_IsError(result_code)) {
		return result_code;
	}

	return Dart_Null();
}
