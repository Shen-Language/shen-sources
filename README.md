[![Current Release](https://img.shields.io/badge/release-19.3.1-blue.svg)](https://github.com/Shen-Language/shen-sources/releases)

[![Shen Logo](http://www.shenlanguage.org/malcolm_logo_grey.gif)](http://www.shenlanguage.org)

# Official Shen Sources

This is the official repository for the open-source development of [Mark Tarver's](http://www.shenlanguage.org/lambdassociates/htdocs/index.htm) Shen. Bug reports, suggested enhancements and pull requests are welcome here.

Note that this repository does not contain a runnable implementation of Shen. Certified implementations can be obtained from the [download page](http://www.shenlanguage.org/download_form.html) on [the Shen website](http://www.shenlanguage.org).

## Generating Kλ

To generate Kλ from the Shen sources, acquire a certified port of Shen, version 17 or greater. The SBCL port is recommended as it is the de facto standard port and is typically the fastest.

In the Shen REPL, navigate to the `sources/` directory and enter `(load "make.shen")`. Then enter `(make)` and the `*.kl` files will be emitted into the working directory.

## Porting Shen

Refer to `specification/` for instructions on building a certifiable port of Shen. See `certification.pdf` on accreditation of your port.

Happy Programming!

神
