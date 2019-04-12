import os, ospaths, osproc, streams, httpclient, strformat, strutils, base64, terminal, winregistry, sequtils
const header = """# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
                  # NimVPN private network autosetup v0.1 #
                  # Developed in 2019 by Victoria Guevara #
                  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
                """.replace("  ", "")

#.{ [Procs]
proc main(country: string): string =
    fgGreen.styledEcho styleBright, header
    # Parsing OpenVPN location.
    let exe     = try: "HKEY_LOCAL_MACHINE\\SOFTWARE\\OpenVPN".open(samRead).readString("exe_path") except: ""
    if exe == "": return "[nimvpn] FAULT:: unable to locate OpenVPN !"
    let config  = getTempDir().joinPath "vpnconfig.tmp"
    let command = fmt"{exe} --connect-retry-max 2 --connect-timeout 10 --config {config}"
    # Parsing server list.
    let url = "http://www.vpngate.net/api/iphone/"
    fgYellow.styledEcho styleBright, "[nimvpn] getting server list..."
    let list = try: newHttpClient().getContent(url).splitLines[2..^3] except: @[]
    if list.len == 0: return fmt"[nimvpn] FAULT:: unable to load {url} !"
    fgMagenta.styledEcho styleBright, fmt"[nimvpn] looking for VPNs from {country}:"
    # Main parsing loop.
    for idx, entry in list.mapIt(it.split(",").seq[:string]):
        if entry.len != 15: fgRed.styledEcho(fmt"[nimvpn] invalid entry encountered."); continue
        if country != entry[6]: continue
        config.writeFile entry[14].decode()
        fgCyan.styledEcho styleBright, fmt"[nimvpn] running OpenVPN for {entry[1]} [{idx}/{list.len}]"
        try:
            let openvpn = command.startProcess(options={poEvalCommand})
            defer: openvpn.terminate()
            while openvpn.running: # Piping openVPN output to stdout.
                let output = (500.sleep(); openvpn.outputStream.readAll())
                stdout.write output
                if output.find("Initialization Sequence Completed") > -1: break
            stdout.styledWrite fgCyan,"[nimvpn] try another VPN ? (y/n) "
            while (let inchar = try: getch().toLowerAscii except: ' '; true): # Auxiliary (y/n) input.                
                if inchar in ['y', 'n']: styledEcho $inchar else: continue
                if inchar == 'n': return "[nimvpn] Terminated by user request." else: break
        except: return "[nimvpn] FAULT:: unable to start OpenVPN !"
    fgWhite.styledEcho styleBright, "[nimvpn] === end of list reached ==="
#.}

# -Main code-
let report = main(if paramCount() > 1: paramStr(1) else: "US")
if report != "": stdout.styledWrite fgRed, styleBright, report
3000.sleep()