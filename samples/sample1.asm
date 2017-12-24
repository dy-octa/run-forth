.dict
.:
movb R R -1 0 0
jr

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

.text
imm 1
imm 2
jal min

.dict
dup:
movb _ T 1 0 1
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

.text
jal dup
movb _ R -1 1 1
movb R T 1 -1 0
movb R T 1 0 0
imm 2
jal max
jal drop