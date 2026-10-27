import sys
f=open(sys.argv[1]).read().split(); b=sys.argv[2]
n,m=int(f[0]),int(f[1]); 
if len(b)!=n: sys.exit(1)
i=2;ok=True
for _ in range(m):
    s=False
    while f[i]!='0':
        l=int(f[i]); i+=1
        if (l>0)==(b[abs(l)-1]=='1'): s=True
    i+=1
    if not s: ok=False;break
sys.exit(0 if ok else 1)
