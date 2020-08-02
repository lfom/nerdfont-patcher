# Nerd Font Patcher
Nerd Fonts are great, but if you want to patch your own fonts? Cloning the whole Nerd Fonts repository will download a lot of things, like Open Source un-patched fonts and the whole set of already patched ones, it will also require some reading of the [documentation](https://github.com/ryanoasis/nerd-fonts#font-patcher) for patching your own fonts.

Nerd Font Patcher is a simple script that will download (only once) all the required files from Nerd Fonts repo and create two sets of the fonts found in the provided folder: Complete (apply all glyphs to the font) and Complete Mono (all glyphs but using monospace toggle).

It also provides some extra features, thanks to the great work by [Adam Cooper](https://github.com/adam7) in his [Delugia Code](https://github.com/adam7/delugia-code) workflow:

- Font cleanup (removal of internal inconsistencies)
- Some special glyphs are added by default from the famous [Hack font](https://github.com/source-foundry/Hack)
- Proper font naming using Nerd Fonts standard


## What is Nerd Fonts anyway?
[Nerd Fonts](https://www.nerdfonts.com) takes popular programming fonts and adds a bunch of Glyphs. They include all the absolutely [indispensable symbols](https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points) all nerds need in their favorite fonts.
Go to their [repository](https://github.com/ryanoasis/nerd-fonts) or have a look at the [overview](https://www.nerdfonts.com/#cheat-sheet).

The available patched fonts use the _Complete_ set of glyphs, that includes:
- Powerline Symbols
- [Seti-UI](https://atom.io/themes/seti-ui#current_icons)
- [Devicons](http://vorillaz.github.io/devicons/)
- [Powerline Extra Symbols](https://github.com/ryanoasis/powerline-extra-symbols)
- [Pomicons](https://github.com/gabrielelana/pomicons)
- [Font Awesome](https://github.com/FortAwesome/Font-Awesome) and [Extension](https://github.com/AndreLZGava/font-awesome-extension)
- [Power Symbols](https://unicodepowersymbol.com/)
- [Material Design Icons](https://github.com/Templarian/MaterialDesign)
- [Font Logos](https://github.com/Lukas-W/font-logos)
- [Octicons](https://github.com/github/octicons)

## Which fonts are generated
For each font found in the provided directory, two files are generated: Mono and normal. The only difference is that the Mono version uses the `mono` toggle that creates single-width glyphs, it does not change the source font itself. The other toggles used are (more info in the [font-patcher documentation](https://github.com/ryanoasis/nerd-fonts#font-patcher)):
```
--careful                       # Do not overwrite existing glyphs
-c                              # Same as --complete
--custom SomeExtraSymbols.otf   # See bellow
-ext [EXTENSION]                # The script tries to detect if it is a TTF or OTF font
--quiet                         # Passed to FontForge to avoid verbosity
--no-progressbars               # No progress bars
```


These glyphs are added from [Hack font](https://github.com/source-foundry/Hack) to `SomeExtraSymbols.otf`, and can be customized in the `extract-extra-glyphs` script:
- Extra symbols: ``≢`` (0u2262), ``≣`` (0u2263), ``❯`` (0u276F), and ``⚡`` (0u26A1)

The `prepare-font` script simply opens the file with [FontForge](https://fontforge.org) and save them again to fix some internal structure errors if any, while `cleanup-font` saves the patched font using Nerd Font format: FAMILYNAME_STYLE_NERD_FONT_COMPLETE\[\_MONO\].

PS: The generated fonts may now work correctly on Windows, due to a limitation of 31 characters in the font name.

## Requirements
Besides `bash` and `curl`, the script uses `fc-scan` that is included in `fontconfig` package to retrieve font data, all of them should be installed by default on any Linux distribution, but macOS users may need to use `brew`. The only extra dependency is [FontForge](https://fontforge.org).

## How to use
Simply clone this repository (or download then unzip), then run:
```
bash nerdfont-patcher.sh FOLDER
```
where _FOLDER_ is the directory that contains the fonts to be patched.

<br/>

### Acknowledgements
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) - Ryan L McIntyre
- [Delugia Code](https://github.com/adam7/delugia-code) - Adam Cooper


### License

MIT © [lfom](https://lfom.tk)
