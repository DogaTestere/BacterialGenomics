/*
The filter operator emits the items from a source channel that satisfy a condition, discarding all other items. 
The filter condition can be a literal value, a regular expression, a type qualifier (i.e. Java class), or a boolean predicate.
*/

workflow {
    // Filter out the numbers
    channel.of("hello!","000000","aaaA",000, 0.5)
           .filter(Number)
           .view { x -> "NUMBERS -> $x" }

    // Filter out the values that have uppercase letters
    channel.of("hello!","000000","aaaA",000, 0.5, "aaaaa")
           .filter(~/.*[A-Z].*/)
           .view { x -> "UPPERCASE -> $x" }

    // Filter out ANY numbers
    channel.of("hello!","000000","aaaA",000, 0.5)
           .filter(~/[0-9]/)
           .view { x -> "HAS DIGIT -> $x" }

    // Filter out only numbers in strings
    channel.of("hello!","000000","aaaA",000, 0.5)
            .filter { x -> x instanceof String && x ==~ /^\d+$/ }
            .view { x -> "NUMBER_IN_STRING -> $x" }
}

/*
channel.of("hello!","000000","aaaA",000, 0.5)
        .filter( ~/^[^A-Za-z]*\d[^A-Za-z]*$/ )
        .view { x -> "NUMBER_IN_STRING -> $x" }

This one was finding the regular numbers too because all of the values were being turned into stings before passing through the regex
*/

/*
UPPERCASE -> aaaA
NUMBERS -> 0
NUMBERS -> 0.5
NUMBER_IN_STRING -> 000000
HAS DIGIT -> 0
*/