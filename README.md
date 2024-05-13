## Important User Notice

This repository contains a partial Shen language implementation, aimed at developers working on Shen itself, **not** a full version ready for general programming use.

> For beginners, it is **highly** recommended that they start first with the [main website](https://shenlanguage.org) and to join [the mailing list](https://groups.google.com/forum/#!forum/qilang).

To write and run Shen programs, please use one of these user-friendly options:

- **Windows Users**: Download pre-compiled [SBCL port binaries](https://shenlanguage.org/download.html).
- **Direct from Source**: Non-Windows users can obtain the [latest sources](https://shenlanguage.org/download.html) and run `(load "install.lsp")` in an SBCL REPL.
- **Shen/Scheme**: Explore [Shen/Scheme](https://github.com/tizoc/shen-scheme), available as binaries or buildable from source.

These resources provide complete Shen environments for programming. 

---

[![Current Release](https://img.shields.io/badge/release-38.3-blue.svg)](https://github.com/Shen-Language/shen-sources/releases)

# Shen Sources

<a href="http://www.shenlanguage.org">
  <img src="https://raw.githubusercontent.com/Shen-Language/shen-sources/master/assets/shen.png" align="right">
</a>

This repository hosts a slightly modified version of the sources for the kernel of [Mark Tarver's](http://www.marktarver.com/) Shen programming language.

Note that this repository does not contain a runnable implementation of Shen, just the language kernel code that can be used by porters to create a full implementation of the language.

> **NOTE** To obtain a runnable version, consider the reference implementation from the [main website](https://shenlanguage.org/download.html) or [Shen/Scheme](https://github.com/tizoc/shen-scheme).

Documentation for the Shen Language is the [shendoc](http://shenlanguage.org/shendoc.htm) hosted on the [main website](http://www.shenlanguage.org).

## Generating Kλ

> **IMPORTANT** This is not required when downloading the [releases](https://github.com/Shen-Language/shen-cl/releases) (recommended).

Shen is a self-hosted language, so its kernel implementation is written in Shen. Building Kλ from the Shen sources requires an executable built from the previous release of Shen.

### Using Pre-Built Shen/Scheme (Recommended)

A prebuilt copy of a reference implementation can be pulled down by running `make fetch`. The executable `shen-scheme` will be dropped under the `shen-scheme/bin` folder. Render the Kλ by running `make klambda` or just `make`.

### Using Another Executable

Using your own executable is the same as above, except you override the `Shen` variable like this: `make klambda Shen="/path/to/shen"`.

## Releases

Release packages containing the pre-built Kλ and the test suite are created using `make release`. Archives appear under the `release/` folder in both `zip` and `tar.gz` format.

Packages can be created for any version, but when uploading to the releases page, make sure to have built the specific tagged revision.

```
make pure
git checkout shen-38.3
make fetch
make klambda
make release
```

Building release packages on Windows currently requires the [7-zip](http://www.7-zip.org/) command `7z` to be accessible from the command line.

## Porting Shen

Refer to `doc/` and [the wiki](https://github.com/Shen-Language/wiki/wiki) for instructions on building a certifiable port of Shen. If you get your port to run the standard test suite successfully, let us know on [the mailing list](https://groups.google.com/forum/#!forum/qilang) and your port will be certified.

Happy Programming!

神
