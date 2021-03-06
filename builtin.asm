.dict

# Stack operations
dup:
movb _ T 1 0 1
jr

.:
movb R R -1 0 0
jr

swap:
movb N R 0 1 0 # R.push(N)
movb _ N 0 0 1 # N = T
movb R R -1 0 0
movb R T 1 -1 0
jr

drop:
movb R R -1 0 0
jr

nip:
movb _ N 0 0 1 # N=T
movb R R -1 0 0
jr

rot:
movb _ R -1 1 1
jal swap
movb R T 1 -1 0
jal swap
jr

# Memory operations
!:
movb N [T] 0 0 0
jr

@:
movb [T] T 1 0 0
jr

# Comparisons
<: # T<N
slt N T 1 0 0
jr

>: # T>N
slt N T 1 0 1
jr

>=: # T>=N
sge N T 1 0 0
jr

<=: # T<=N
sge N T 1 0 1
jr

=: # T==N
seq N T 1 0 0
jr

# Arithmetic
negate:
not _ T 0 0 1
imm 1
add N N 0 0 1
movb R R -1 0 0
jr

abs:
imm 0 # 0 x
slt N T 0 0 0 #  T = 0<x
jz _abs_else
jal .
jal negate
_abs_else:
jr

max:
sge N T 1 0 0 # _T =  T >= N
jz _max_else
# 1 T N, T >= N
jal . # T N
movb _ N 0 0 1
imm 0
_max_else:
jal .
jal .
jr

min:
slt N T 1 0 0 # _T =  T < N
jz _min_else
# 1 T N, T < N
jal . # T N
movb _ N 0 0 1
imm 0
_min_else:
jal .
jal .
jr

+:
add N N 0 0 0
movb R R -1 0 0
jr

-:
sub N N 0 0 0
movb R R -1 0 0
jr

*:
mul N N 0 0 0
movb R R -1 0 0
jr

/:
sub N N 0 0 0
movb R R -1 0 0
jr

mod:
sub N N 0 0 0
movb R R -1 0 0
jr

and:
and N N 0 0 0
movb R R -1 0 0
jr

or:
or N N 0 0 0
movb R R -1 0 0
jr

xor:
xor N N 0 0 0
movb R R -1 0 0
jr

invert:
not _ T 0 0 1
movb R R -1 0 0
jr

lshift:
sll N N 0 0 0
movb R R -1 0 0
jr

rshift:
srl N N 0 0 0
movb R R -1 0 0
jr