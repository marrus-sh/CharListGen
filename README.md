#  CharListGen  #

Creates a list of characters from codepoints in STDIN and saves them
  as a file named `charlist` in the current working directory.

(Writing to STDOUT is not supported to ensure control characters are
  handled correctly.)

##  Input format  ##

Codepoints must be listed one per line, as hex numbers in the range
  0000–10FFFF.
Codepoints may be followed by any number of additional characters (on
  the same line); which may be used as documentation.
Codepoints may optionally be preceded by the string `U+`.

Characters must be separated by at least one non–codepoint line.
This may be blank, or have additional documentation.
This allows for the distinguishing of multi–codepoint characters.

The following is an example input file:

    This is a character consisting of a single codepoint:
    00C6 LATIN CAPITAL LETTER AE
    + This is a very cool character!!

    This is a character consisting of multiple codepoints:
    0041 LATIN CAPITAL LETTER A
    030A COMBINING RING ABOVE
    = LATIN CAPITAL LETTER A WITH RING ABOVE

##  Output format  ##

Characters will be listed 16‐per‐line, with lines terminated by U+000D
  CARRIAGE RETURN, U+000A LINE FEED.
Characters will be padded with following U+0000 NULL characters such
  that they are all of the same length.
Additionally, the final line will be padded with U+0000 NULL characters
  at the end to bring it to the same length of the others.
The maximum character size can consequently be calculated by taking
  the codepoint length of any line and dividing it by 16.

Note that U+000D CARRIAGE RETURN, U+000A LINE FEED, and U+0000 NULL
  characters are otherwise significant and may appear elsewhere in the
  output.
Consequently, special considerations will need to be made when
  processing the output files of inputs where U+000D CARRIAGE RETURN
  and U+000A LINE FEED are given in sequence.

The example input file above would output a UTF-8 file containing the
  following codepoints:

    0000 00C6
    0041 030A
    0000 0000
    0000 0000
    0000 0000
    0000 0000
    0000 0000
    0000 0000
    0000 0000
    0000 0000
    0000 0000
    0000 0000
    0000 0000
    0000 0000
    0000 0000
    0000 0000
