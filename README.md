## @averissimo

> customizations for linux

Run `setup.sh` to get most of the customizations

## Info

* Terminal: `sudo apt install tilix`
  * Fancy fonts in terminal: `sudo apt install powerline`
    * Fantasque is installed with `setup.sh`
  * [zsh](https://ohmyz.sh/): `sudo apt install zsh && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
* Theme:
  * arc-theme: `sudo apt install arc-theme`
  * papirus icons: `sudo apt install papirus-icon-theme`

## Open in Tilix _(nautilus)_

Install actions

```
sudo apt install filemanager-actions nautilus-actions
sudo apt remove nautilus-extension-gnome-terminal
```

Create new action with the command `tilix` and parameters `--working-directory=%d/%b`

## Wacom

Inside the `wacom` folder are scripts to run the shortcuts

`xsetwacom.sh` should be run at startup

## Some general configurations

Firefox nightly 

* shortcut at `nightly.desktop`
* Insert new tabs next to current: `browser.tabs.insertAfterCurrent true` 

### Tweaks

#### Appearance

Applications: Arc-Dark
Cursor: [Bibata\_Ice](https://www.pling.com/s/Gnome/p/1197198/)
Icons: Papirus-Dark
Shell: Arc-Dark

#### Fonts

https://github.com/ryanoasis/nerd-fonts/releases

Interface text: `Intel Clear Light`
Document text: `Intel Clear Regular`
Monospace text: `Knack Nerd Regular` *with powerline*
Legacy window titles: `Intel Clear Bold`


