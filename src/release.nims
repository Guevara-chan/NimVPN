mode = ScriptMode.Verbose
exec """nim compile --d:release --passl:-s --cpu:ia64 -t:-m64 -l:-m64 --out:"../NimVPN.exe" nimvpn.nim"""
if existsFile "../test.exe": rmFile "../test.exe"