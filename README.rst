***
DRY
***

.. image:: https://img.shields.io/badge/license-Public%20Domain-blue.svg
   :alt: Project license
   :target: https://unlicense.org

.. image:: https://img.shields.io/travis/dryproject/drylang/master.svg
   :alt: Travis CI build status
   :target: https://travis-ci.org/dryproject/drylang

|

*An experimental programming language.*

Caveats
=======

*This is a semi-public, pre-alpha, work-in-progress project.*

**Here be dragons.**

**Caveat utilitor:** assume nothing works, and you may be pleasantly
surprised; and when it breaks, you get to keep both pieces.

Prerequisites
=============

Build Prerequisites
-------------------

- `OCaml <https://ocaml.org>`__
  4.06+

- `Dune (aka Jbuilder) <https://github.com/ocaml/dune>`__
  1.0+beta20

- `GNU Make <https://www.gnu.org/software/make/>`__
  3.81+

Runtime Prerequisites
---------------------

The installed binaries have no runtime requirements or dependencies beyond
the system's standard library (``libc``).

Installation
============

Installation on Unix
--------------------

::

   $ make && sudo make install

Configuration
=============

::

   $ export DRY_ROOT=$HOME/.dry

   $ mkdir -p $DRY_ROOT

   $ cd $DRY_ROOT && git clone https://github.com/dryproject/drylib.git drylib

Usage
=====

::

   $ dry analyze --help         # analyze code
   $ dry check --help           # type-check code
   $ dry compile --help         # compile program
   $ dry describe --help        # describe a term
   $ dry evaluate --help        # evaluate code
   $ dry execute --help         # execute function
   $ dry export --help          # export terms into a target language
   $ dry format --help          # reformat code
   $ dry index --help           # show the package index
   $ dry locate --help          # locate the source file for a term
   $ dry optimize --help        # optimize code
   $ dry parse --help           # parse code
   $ dry shell --help           # the interactive DRY shell
   $ dry translate --help       # translate code

Syntax
======

Scalar Literals
---------------

=============================================== ================================
Literal                                         Type
=============================================== ================================
``true``, ``false``                             ``base/bool``
``'foobar``                                     ``base/symbol``
``1.23``                                        ``base/float``
``123``                                         ``base/integer``
``1/3``, ``-3/4``                               ``base/rational``
``1+2i``                                        ``base/complex``
``99%``                                         ``base/float``
``0b01011101``                                  ``base/word``
``0o775``                                       ``base/word``
``0xDEADBEEF``                                  ``base/word``
``\x41``                                        ``base/char``
``\u0041``                                      ``base/char``
``\U0001D306``                                  ``base/char``
``"hello"``                                     ``text/utf8/string``
``@2020-12-31T23:59:59``                        ``time/instant``
``<urn:ietf:rfc:2648>``                         ``std/ietf/urn``
``<http://example.org/>``                       ``std/ietf/url``
``123e4567-e89b-12d3-a456-426655440000``        ``std/ietf/uuid``
=============================================== ================================
