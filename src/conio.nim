# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
# Con/IO terminal library v0.1
# Developed in 2019 by V.A. Guevara
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
from strutils import join
import terminal, unicode, encodings, encodings_aux
export unicode

# [OS-dependent bindings]
when defined(windows):
    const max_buf = 256
    type
        Coord = object
            x, y: int16
        SmallRect = object
            left, yop, right, bottom: int16
        BufferInfo = object
            size, cursor_pos: Coord
            attribs:          int16
            window:           SmallRect
            max_win_size:     Coord
        CursorInfo = object
            size:             int
            visible:          bool
    proc get_char(): cint                               {.header: "<conio.h>", importc: "_getwch".}
    proc get_echoed_char(): cint                        {.header: "<conio.h>", importc: "_getwche".}
    proc set_console_title(title: WideCString): cint    {.stdcall, dynlib: "kernel32", importc: "SetConsoleTitleW".}
    proc get_console_title(title: WideCString, size: int): cint {.stdcall,dynlib:"kernel32",importc:"GetConsoleTitleW".}
    proc beep(freq: int, duration: int): cint           {.stdcall, dynlib: "kernel32", importc: "Beep".}
    proc get_key_state(code: int): cint                 {.stdcall, dynlib: "user32", importc: "GetKeyState".}
    proc get_console_output_cp(): cint                  {.stdcall, dynlib: "kernel32", importc: "GetConsoleOutputCP".}
    proc get_console_input_cp(): cint                   {.stdcall, dynlib: "kernel32", importc: "GetConsoleCP".}
    proc get_console_window(): cint                     {.stdcall, dynlib: "kernel32", importc: "GetConsoleWindow".}
    proc show_window(win: int, flags: int): cint        {.stdcall, dynlib: "user32", importc: "ShowWindow".}
    proc is_window_visible(win: int): cint              {.stdcall, dynlib: "user32", importc: "IsWindowVisible".}
    proc get_std_handle(flag: int = -11): File          {.stdcall, dynlib: "kernel32", importc: "GetStdHandle".}
    proc get_cursor_info(cout: File, info: ptr CursorInfo): bool
        {.stdcall, dynlib: "kernel32", importc: "GetConsoleCursorInfo".}
    proc get_console_buffer_info(cout: File, info: ptr BufferInfo): cint 
        {.stdcall, dynlib: "kernel32", importc: "GetConsoleScreenBufferInfo".}
    proc set_console_buffer_info(cout: File, info: ptr BufferInfo): cint 
        {.stdcall, dynlib: "kernel32", importc: "SetConsoleScreenBufferInfo".}
    proc set_console_buffer_size(cout: File, size: Coord): bool 
        {.stdcall, dynlib: "kernel32", importc: "SetConsoleScreenBufferSize".}
    let cout = get_std_handle()
    template cursor_info(): CursorInfo =
        var info: CursorInfo
        discard cout.get_cursor_info info.addr
        info
    template buffer_info(): BufferInfo =
        var info: BufferInfo
        discard cout.get_console_buffer_info info.addr
        info
else: {.fatal: "FAULT:: only Windows OS is supported for now !".}

