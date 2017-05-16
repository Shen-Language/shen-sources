[![Current Release](https://img.shields.io/badge/release-20.0-blue.svg)](https://github.com/Shen-Language/shen-sources/releases)

[![Shen Logo](https://raw.githubusercontent.com/Shen-Language/shen-sources/master/assets/shen.png)](http://www.shenlanguage.org)

# Official Shen Sources

This is the official repository for the open-source development of [Mark Tarver's](http://www.marktarver.com/) Shen. Bug reports, suggested enhancements and pull requests are welcome here.

Note that this repository does not contain a runnable implementation of Shen. Certified implementations can be obtained from the [download page](http://www.shenlanguage.org/download_form.html) on [the Shen website](http://www.shenlanguage.org).

## Generating Kλ

To generate Kλ from the Shen sources, acquire a certified port of Shen, version 19.2 or greater. The SBCL port is recommended as it is the de facto standard port and is typically the fastest.

In the Shen REPL, navigate to the `sources/` directory and enter `(load "make.shen")`. Then enter `(make)` and the `*.kl` files will be emitted into the working directory.

## Porting Shen

Refer to `specification/` for instructions on building a certifiable port of Shen. See `certification.pdf` on accreditation of your port.

Happy Programming!

神
