[![Current Release](https://img.shields.io/badge/release-22.2-blue.svg)](https://github.com/Shen-Language/shen-sources/releases)

# Official Shen Sources

<a href="http://www.shenlanguage.org">
  <img src="https://raw.githubusercontent.com/Shen-Language/shen-sources/master/assets/shen.png" align="right">
</a>

This is the official repository for the open-source development of [Mark Tarver's](http://www.marktarver.com/) Shen. Bug reports, suggested enhancements and pull requests are welcome here.

Note that this repository does not contain a runnable implementation of Shen. Downloads for the [de-facto reference implementation](https://github.com/Shen-Language/shen-cl) are available on its [releases page](https://github.com/Shen-Language/shen-cl/releases). Other certified implementations are linked on [the Shen Open Source website](http://shen-language.github.io).

Documentation for the Shen Language is the [shendoc](http://shenlanguage.org/shendoc.htm) hosted on the [main website](http://www.shenlanguage.org).

## Generating Kλ

Shen is a self-hosted language, so its kernel implementation is written in Shen. Building Kλ from the Shen sources requires an executable built from the previous release of Shen.

### Using Pre-Built shen-cl (Recommended)

A prebuilt copy of the reference implementation can be pulled down by running `make fetch`. The executable `shen` will be dropped under the `shen-cl` folder. Render the Kλ by running `make klambda` or just `make`.

### Using Another Executable

Using your own executable is the same as above, except you override the `Shen` variable like this: `make klambda Shen="/path/to/shen"`.

## Releases

Release packages containing the pre-built Kλ and the test suite are created using `make release`. Archives appear under the `release/` folder in both `zip` and `tar.gz` format.

Packages can be created for any version, but when uploading to the releases page, make sure to have built the specific tagged revision.

```
make pure
git checkout shen-22.2
make fetch
make klambda
make release
```

Building release packages on Windows currently requires the [7-zip](http://www.7-zip.org/) command `7z` to be accessible from the command line.

## Porting Shen

Refer to `doc/` and [the wiki](https://github.com/Shen-Language/wiki/wiki) for instructions on building a certifiable port of Shen. If you get your port to run the standard test suite successfully, let us know on [the mailing list](https://groups.google.com/forum/#!forum/qilang) and your port will be certified.

Happy Programming!

神