#.{ [Classes]
when not defined(con):
    # --Service definitions:
    type 
        con* {.package.} = object
        con_cursor       = object
        color_names      = enum
            black, dark_blue, dark_green, dark_cyan, dark_red, dark_magenta, dark_yellow, gray,
            dark_gray, blue, green, cyan, red, magenta, yellow, white
    const
        color_impl = [(fgBlack, false), (fgBlue, false), (fgGreen, false), (fgCyan, false), (fgRed, false), 
        (fgMagenta, false), (fgYellow, false), (fgWhite, false), (fgBlack, true), (fgBlue, true), (fgGreen, true), 
        (fgCyan, true), (fgRed, true), (fgMagenta, true), (fgYellow, true), (fgWhite, true)]
    var 
        (fg_color, bg_color) = (colorNames.gray, colorNames.black)
        out_conv, in_conv: EncodingConverter
    using
        Δ:      type con
        cur:    type con_cursor
        list:   varargs[auto, `$`]
        color:  color_names
        
    # --Methods goes here:
    # •Handles•
    proc output*(Δ): File {.inline.} = stdout
    proc input*(Δ): File {.inline.}  = stdin
    proc window*(Δ): int {.inline.}  = get_console_window().int

    # •Output•
    proc write*(Δ, list): auto {.inline.}   = (for entry in list: con.output.write out_conv.convert entry)
    proc write_line*(Δ; t: auto) {.inline.} = con.write t; con.write '\n'
    proc log*(Δ, list) {.inline.}           = con.write_line list.join " "
    proc clear*(Δ) {.inline.}               = eraseScreen()

    # •Input•
    proc readline*(Δ): string {.discardable inline.}               = in_conv.convert con.input.readLine
    proc read*(Δ): int16 {.discardable inline.}                    = getChar().int16
    proc read_key*(Δ; echoed = false): Rune {.discardable inline.} = (if echoed:get_echoed_char() else: con.read).Rune

    # •Colors•
    template colors*(_: type con): auto         = color_names
    proc foreground_color*(Δ, color) {.inline.} = fg_color
    proc background_color*(Δ, color) {.inline.} = bg_color
    proc `foreground_color=`*(Δ, color) {.inline.} =
        let (shade, bright) = color_impl[color.int]
        con.output.setForegroundColor shade, bright
        fg_color = color
    proc `background_color=`*(Δ, color) {.inline.} =
        let (shade, bright) = color_impl[color.int]
        con.output.setBackgroundColor (shade.int+10).BackgroundColor, bright
        bg_color = color
    proc reset_color*(Δ) {.inline.} = (con.foregroundColor, con.backgroundColor) = (con.colors.gray, con.colors.black)

    # •Sizing•
    proc set_buffer_size*(Δ; w=120, h=9001) {.inline.}  = 
        if not cout.set_console_buffer_size Coord(x: w.int16, y: h.int16):
            raise newException(Exception, "Invalid buffer size provided")
    proc window_width*(Δ): int {.inline.}               = buffer_info().window.right + 1
    proc window_height*(Δ): int {.inline.}              = buffer_info().window.bottom + 1
    proc buffer_width*(Δ): int {.inline.}               = buffer_info().size.x
    proc buffer_height*(Δ): int {.inline.}              = buffer_info().size.y
    proc `buffer_width=`*(Δ, w: int) {.inline.}         = con.set_buffer_size(w, con.buffer_height)
    proc `buffer_height=`*(Δ, h: int) {.inline.}        = con.set_buffer_size(con.buffer_width, h)

    # •Cursor controls•
    template cursor*(_: type con): auto                   = con_cursor
    proc set_cursor_position*(Δ; x = 0, y = 0) {.inline.} = con.output.setCursorPos(x, y)
    proc top*(cur): int {.inline.}                        = buffer_info().cursor_pos.y
    proc left*(cur): int {.inline.}                       = buffer_info().cursor_pos.x
    proc visible*(cur): bool {.inline.}                   = cursor_info().visible
    proc height*(cur): int {.inline.}                     = cursor_info().size
    proc `top=`*(cur; y: int) {.inline.}                  = con.set_cursor_position(con.cursor.x, y)
    proc `left=`*(cur; x: int) {.inline.}                 = con.set_cursor_position(x, con.cursor.y)
    proc `visible=`*(cur; val: bool) {.inline.}           = (if val: showCursor() else: hideCursor())

    # •Misc•
    proc beep*(Δ; freq = 800, duration = 200) {.inline.}  = discard freq.beep duration
    proc caps_lock*(Δ): bool {.inline.}                   = (0x14.get_key_state and 0x0001) != 0
    proc number_lock*(Δ): bool {.inline.}                 = (0x90.get_key_state and 0x0001) != 0
    proc output_encoding*(Δ): string {.inline.}           = get_console_output_cp().codePageToName
    proc input_encoding*(Δ): string {.inline.}            = get_console_input_cp().codePageToName
    proc visible*(Δ): bool {.inline.}                     = con.window.is_window_visible()
    proc title*(Δ): string {.inline.}                     =
        let buffer = cast[WideCString](array[max_buf, Utf16Char].new)
        discard buffer.getConsoleTitle max_buf
        return $buffer
    proc `visible=`*(Δ; val: bool) {.inline.}             = discard con.window.show_window(val.int)
    proc `title=`*(Δ; title: auto) {.inline.}             = discard $(title).newWideCString.setConsoleTitle

    # --Pre-init goes here:
    con.resetColor()
    out_conv = encodings.open(con.output_encoding, "UTF-8")
    in_conv  = encodings.open("UTF-8", con.input_encoding)
#.}

# ==Testing code==
when isMainModule: include "../examples/hello_world.nim"