BASE_DIR=$(readlink -f $(dirname $0)/..)

show_art() {
  title=$1
  note=$2
  if [ ! hash figlet 2> /dev/null ]; then
    echo "Needs to install figlet for fancy art"
    sudo apt install figlet -y
  fi
  figlet $title
  echo
  if [ -n "$note" ]; then
    echo "  note:: $note"
    echo
  fi
}

#
# aria2c config
# 
firefox_install() {
  show_art 'firefox'
  echo "ACTION:: installing firefox"
  # aria2c configuration
  if ! test -d /opt/firefox ; then
    firefox_url="https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US"
    curl -sL $firefox_url | sudo tar xj -C /opt
    echo "      :: writting to /opt"
  else
    echo "      :: /opt/firefox already exists."
  fi
}

#
# git
# 
git_install() {
  show_art 'git'
  if git config user.email >/dev/null 2>&1; then
    echo "INFO:: EMAIL already set: $(git config --global user.email)"
  else
    read -p "QUESTION:: Which git EMAIL should be set? " -r
    echo
    git config --global user.email "$REPLY"
    echo "INFO:: Going to set $(git config --global user.email) as git email"
  fi

  if git config user.name >/dev/null 2>&1; then
    echo "INFO:: USER already set: $(git config --global user.name)"
  else
    read -p "QUESTION:: Which git NAME should be set? "
    echo
    git config --global user.name "$REPLY"
    echo "INFO:: Going to set $(git config --global user.name) as git name"
  fi

  if ! git config include.path >/dev/null 2>&1; then
    git config --global include.path $BASE_DIR/git/gitconfig.global
    echo "INFO:: Going to set $(git config --global include.path) as include.path"
  fi
}
declare -a register=(git_install)

#
# zsh
#
zsh_install() {
  show_art 'zsh' 'it may require sudo privileges'
  if ! hash 'zsh' 2>/dev/null; then
    echo "ACTION:: Installing zsh (requires sudo)..."
    sudo apt install zsh -y
  fi
  if [ -d $HOME/.oh-my-zsh ]; then
    zsh $HOME/.oh-my-zsh/tools/upgrade.sh
  else
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  if ! grep -q 'custom zshrc installed via config files' $HOME/.zshrc; then
    echo "ACTION:: writting to $HOME/.zshrc"
    echo "[ -f $BASE_DIR/rc/zshrc ] && . $BASE_DIR/rc/zshrc # custom zshrc installed via config files" >> $HOME/.zshrc
  else
    echo "INFO:: $HOME/.zshrc already been patched."
  fi
}
register+=(zsh_install)

#
# Node
#
node_install() {
  show_art 'node'
  if [ -d $HOME/.nvm ]; then
    echo "ACTION:: Updating node..."
    pushd .
    cd $HOME/.nvm
    git fetch --tags
    TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
    echo "TAG is $TAG"
    git checkout "$TAG"
    popd
  else
    echo "ACTION:: Installing node..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | PROFILE=/dev/null bash
  fi

  echo
  echo "Sourcing nvm.sh"
  source $HOME/.nvm/nvm.sh

  echo
  echo "Installing latest node"

  nvm install node       # install latest stable version
  nvm alias default node # default to latest version
  npm i -g npm
  npm i -g yarn
}
register+=(node_install)

#
# Ruby
#
ruby_install() {
  show_art 'ruby'
  if [ -d $HOME/.rvm ]; then
    echo "ACTION:: Updating rvm..."
    rvm get latest
  else
    echo "ACTION:: Installing rvm..."
    gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDBa
    curl -sSL https://get.rvm.io | bash
  fi

  source $HOME/.rvm/scripts/rvm
  rvm cleanup all

  echo "ACTION:: Installing latest ruby..."
  rvm install --quiet-curl ruby
  rvm use --default ruby
  echo "      :: $(ruby -v)"
}
register+=(ruby_install)

#
# nvm and rvm lazy loading
lazy_load_install() {
  show_art 'lazy_load'
  lazy_load_str='lazy_load installed via linux-config'
  if ! grep -q "$lazy_load_str" $HOME/.zshrc; then
    echo "ACTION:: writting to $HOME/.zshrc"
    echo "[ -s $BASE_DIR/rc/lazy_load.zsh ] && . $BASE_DIR/rc/lazy_load.zsh    # $lazy_load_str" >> $HOME/.zshrc
  else
    echo "INFO:: $HOME/.zshrc already been patched."
  fi
}
register+=(lazy_load_install)

#
# Bibata cursor
#
bibata_install() {
  show_art 'bibata cursor'

  pushd .
  cd $BASE_DIR/shell_extensions
  
  clone_url https://github.com/KaizIqbal/Bibata_Cursor bibata
  
  cd bibata
  ./install.sh
  popd
}

#
# inputrc config
# 
inputrc_install() {
  show_art 'inputrc'
  echo "ACTION:: updating inputrc"
  # inputrc configuration
  if ! test -f $HOME/.inputrc ; then
    echo "      :: writting to $HOME/.inputrc"
    ln -sf $BASE_DIR/rc/inputrc $HOME/.inputrc
  else
    echo "      :: $HOME/.inputrc already exists."
  fi
}
register+=(inputrc_install)

#
# aria2c config
# 
aria2c_install() {
  show_art 'aria2c'
  echo "ACTION:: updating aria2c configuration"
  # aria2c configuration
  if ! test -f $HOME/.aria2c.conf ; then
    echo "      :: writting to $HOME/.aria2c.conf"
    ln -s $BASE_DIR/rc/aria2c.conf $HOME/.aria2c.conf
  else
    echo "      :: $HOME/.aria2c.conf already exists."
  fi
}
register+=(aria2c_install)

