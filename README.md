# GearMenu

![](/docs/gm_ragedunicorn_love_classic.png)

> GearMenu aims to help the player switching between items in and out of combat. When the player is in combat a combatqueue will take care of switching the item as soon as possible. It also allows you to define switching rules and keybinding slots.

![](/docs/badge_wow_classic.png)

## Installation

WoW-Addons are installed directly into your WoW directory:

`[WoW-installation-directory]\Interface\AddOns`

Make sure to get the newest version of the Addon from the releases tab:

[GearMenu-Releases](https://github.com/RagedUnicorn/wow-classic-gearmenu/releases)

> Note: If the Addon is not showing up in your ingame Addonlist make sure that the Addon is named `GearMenu` in your Addons folder

## What is GearMenu?

GearMenus goal is to help the player switching between items on certain slots. Often players have items such as engineering items that have a one time use followed by a long cooldown. After using them during a fight the player wants to switch back to a more useful item. While changing items during combat is not possible (with some exceptions such as weapons) GearMenu can help with switching them as soon as possible. When a player tries to switch an item during combat it will be put into the combatqueue and switched as soon as possible. If the player leaves combat for just a split second all the items in the combatqueue will be switched. For some classes this might be even easier because they can use spells such as rogue - vanish or hunter - feign death.

**Supported slots:**

| Slotname          | Description                  |
|-------------------|------------------------------|
| HeadSlot          | Head/Helmet slot             |
| NeckSlot          | Neck slot                    |
| ShoulderSlot      | Shoulder slot                |
| ChestSlot         | Chest/Robe slot              |
| WaistSlot         | Waist/Belt slot              |
| LegsSlot          | Legs slot                    |
| FeetSlot          | Feet/Boots slot              |
| WristSlot         | Wrist/Bracers slot           |
| HandsSlot         | Hands slot                   |
| Finger0Slot       | First/Upper ring slot        |
| Finger1Slot       | Second/Upper ring slot       |
| Trinket0Slot      | First/Upper trinket slot     |
| Trinket1Slot      | Second/Lower trinket slot    |
| BackSlot          | Back/Cloak slot              |
| MainhandSlot      | Main-hand slot               |
| SecondaryHandSlot | Secondary-hand/Off-hand slot |
| RangedSlot        | Ranged slot                  |

## Features of GearMenu

### Item switch for certain slots

With GearMenu it is easy to switch between items in supported slots. This is especially useful for engineering items that you wear for a certain amount of time and then switch back to your usual gear.

TODO add gif

### CombatQueue

Certain items cannot be switched while the player is in combat. Weapons will be switched immediately whether the player is in combat or not. Other items that cannot be switched in combat will be enqueued in the combatqueue and switched as soon as possible. This is especially useful in PvP when you leave combat for a short time.

> Note: You can right click any slot to clear the combatqueue for that slot

TODO add gif

### Quick Change

Quick change consists of rules that apply when certain items are used. The player can define rules for items that have a usable effect. An item might be immediately switched after use or only after a certain delay. Otherwise the same rules for item switching apply. This means that if the user is in combat it will be moved to the combat queue and if he is out of combat the item will be immediately switched. See the optionsmenu for defining new rules based on the item type.

> Note: If an item has a buff effect and you immediately change the item you will usually also lose its buff. In most cases it makes sense to set the delay to the duration of the buff

TODO add gif

After adding such a rule you can try it out.

TODO add gif

### Keybinding

GearMenu allows to keybind to every slot with a keybinding. Instead of having a keybind for every item that you have to remember you set it directly on the slot itself.

TODO add gif

### Drag and drop support

GearMenu allows to drag and drop items onto slots, remove from slots and slots can even be switched in between.

#### Drag and drop between slots
TODO add gif

#### Drag and drop item to GearMenu
TODO add gif

#### Unequip item by drag and drop
TODO add gif

## Configurability

GearMenu is configurable. Don't need a certain slot? You can hide it.

To show the configuration screen use `/rggm opt` while ingame and `/rggm info` for an overview of options or check the standard blizzard addon options.

### Hide/Show Cooldowns

TODO add gif

### Hide/Show Keybindings

TODO add gif

### Lock/Unlock Window

TODO add gif

### Filter Items by Quality

Not interested to see items with a quality level below a certain level? Filter them out and only items that meet your set level will be considered to be displayed in GearMenu.

TODO add gif

## FAQ

#### The Addon is not showing up in WoW. What can I do?

Make sure to recheck the installation part of this Readme and check that the Addon is placed inside `[WoW-installation-directory]\Interface\AddOns` and is correctly named as `GearMenu`.

#### I get a red error (Lua Error) on my screen. What is this?

This is what we call a Lua error and it usually happens because of an oversight or error by the developer (in this case me). Take a screenshot off the error and create a Github Issue with it and I will see if I can resolve it. It also helps if you can add any additional information of what you we're doing at the time and what other addons you have active. Also if you are able to reproduce the error make sure to check if it still happens if you disable all others addons.

#### GearMenu failed to switch my item. What happened?

There are certain limitations that make it harder to switch an item even if the player is out of combat. One such example is that WoW prevents switching items while the player is casting a spell. GearMenu detects this and changes the item as soon as there is a pause between two spells or if a spell was cancelled. Just keep this in mind if you absolutely need the item switch to happen as soon as possible. Another factor can be a loss of control effect such as sap, iceblock and similar effects. In such circumstances it is not possible to switch an item. GearMenu is aware of such effects on the player and will switch the item as soon as possible.

If you still think you found an issue where GearMenu doesn't switch items as expected feel free to create an [issue](https://github.com/RagedUnicorn/wow-classic-gearmenu/issues).

## Development

### Switching between Environments

Switching between development and release can be achieved with maven.

```
mvn generate-resources -Dgenerate.sources.overwrite=true -P development
```

This generates and overwrites `GM_Environment.lua` and `GearMenu.toc`. You need to specifically specify that you want to overwrite to files to prevent data loss. It is also possible to omit the profile because development is the default profile that will be used.

Switching to release can be done as such:

```
mvn generate-resources -Dgenerate.sources.overwrite=true -P release
```

In this case it is mandatory to add the release profile.

**Note:** Switching environments has the effect changing certain files to match an expected value depending on the environment. To be more specific this means that as an example test and debug files are not included when switching to release. It also means that variables such as loglevel change to match the environment.

As to not change those files all the time the repository should always stay in the development environment. Do not commit `GearMenu.toc` and `GM_Environment.lua` in their release state. Changes to those files should always be done inside `build-resources` and their respective template files marked with `.tpl`.

### Packaging the Addon

To package the addon use the `package` phase.

```
mvn package -Dgenerate.sources.overwrite=true -P development
```

This generates an addon package for development. For generating a release package the release profile can be used.

```
mvn package -Dgenerate.sources.overwrite=true -P release
```

**Note:** This packaging and switching resources can also be done one after another.

```
# switch environment to release
mvn generate-resources -Dgenerate.sources.overwrite=true -P release
# package release
mvn package -P release
```

### Deploy a Release

Before creating a new release update `addon.tag.version` in `pom.xml`. Afterwards to create a new release and deploy to GitHub the `deploy` profile has to be used.

```
# switch environment to release
mvn generate-resources -Dgenerate.sources.overwrite=true -P release
# deploy release to GitHub
mvn package -P deploy
```

For this to work an oauth token for GitHub is required and has to be configured in your `.m2` settings file.

## License

MIT License

Copyright (c) 2019 Michael Wiesendanger

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
