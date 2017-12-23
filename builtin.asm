.dict

# Stack operations
dup:
movb _ T 1 0 1
jr

.:
movb N T -1 0 0 # N = N
jr

swap:
movb N R 0 1 0 # R.push(N)
movb _ T -1 0 1 # T = N, pop
jal r>
jr

drop:
jal .
jr

nip:
movb _ T -1 0 1 # N=T, pop

rot:
jal >r
jal swap
jal r>
jal swap
jr

# Memory operations
!:
movb N [T] 0 0 0
jr

@:
movb [T] T 1 0 0
jr

# Address stack operations
>r:
movb _ R -1 1 1
jr

r>:
movb R T 1 -1 0
jr

r@:
movb R T 1 0 0
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
movb _ T -1 0 1
imm 0
_max_else:
jal .
jal .
jr

min:
slt N T 1 0 0 # _T =  T < N
jz _max_else
# 1 T N, T < N
jal . # T N
movb _ T -1 0 1
imm 0
_max_else:
jal .
jal .
jr
