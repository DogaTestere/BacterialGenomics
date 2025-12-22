/*
The dump operator prints each item in a source channel when the pipeline is executed with the -dump-channels command-line option, otherwise it does nothing. 
It is a useful way to inspect and debug channels quickly without having to modify the pipeline script.
The tag option can be used to select which channels to dump:
*/

channel.of( 1, 2, 3 )
    .map { v -> v + 1 }
    .dump(tag: 'plus1')

channel.of( 1, 2, 3 )
    .map { v -> v ** 2 }
    .dump(tag: 'exp2')

/*
[DUMP: plus1] 2
[DUMP: exp2] 1
[DUMP: plus1] 3
[DUMP: exp2] 4
[DUMP: exp2] 9
[DUMP: plus1] 4
*/