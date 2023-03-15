#!/bin/bash

gnome-extensions show hidetopbar@mathieu.bidon.ca | grep -q 'State: ENABLED' \
  && gnome-extensions disable hidetopbar@mathieu.bidon.ca \
  || gnome-extensions enable hidetopbar@mathieu.bidon.ca 

dconf read /org/gnome/shell/extensions/dash-to-dock/intellihide-mode | grep 'ALL_WINDOWS' \
  && dconf write /org/gnome/shell/extensions/dash-to-dock/intellihide-mode "'FOCUS_APPLICATION_WINDOWS'" \
  || dconf write /org/gnome/shell/extensions/dash-to-dock/intellihide-mode "'ALL_WINDOWS'"
