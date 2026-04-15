# poker

This is a plugin for [ddnet++ servers](https://github.com/DDNetPP/DDNetPP) written in lua.
It implements the popular card game texas hold 'em. For now there are only tournaments
and no cash games. The buy in is paid in the ddnet++ currency. Cards are displayed in the world
as unicode strings using nameplates like 🃙🃚. The controls are chat commands such as:
- /poker
- /call
- /allin
- /check
- /raise
- /fold
- /time

![poker preview](https://raw.githubusercontent.com/DDNetPP/cdn/refs/heads/master/poker.png)

## tests

```
luarocks install simple-assert
make test
```

