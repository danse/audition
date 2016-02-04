### How to run this

    $ cabal sandbox init
    $ cabal run audition test/5.json

### About performance

#### Hamiltonian

Since the problem seems not to have a known efficient algorithm, I
tried to use a backtracking approach based on lazy evaluation of an
exaustive search

#### Eulerian

Here i found two known algorithms that had been more efficient than
exaustive search, but i relied on the same approach i used for the
Hamiltonian, both to save time and in the hope to reuse some code. I
didn't have time to extract the common abstractions

### About quality

#### Reliability

I didn't have the time to set up a proper test suite, thus there could
be several errors. I tested with the files under `test/`, and with the
interpreter in some cases.

#### Robustness

I didn't add any sanity check about the structure of the graph, and i
didn't test malformed graphs. However, the search functions work
reducing the graph in parts, thus a malformed graph should lead to a
research within a consistent part of it. In other terms, the expected
behaviour in case of malformed graphs is to terminate with some kind
of solution. This behaviour might or might not be desired

#### Elegance

There are some popular Haskell libraries for graphs manipulation and
backtracking, which i had tried harder to use if this was a
middle-term project

#### User Interface

This is very poor. I simply use `show` in many cases. The error
returned by Aeson in the case of empty edges in a connection is
unintellegible, try `test/8.json` to see by yourself
