/*
The first operator emits the first item in a source channel, or the first item that matches a condition. 
The condition can be a regular expression, a type qualifier (i.e. Java class), or a boolean predicate.

This operator depends on the ordering of values in the source channel. It can lead to non-deterministic behavior if used improperly.
non-deterministic behavior: A process that merges inputs from different sources non-deterministically may invalidate the cache.
*/

workflow {
       // no condition is specified, emits the very first item: 1
       channel.of( 1, 2, 3 )
              .first()
              .view{ x -> "FIRST_VALUE -> $x" }

       // emits the first item matching the regular expression: 'aa'
       channel.of( 'a', 'aa', 'aaa' )
              .first( ~/aa.*/ )
              .view{ x -> "REGEX_MATCH -> $x" }

       // emits the first String value: 'a'
       channel.of( 1, 2, 'a', 'b', 3 )
              .first( String )
              .view{ x -> "FIRST_STRING -> $x" }

       // emits the first item for which the predicate evaluates to true: 4
       channel.of( 1, 2, 3, 4, 5 )
              .first { v -> v > 3 }
              .view{ x -> "FIRST_TRUE -> $x" }
}