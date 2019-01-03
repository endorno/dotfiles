# dotfiles

# setup
```
pip install dotfiles
git clone git@github.com:endorno/dotfiles.git .dotfiles
ln -snf .dotfiles/dotfilesrc .dotfilesrc
dotfiles -s
```


if windows,
```
New-Item -Path . -Name .dotfilesrc -Value .dotfiles/dotfilesrc -ItemType SymbolicLink
```
