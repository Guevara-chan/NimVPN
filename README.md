# •Sum•
NimVPN is a tool to automatically connect you to a random VPN in a country of your choice.  
It uses [openvpn](https://github.com/OpenVPN/openvpn) to connect you to a server obtained from [VPN Gate](http://www.vpngate.net/en/).  
_100% inspired by POSIX-based [autovpn](https://github.com/adtac/autovpn) and 200% ported to Windows and [Nim](http://nim-lang.org)._

# •Reassembling•
First clone the repo and `cd` into the directory:

```
git clone https://github.com/adtac/autovpn
cd autovpn
```

Then run this to generate the executable:

```
nim src\release.nims
```

It's Nim. What do you expect?  
___NimVPN__ uses external [winregistry](https://github.com/miere43/nim-registry) package by miere43._
