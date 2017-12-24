0 1 2
: storeloop ( -- ) 5 0 do 10 r> r@ if r@ ! . then >r . loop ;
swap dup >r r> storeloop
