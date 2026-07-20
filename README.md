# 🖥️ LuaCCT

> Lua programs for [CC: Tweaked](https://tweaked.cc/) computers in Minecraft — a multi-floor networked elevator and a tiny over-the-air update system.

![Lua](https://img.shields.io/badge/Lua-CC%3A%20Tweaked-2C2D72?style=flat&logo=lua&logoColor=white)
![Minecraft](https://img.shields.io/badge/Minecraft-mod%20scripts-62B47A?style=flat)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)

## 📁 What's inside

| Path | Runs on | Purpose |
|------|---------|---------|
| `elevator/master.lua` | Elevator controller computer | Drives the physical elevator: floor calibration, call queue, lock/unlock |
| `elevator/slave.lua` | Per-floor panel computer | Touch-screen call panel with floor display and sound effects |
| `pocket/lift.lua` | Pocket computer | CLI remote control for the elevator |
| `pocket/qq.lua` | Pocket computer | CLI for sending OTA commands to computer groups |
| `lib/OTA.lua` | Everywhere | Shared OTA protocol library (send + handle packets) |
| `OS/OTA/startup.lua` | Any managed computer | Boot-time OTA daemon that listens for remote commands |

## 🛗 Elevator

A rednet-based elevator system built around an elevator-pulley peripheral and an electric motor (Create-ecosystem peripherals):

- 📏 **Auto-calibration** — the master measures pulley distance per floor on first start to detect where each floor is
- 📥 **Call queue** — floor calls are queued and resolved one by one by a path-solver loop
- 🖵 **Floor panels** — each floor's computer shows the current floor on a monitor: green when the lift is at your floor, orange while it's on the way; tap the screen to call it
- 🔊 **Sound feedback** — speaker chimes on call and arrival
- 🔒 **Lockdown** — the whole elevator can be locked/unlocked remotely (stops the motor)
- 📡 **Live state broadcast** — the master broadcasts floor/target/queue over rednet ten times a second

Pocket remote usage:

```sh
lift go <floor>   # call the elevator to a floor
lift lock         # stop the motor and freeze the lift
lift unlock       # resume operation
```

## 📡 OTA

A minimal "over-the-air" management layer for a fleet of computers. Each computer runs `OS/OTA/startup.lua` on boot and belongs to a **group** (stored in its settings; hold `f` during the 3-second boot window to change it). From a pocket computer:

```sh
qq <group> run <command>    # execute a shell command on every computer in the group
qq <group> launch <path>    # require() a program returning a function table and run it in parallel
qq <group> group <newgroup> # reassign a group remotely
```

`elevator/slave.lua` is written in this launchable style — it returns its loop functions as a table, so floor panels can be (re)deployed over the air without touching them.

## 🚀 Setup

1. Attach a wireless modem to every computer (sides used in the scripts: `back` for panels/pockets, `bottom` for the master).
2. Copy `lib/OTA.lua` next to the scripts that `require("OTA")`.
3. Install `OS/OTA/startup.lua` as `startup.lua` on managed computers, `elevator/master.lua` on the controller, and the `pocket/` tools on your pocket computer.
4. On each floor panel, enter its floor number once — it's saved via the CC settings API.

## 📄 License

MIT — see [LICENSE](LICENSE).
