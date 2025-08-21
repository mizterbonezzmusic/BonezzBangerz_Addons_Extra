# bonezz-dealers-blips

Adds configurable **map blips** for your NPC drug dealer locations.

## Install
1) Upload the folder **bonezz-dealers-blips** to your server at:
   `resources/[npc]/bonezz-dealers-blips`  (or any category folder you use)
2) Add to `server.cfg` (place with other resources):
   `ensure bonezz-dealers-blips`
3) Restart the server (or run `refresh` then `ensure bonezz-dealers-blips` in the console).

## Configure
- Edit `config.lua` -> `Config.Dealers` list.
- Each entry supports:
  - `label` (string): blip name
  - `coords` (vector3): location
  - `sprite` (number): blip icon id (default 84)
  - `color` (number): blip color id (default 27)
  - `scale` (number): size (default 0.9)
  - `shortRange` (bool): show only when nearby (default true)
  - `radius` (number): optional radius circle, set > 0.0 to enable
  - `radiusColor`/`radiusAlpha`: styling for radius

No dependencies. Works with QBCore/ESX or standalone.
