convert-websters
================

Convert Webster's Unabridged Dictionary from Project Gutenberg to OSX dictionary

## Overview

After reading James Somers' [excellent article][jsomersDictionary] about the
differences in quality between dictionaries, I was prompted to follow his method
for getting Webster's 1913 into Dictionary.app.

The directions worked as promised, but I was dissapointed with the formatting.
In particular, I was troubled by the hard line breaks at about 80 characters
and the way that the pronunciation, part of speech, and etymology were not
clearly separated from the rest of the entry.

To get something more like what I was looking for, I started with a copy of
[Webster's Unabridged Dictionary][gutenbergWebsters] from Project Gutenberg and
wrote this script to convert it to the XML that Apple's Dictionary Development
Kit takes as input.

In addition to the convert-dsm.pl script for making XML, I wrote the  convert-
web.pl script to produce the word and index files required for a static website.
The other parts needed for a static site (client-side search, mostly) have their
own [repository][dictionarySiteRepo].

## If you just want the results

If you don't care to run the script yourself and just want the finished
dictionary, you can download an [installer package][installerPackage] that will
put the finished dictionary in ~/Library/Dictionaries for you.

If you'd prefer to view the dictionary as a [static web site][staticSite] you
can do that too.

## Prerequisites

You'll need a copy of the [Gutenberg document][gutenbergWebsters] and Apple's
Dictionary Development Kit, which is in the "Auxiliary Tools for Xcode - October
2013" package at  [Downloads for Apple Developers][developerDownloads]

## Usage

The Gutenberg text should have the beginning and end trimmed off for proper
parsing.  Line endings should also be made to match whatever is standard on the
local machine.

Assuming OSX with a copy of the Gutenberg text in ../29765 and a Dictionary
Development Kit project at ../ddk_project, this should do the trick:

    tr -d "\r" < ../29765/29765.txt.utf-8 | tail -n +27 | head -n 973878 | \
    ./convert-dsm.pl > ../ddk_project/WebstersUnabridged.xml

[jsomersDictionary]: http://jsomers.net/blog/dictionary
[gutenbergWebsters]: http://www.gutenberg.org/ebooks/29765
[developerDownloads]: https://developer.apple.com/downloads/index.action
[installerPackage]: http://dictionary.parksdigital.com/Webster%27s%20Unabridged%20Dictionary.pkg
[staticSite]: http://dictionary.parksdigital.com/
[dictionarySiteRepo]: https://github.com/aparks517/dictionary-site