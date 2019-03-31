import os, ospaths, osproc, streams, times, httpclient, strformat, strutils, base64, terminal, winregistry
let header = """  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
                  # NimVPN private network autosetup v0.1 #
                  # Developed in 2019 by Victoria Guevara #
                  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
             """
#.{ [Procs]
proc main(country: string): string =
    styledEcho fgGreen, styleBright, header.replace("  ", "")
    # Parsing OpenVPN location.
    let config  = getTempDir().joinPath "vpnconfig.tmp"
    let exe     = try: "HKEY_LOCAL_MACHINE\\SOFTWARE\\OpenVPN".open(samRead).readString("exe_path") except: ""
    if exe == "": return "[nimvpn] FAULT:: unable to locate OpenVPN ! "
    let command = fmt"{exe} --connect-retry-max 2 --connect-timeout 10 --config {config}"
    # Parsing server list.
    styledEcho fgYellow, styleBright, "[nimvpn] getting server list..."
    let list = newHttpClient().getContent("http://www.vpngate.net/api/iphone/").splitLines[2..^1]
    styledEcho fgMagenta, styleBright, fmt"[nimvpn] looking for VPNs from {country}:"
    # Main parsing loop.
    for entry in list:
        let chunks = entry.split ','
        if chunks.len < 15: break
        if country != chunks[6]: continue
        config.writeFile chunks[14].decode()
        styledEcho fgCyan, styleBright, fmt"[nimvpn] running OpenVPN for {chunks[1]}."
        try:
            let openvpn = command.startCmd
            defer: openvpn.terminate()
            while openvpn.running:
                500.sleep()
                let output = openvpn.outputStream.readAll()
                stdout.write output
                if output.find("Initialization Sequence Completed") > -1: break
            stdout.styledWrite fgCyan,"[nimvpn] try another VPN ? (y/n) "
            if stdin.readLine.toLowerAscii[0] == 'n': break
            openvpn.terminate()
        except: return "[nimvpn] FAULT:: unable to start OpenVPN !"
#.}

# -Main code-
stdout.styledWrite fgRed, styleBright, main(if paramCount() > 1: paramStr(1) else: "US")
3000.sleep()
quit 0