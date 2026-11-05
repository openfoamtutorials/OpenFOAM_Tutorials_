# -*- coding: utf-8 -*-
"""Bagimsiz inp kontrolu (python3 + numpy, Abaqus GEREKMEZ).
Kullanim: python3 check_inp.py inp/BENCH_F6_TIE.inp 152.7778   (dT [K] = 275 F)
inp dosyasini okur, CGAX4 termoelastik problemi uniform dT altinda cozer:
mesh baglantisi, malzeme sirasi, *Equation, *Tie ve *Boundary kontrolu.
Kontakt modelinde arayuz radyalde bagli kabul edilir; *Elastic icin ilk satir
(EXP modellerinde DOC<=0.2 kurlenmemis ozellikler) kullanilir."""
import sys, re, numpy as np
path, dT = sys.argv[1], float(sys.argv[2])
lines=[l.rstrip() for l in open(path) if not l.startswith('**')]
blocks=[]; cur=None
for l in lines:
    if l.startswith('*'):
        cur=[l,[]]; blocks.append(cur)
    elif cur is not None: cur[1].append(l)
def kv(h):
    d={}
    for p in h.split(',')[1:]:
        if '=' in p: a,b=p.split('=',1); d[a.strip().lower()]=b.strip()
        else: d[p.strip().lower()]=True
    return d
def nums(rows):
    out=[]
    for r in rows:
        for x in r.split(','):
            x=x.strip(); out.append(float(x) if x else None)
    return out
nodes={}; elems={}; elsets={}; nsets={}; mats={}; sec={}; eqs=[]; bcs=[]; tie=None; cmat=None; contact=None
for h,rows in blocks:
    k=h.split(',')[0].lower(); p=kv(h)
    if k=='*node':
        for r in rows: a=nums([r]); nodes[int(a[0])]=(a[1],a[2])
    elif k=='*element':
        es=p.get('elset')
        for r in rows:
            a=[int(x) for x in nums([r])]; elems[a[0]]=a[1:]; elsets.setdefault(es,[]).append(a[0])
    elif k=='*elset': elsets[p['elset']]=[int(x) for x in nums(rows)]
    elif k=='*nset':
        if 'elset' in p: nsets[p['nset']]=sorted({n for e in elsets[p['elset']] for n in elems[e]})
        else: nsets[p['nset']]=[int(x) for x in nums(rows)]
    elif k=='*solid section': sec[p['elset']]=p['material']
    elif k=='*material': cmat=p['name']; mats[cmat]={}
    elif k in ('*elastic','*expansion') and cmat: mats[cmat][k]=(p,nums(rows))
    elif k=='*equation':
        i=0
        while i<len(rows):
            n=int(rows[i]); a=nums([rows[i+1]]); eqs.append([(int(a[3*j]),int(a[3*j+1]),a[3*j+2]) for j in range(n)]); i+=2
    elif k=='*boundary' and 'amplitude' not in p:
        for r in rows: a=[x.strip() for x in r.split(',')]; bcs.append((a[0],int(a[1]),int(a[2])))
    elif k=='*tie': tie=[x.strip() for x in rows[0].split(',')]
    elif k=='*contact pair': contact=[x.strip() for x in rows[0].split(',')]
    elif k=='*step': break
def Dmat(m):
    p,v=mats[m]['*elastic']
    if p.get('type','').upper().startswith('ANISO'):
        v=[x for x in v[:21]]; D=np.zeros((6,6)); c=0
        for I in range(6):
            for J in range(I+1): D[J,I]=D[I,J]=v[c]; c+=1
    else:
        E,nu=v[0],v[1]; l=E*nu/((1+nu)*(1-2*nu)); mu=E/(2*(1+nu)); D=np.zeros((6,6)); D[:3,:3]=l; D[[0,1,2],[0,1,2]]+=2*mu; D[3,3]=D[4,4]=D[5,5]=mu
    p,v=mats[m]['*expansion']
    if p.get('type','').upper().startswith('ANISO'): a=np.array(v[:6]); a[3:]*=2  # tensor->eng
    else: a=np.array([v[0]]*3+[0,0,0])
    return D,a
