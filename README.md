# •Sum•
`NimVPN` is a tool to automatically connect you to a random VPN in a country of your choice.  
It uses [openvpn](https://github.com/OpenVPN/openvpn) to connect you to a server obtained from [VPN Gate](http://www.vpngate.net/en/).  
_100% inspired by POSIX-based [autovpn](https://github.com/adtac/autovpn) and 200% ported to Windows and [Nim](http://nim-lang.org) by [d38k8](https://github.com/d38k8)'s request._  
❗ _Needs elevated UAC ('Run as administator' works fine) to work properly._ ❗

# •Featuræ•
* No data feeds required, fully based on trusted remote server list.
* No config required except providing desirable VPN country as cmdline arg (_US_ by defalut).
* No installation required, running single executable with OpenVPN present in system is enough.

# •Reassembling•
First clone the repo and `cd` into the directory:

```
git clone https://github.com/adtac/autovpn
cd autovpn\src
```

Then run this to generate the executable:

```
nim release.nims
```

It's Nim. What do you expect?  
___NimVPN__ uses external [winregistry](https://github.com/miere43/nim-registry) package by miere43._

# •Brief sample of private networking•
![image](https://user-images.githubusercontent.com/8768470/55900440-e16ebe80-5bcf-11e9-9231-ad34bb77e6b2.png)
