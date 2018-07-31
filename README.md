# Index of Ancient Greek Lexica

This repository contains code and data for a searchable index of a variety of Ancient Greek lexica, available via GitHub Pages here: <https://dcthree.github.io/ancient-greek-lexica/>

The main client-side JavaScript/CoffeeScript is in `src/js/lexica.coffee`. Scripts for data processing are in the `_scripts` directory. A `Makefile` is provided for automatically updating `data/headwords.json` (the comprehensive JSON index) and `data/all_headwords_unique.csv` (not used by the client-side JS, but handy for research).

A checklist of lexica is a available in [the `LEXICA.md` file](https://github.com/dcthree/ancient-greek-lexica/blob/master/LEXICA.md).