ids=sorted(nodes); idx={n:i for i,n in enumerate(ids)}; nd=3*len(ids)  # dof: ur, uz, phi
def g(n,dof): return 3*idx[n]+{1:0,2:1,5:2}[dof]
K=np.zeros((nd,nd)); F=np.zeros(nd)
emat={}
for es,m in sec.items():
    for e in elsets[es]: emat[e]=m
gp=[-1/np.sqrt(3),1/np.sqrt(3)]
for e,conn in elems.items():
    D,a=Dmat(emat[e]); X=np.array([nodes[n] for n in conn])
    for xi in gp:
        for eta in gp:
            N=0.25*np.array([(1-xi)*(1-eta),(1+xi)*(1-eta),(1+xi)*(1+eta),(1-xi)*(1+eta)])
            dN=0.25*np.array([[-(1-eta),(1-eta),(1+eta),-(1+eta)],[-(1-xi),-(1+xi),(1+xi),(1-xi)]])
            J=dN@X; dX=np.linalg.solve(J,dN); r=N@X[:,0]; w=np.linalg.det(J)*r
            assert np.linalg.det(J)>0, 'negatif jacobian %d'%e
            B=np.zeros((6,12))
            for i in range(4):
                B[0,3*i]=dX[0,i]; B[1,3*i+1]=dX[1,i]; B[2,3*i]=N[i]/r
                B[3,3*i]=dX[1,i]; B[3,3*i+1]=dX[0,i]; B[4,3*i+2]=r*dX[0,i]; B[5,3*i+2]=r*dX[1,i]
            dofs=[3*idx[n]+k for n in conn for k in range(3)]
            K[np.ix_(dofs,dofs)]+=B.T@D@B*w; F[dofs]+=B.T@D@(a*dT)*w
cons=[]
for s,d1,d2 in bcs:
    for n in nsets[s]:
        for d in range(d1,d2+1): cons.append([(g(n,d),1.0)])
for eq in eqs: cons.append([(g(n,d),c) for n,d,c in eq])
pair=tie or contact
if pair:  # secondary (C_IN) dugumlerini ayni konumdaki main dugumune bagla
    sec_n=sorted({n for e in elsets['C_FIRST'] for n in elems[e][::3]}) # n1,n4
    main_n=sorted({n for e in elsets['M_LAST'] for n in elems[e][1:3]})
    for s in sec_n:
        m=min(main_n,key=lambda q: abs(nodes[q][0]-nodes[s][0])+abs(nodes[q][1]-nodes[s][1]))
        dl=[1,2,5] if tie else [1]
        for d in dl: cons.append([(g(s,d),1.0),(g(m,d),-1.0)])
C=np.zeros((len(cons),nd))
for i,c in enumerate(cons):
    for j,v in c: C[i,j]+=v
C*=np.mean(np.abs(np.diag(K)))
A=np.block([[K,C.T],[C,np.zeros((len(cons),len(cons)))]]); b=np.concatenate([F,np.zeros(len(cons))])
sol=np.linalg.solve(A,b); u=sol[:nd]
rank=np.linalg.matrix_rank(A,tol=1e-9*np.abs(A).max()); print('sistem boyutu %d, rank %d %s'%(A.shape[0],rank,'(tekil degil)' if rank==A.shape[0] else '(!! tekil/asiri kisit)'))
dz=max(v[1] for v in nodes.values())
m=nsets['N_MASTER'][0]
print('eksenel gerinim = %.0f ue'%(u[g(m,2)]/dz*1e6))
for s in sorted(nsets):
    if s.startswith('GM_') or s.startswith('GC_'):
        n=nsets[s][0]; print('  %-14s r=%.5f  hoop=%.0f ue'%(s,nodes[n][0],u[g(n,1)]/nodes[n][0]*1e6))