#
# VIM
# 
vim_install() {
  show_art 'vim'
  echo "ACTION:: Updating vim-plug"

  sudo apt install -y powerline

  # Updating vim-plug
  curl -sfLo $HOME/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  # vim configuration
  if ! test -f $HOME/.vimrc ||  ! grep -q 'installed via config-files' $HOME/.vimrc; then
    echo "      :: writting to $HOME/.vimrc"
    echo "so $BASE_DIR/rc/vimrc   \" installed via config-files" >> $HOME/.vimrc
  else
    echo "      :: $HOME/.vimrc already been patched."
  fi
  vim -S <(echo -e "PlugInstall \n q \n q")
}
register+=(vim_install)

#
# git
#
lolcommits_install() {
  show_art 'lolcommits'
  sudo apt install -y -q mplayer
  rvm use default
  if [ -f $HOME/.rvm/gems/default/bin/lolcommits ]; then
    gem update --user-install --no-document lolcommits
  else
    echo
    read -p "Install lolcommits to take pictures? y/n (requires ruby): " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      gem install --user-install --no-document lolcommits
      mkdir -p $HOME/.git_template/hooks
      git config init.templatedir = $HOME/.git_template
      if [ ! -f $HOME/.git_template/hooks/post-commit ]; then
        ln -s $BASE_DIR/git/git_template/hooks/post-commit $HOME/.git_template/hooks/post-commit
      fi
    fi
  fi
}
register+=(lolcommits_install)

themes_install() {
  show_art 'gnome themes'
  sudo apt install arc-theme papirus-icon-theme -y -q
}
# register+=(themes_install)

terminal_install() {
  show_art 'terminal (tilix)'
  sudo apt install tilix -y -q
}
register+=(terminal_install)

clone_url() {
  if [ -d $(pwd)/$2 ]; then
    pushd .
    cd $(pwd)/$2
    git pull
    popd
  else
    git clone \
      -c core.eol=lf \
      -c core.autocrlf=false \
		  -c fsck.zeroPaddedFilemode=ignore \
		  -c fetch.fsck.zeroPaddedFilemode=ignore \
		  -c receive.fsck.zeroPaddedFilemode=ignore \
      --depth=1 $1 $(pwd)/$2
  fi
}

extensions_install() {
  
  show_art "gnome extensions"
  mkdir -p $HOME/.local/share/gnome-shell/extensions
  mkdir -p $BASE_DIR/shell_extensions
  pushd .
  GNOME_DIR=$BASE_DIR/shell_extensions

  cd $GNOME_DIR

  show_art "download extensions"
  clone_url https://github.com/micheleg/dash-to-dock.git dash-to-dock
  clone_url https://github.com/kazysmaster/gnome-shell-extension-lockkeys lockkeys
  clone_url https://gitlab.com/jenslody/gnome-shell-extension-openweather.git  openweather
  clone_url https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet monitor-applet
  clone_url https://github.com/eonpatapon/gnome-shell-extension-caffeine caffeine

  # many here
  clone_url https://gitlab.gnome.org/GNOME/gnome-shell-extensions extension-pack

  # Caffeine
  show_art "Caffeine"
  pushd .
  cd $GNOME_DIR/caffeine
  ./update-locale.sh
  glib-compile-schemas --strict --targetdir=caffeine@patapon.info/schemas/ caffeine@patapon.info/schemas
  cp -r caffeine@patapon.info $HOME/.local/share/gnome-shell/extensions
  popd

  # cpufreq
  show_art "cpufreq"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/konkor/cpufreq/master/install_extension.sh)"

  # dash-to-dock
  show_art "dash-to-dock"
  pushd .
  cd $GNOME_DIR/dash-to-dock
  make
  make install
  popd

  # lock keys
  show_art "lock keys"
  pushd .
  cd $GNOME_DIR/lockkeys
  cp -r lockkeys@vaina.lt $HOME/.local/share/gnome-shell/extensions
  popd

  # monitor applet
  show_art "monitor"
  sudo apt-get install -y gir1.2-gtop-2.0 gir1.2-nm-1.0  gir1.2-clutter-1.0
  pushd .
  cd $GNOME_DIR/monitor-applet
  make install
  popd

  # openweather
  show_art "open weather"
  sudo apt install -y -q gnome-common
  pushd .
  cd $GNOME_DIR/openweather
  ./autogen.sh
  make local-install
  popd
  
  # pack
  show_art "Extension pack (user-theme)"
  sudo apt install -y -q meson
  pushd .
  cd $GNOME_DIR/extension-pack
  meson builddir -Dprefix=/home/averissimo/.local
  cd builddir
  ninja install
  popd
  

  sudo apt install -y -q libgtk-3-dev
# end
  popd
}
register+=(extensions_install)

gnome_install() {
  bibata_install
  themes_install
  gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
  gsettings set org.gnome.desktop.interface cursor-theme 'Bibata_Amber'
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
  gsettings --schemadir $HOME/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com/schemas set org.gnome.shell.extensions.user-theme name "Arc-Dark"
 }
register+=(gnome_install)

fonts_install() {
  mkdir -p $HOME/.local/share/fonts
  cp -r $BASE_DIR/fonts/* $HOME/.local/share/fonts/
}
register+=(fonts_install)

deb_install() {
  sudo apt install -y -q flameshot filezilla peek
}
register+=(deb_install)

all_install() {
  for item in ${register[*]}
  do
    eval ${item}
  done
}















