# -*- coding: utf-8 -*-
"""
Calius, Lee & Springer (1990) F-1/F-4/F-6 silindirleri icin TAM Abaqus 2025
input dosyalarini (*.inp) dogrudan yazar. Abaqus/CAE GEREKMEZ (saf python3).

    python3 write_inp.py            -> inp/BENCH_F6_TIE.inp, inp/F6_EXP.inp,
                                       inp/F1_EXP.inp, inp/F4_EXP.inp
    abaqus job=BENCH_F6_TIE input=inp/BENCH_F6_TIE.inp cpus=1

Model (build_model.py ile ayni kurgu, duz "flat" inp, part/assembly yok):
  * CGAX4T (genellestirilmis eksenel simetri + burulma, coupled T-u), eksenel
    dilim DZ, ply ply +phi/-phi, mandrel Al 6061-T6
  * Alt yuz U2 = 0, burulma (DOF5) = 0 ; ust yuz *Equation -> esit eksenel uzama
    ve esit burulma (eksenel kuvvet = 0, tork = 0)
  * Mandrel ic yuzeyi T = Tm(t), kompozit dis yuzeyi T = Tc(t)
  * BENCH: *Tie ; EXP: hard kontakt (ayrilabilir, surtunmesiz) + gap conductance
  * Kur: *Cure Kinetics (KAMAL), *Cure Heat Generation, (EXP) *Cure Shrinkage
    + *User Defined Field, type=SPECIFIED (FV1 = DOC). Alt program YOK.

Dugum numaralari: mandrel 1.., kompozit 100001..  (z satiri basina +1000)
Eleman yuzleri (CGAX4): S1 alt, S2 r+ , S3 ust, S4 r-
"""
from __future__ import print_function
import os
import calius_data as cd
import kw_gen as kw

# (model adi, durum, etkilesim 'TIE'|'CONTACT', eksenel 'EQUAL'|'SLIP')
MODELS = [
    ('BENCH_F6_TIE', 'BENCH', 'TIE', 'EQUAL'),
    ('F6_EXP', 'F6', 'CONTACT', 'EQUAL'),
    ('F1_EXP', 'F1', 'CONTACT', 'EQUAL'),
    ('F4_EXP', 'F4', 'CONTACT', 'EQUAL'),
]
DZ = 0.5e-3
NZ = 1
NEL_MANDREL = 10
EL_PER_PLY = 2
H_CONTACT = 1.0e6
GAP_TABLE = ((H_CONTACT, 0.0), (300.0, 1.0e-4), (0.0, 1.0e-3))
DT_INIT, DT_MIN, DT_MAX, DELTMX = 10.0, 1.0e-4, 60.0, 5.0
N_FIELD_INTERVALS = 200

BASE_M, BASE_C, ROW = 0, 100000, 1000
OUTDIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'inp')


def _lines(vals, per=16, fmt='%d'):
    vals = list(vals)
    return '\n'.join(', '.join(fmt % v for v in vals[i:i + per]) for i in range(0, len(vals), per))


def _nset(name, labels):
    return '*Nset, nset=%s\n%s' % (name, _lines(sorted(labels)))


def _elset(name, labels):
    return '*Elset, elset=%s\n%s' % (name, _lines(sorted(labels)))


def _amp(name, pts):
    flat = []
    for t, v in pts:
        flat += [t, v]
    return '*Amplitude, name=%s, time=STEP TIME\n%s' % (name, _lines(flat, per=8, fmt='%.6g'))


def _block(nid_base, rs):
    """Yapisal mesh: dugum ve eleman sozlukleri."""
    nodes, elems = {}, {}
    for j in range(NZ + 1):
        z = DZ * j / NZ
        for i, r in enumerate(rs):
            nodes[nid_base + j * ROW + i + 1] = (r, z)
    for j in range(NZ):
        for i in range(len(rs) - 1):
            n1 = nid_base + j * ROW + i + 1
            n2, n3, n4 = n1 + 1, n1 + 1 + ROW, n1 + ROW
            elems[nid_base + j * ROW + i + 1] = (n1, n2, n3, n4)
    return nodes, elems


def _nid(base, i, j):
    return base + j * ROW + i + 1


def build_inp(mname, case, inter, axial):
    cyl = cd.BENCH if case == 'BENCH' else cd.CYLINDERS[case]
    g = cd.geometry_SI(cyl)
    r0, r1, r2 = g['r_m_in'], g['r_if'], g['r_out']
    N, tp, phi = g['n_plies'], g['t_ply'], g['phi']
    nC = N * EL_PER_PLY

    rsM = [r0 + (r1 - r0) * i / NEL_MANDREL for i in range(NEL_MANDREL + 1)]
    rsC = [r1 + tp * i / EL_PER_PLY for i in range(nC + 1)]
    rsC[-1] = r2
    nM, eM = _block(BASE_M, rsM)
    nCn, eC = _block(BASE_C, rsC)

    top, bot = NZ, 0
    iM_last, iC_last = NEL_MANDREL, nC
    # setler
    M_IN = [_nid(BASE_M, 0, j) for j in range(NZ + 1)]
    C_OUT = [_nid(BASE_C, iC_last, j) for j in range(NZ + 1)]
    M_BOT = [_nid(BASE_M, i, bot) for i in range(NEL_MANDREL + 1)]
    C_BOT = [_nid(BASE_C, i, bot) for i in range(nC + 1)]
    C_BOT_BC = C_BOT[1:] if inter == 'TIE' else C_BOT
    M_TOP = [_nid(BASE_M, i, top) for i in range(NEL_MANDREL + 1)]
    C_TOP = [_nid(BASE_C, i, top) for i in range(nC + 1)]
    master = _nid(BASE_M, iM_last, top)          # mandrel ust dugum, r = r_if
    masterC = _nid(BASE_C, iC_last, top)

    plyP, plyM = [], []
    for j in range(NZ):
        for i in range(nC):
            ply = i // EL_PER_PLY
            (plyP if ply % 2 == 0 else plyM).append(BASE_C + j * ROW + i + 1)
    M_LAST = [BASE_M + j * ROW + iM_last for j in range(NZ)]
    C_FIRST = [BASE_C + j * ROW + 1 for j in range(NZ)]
    ih2 = nC // 2
    EL_H2 = [BASE_C + j * ROW + i + 1 for j in range(NZ) for i in (ih2 - 1, ih2)]

    # gauge dugumleri (alt satir)
    gkeys = ['mandrel_in', 'if', 'h4', 'h2', 'h34', 'out'] if case == 'BENCH' else \
        sorted(set(cd.GAUGES[case]['T'] + cd.GAUGES[case]['S']))
    gauges, report = [], []
    for key in gkeys:
        rg = cd.gauge_radius(g, key)
        cands = []
        if key in ('mandrel_in', 'if'):
            i = min(range(len(rsM)), key=lambda k: abs(rsM[k] - rg))
            cands.append(('GM_' + key.upper(), _nid(BASE_M, i, bot), rsM[i]))
        if key != 'mandrel_in':
            i = min(range(len(rsC)), key=lambda k: abs(rsC[k] - rg))
            cands.append(('GC_' + key.upper(), _nid(BASE_C, i, bot), rsC[i]))
        for nm, lab, rr in cands:
            gauges.append((nm, lab, rr))
            report.append('**   %-12s r_hedef=%.6f r_dugum=%.6f m  dugum %d' % (nm, rg, rr, lab))

    tm, tc = cd.surface_amplitudes_SI(case)
    tend = max(tm[-1][0], tc[-1][0])
    T0 = 0.5 * (tm[0][1] + tc[0][1])

    # ---------------- yazim ----------------
    L = []
    L.append('*Heading\nCalius-Lee-Springer 1990: %s (%s, %s, %s) CGAX4T dilim modeli, SI (m,kg,s,K)'
             % (mname, case, inter, axial))
    L.append('** r_mandrel_ic=%.6f r_arayuz=%.6f r_dis=%.6f m ; %d ply x %.4e m ; +-%.0f deg ; DZ=%.3g m'
             % (r0, r1, r2, N, tp, phi, DZ))
    L.append('** Mandrel kalinligi: %s' % ('VARSAYIM 0.25 in (makalede yok)' if cyl['t_mandrel_assumed'] else 'makaleden'))
    L.append('** Dogrulama verisi: ' + cd.GAUGES[case]['data'])
    L.append('** Hoop gerinim = U1/r (gauge dugumu) ; eksenel gerinim = U2(N_MASTER)/DZ')
    L.append('** Gauge dugumleri:\n' + '\n'.join(report))
    L.append('*Preprint, echo=NO, model=NO, history=NO, contact=NO')
    L.append('*Physical Constants, absolute zero=0.')
    # dugumler
    L.append('*Node\n' + '\n'.join('%d, %.10g, %.10g' % (k, v[0], v[1])
                                   for k, v in sorted(list(nM.items()) + list(nCn.items()))))
    L.append('*Element, type=CGAX4T, elset=MANDREL\n' +
             '\n'.join('%d, %d, %d, %d, %d' % ((k,) + v) for k, v in sorted(eM.items())))
    L.append('*Element, type=CGAX4T, elset=COMPOSITE\n' +
             '\n'.join('%d, %d, %d, %d, %d' % ((k,) + v) for k, v in sorted(eC.items())))
    # setler
    L += [_elset('PLY_P', plyP), _elset('PLY_M', plyM), _elset('M_LAST', M_LAST),
          _elset('C_FIRST', C_FIRST), _elset('EL_H2', EL_H2),
          _nset('M_IN', M_IN), _nset('C_OUT', C_OUT), _nset('M_BOT', M_BOT),
          _nset('C_BOT_BC', C_BOT_BC), _nset('M_TOP', M_TOP), _nset('C_TOP', C_TOP),
          _nset('N_MASTER', [master])]
    L.append('*Nset, nset=N_COMP, elset=COMPOSITE')
    L.append('*Nset, nset=N_MAND, elset=MANDREL')
    for nm, lab, _ in gauges:
        L.append(_nset(nm, [lab]))
    L.append('*Surface, type=ELEMENT, name=S_M_OUT\nM_LAST, S2')
    L.append('*Surface, type=ELEMENT, name=S_C_IN\nC_FIRST, S4')
    # oryantasyon ve kesitler
    L.append('** Global (r,z,theta) ile cakisik yerel eksen (CURE SHRINKAGE ANISO icin);\n'
             '** anizotrop veriler +-phi icin onceden dondurulmus olarak global eksende verilir.\n'
             '*Orientation, name=ORI_GLOB, system=RECTANGULAR\n1., 0., 0., 0., 1., 0.\n3, 0.')
    L.append('*Solid Section, elset=MANDREL, material=%s\n,' % kw.MAT_AL)
    L.append('*Solid Section, elset=PLY_P, material=%s, orientation=ORI_GLOB\n,' % kw.MAT_P)
    L.append('*Solid Section, elset=PLY_M, material=%s, orientation=ORI_GLOB\n,' % kw.MAT_M)
    # malzemeler
    al = cd.aluminum_SI()
    cols = {'A1': cd.material_SI('A1'), 'A2': cd.material_SI('A2')}
    L.append('*Material, name=%s\n*Conductivity\n%.6g\n*Density\n%.6g\n*Elastic\n%.6g, %.6g\n'
             '*Expansion\n%.6g\n*Specific Heat\n%.6g'
             % (kw.MAT_AL, al['K'], al['rho'], al['E'], al['nu'], al['b'], al['c']))
    for name, sgn in ((kw.MAT_P, +1), (kw.MAT_M, -1)):
        blk = kw._ply_blocks(sgn * phi, cols, case)
        if kw.KINETICS == 'TABULAR':
            rows = cd.tabular_kinetics()
            blk = blk.replace('** >>> cure976_tabular.txt icerigini buraya yapistirin <<<',
                              '\n'.join('%.6e, %.4f, %.2f' % r for r in rows))
        L.append('*Material, name=%s\n** ply acisi %+.0f deg\n%s' % (name, sgn * phi, blk))
    # etkilesim
    if inter == 'TIE':
        L.append('*Tie, name=TIE_IF, adjust=NO\nS_C_IN, S_M_OUT')
    else:
        L.append('*Surface Interaction, name=IP_IF\n*Friction\n0.\n'
                 '*Surface Behavior, pressure-overclosure=HARD\n'
                 '*Gap Conductance\n' + '\n'.join('%.6g, %.6g' % p for p in GAP_TABLE))
        L.append('*Contact Pair, interaction=IP_IF, small sliding, type=SURFACE TO SURFACE\nS_C_IN, S_M_OUT')
    # ust yuz kisitlari
    eqs = []
    for dof in (2, 5):
        for n in M_TOP:
            if n != master:
                eqs.append('2\n%d, %d, 1., %d, %d, -1.' % (n, dof, master, dof))
        for i, n in enumerate(C_TOP):
            if inter == 'TIE' and i == 0:
                continue          # tie secondary: zaten mandrel dugumune bagli
            if axial == 'EQUAL':
                eqs.append('2\n%d, %d, 1., %d, %d, -1.' % (n, dof, master, dof))
            elif n != masterC:
                eqs.append('2\n%d, %d, 1., %d, %d, -1.' % (n, dof, masterC, dof))
    L.append('** Ust yuz: DOF2 esit eksenel uzama, DOF5 esit burulma (master serbest)\n*Equation\n'
             + '\n'.join(eqs))
    # genlikler, baslangic, sinir kosullari
    L.append('** Tm: mandrel ic yuzeyi, Tc: kompozit dis yuzeyi [s, K]')
    L.append(_amp('AMP_TM', tm))
    L.append(_amp('AMP_TC', tc))
    L.append('*Initial Conditions, type=TEMPERATURE\nN_COMP, %.4f\nN_MAND, %.4f' % (T0, T0))
    L.append('*Boundary\nM_BOT, 2, 2\nC_BOT_BC, 2, 2\nM_BOT, 5, 5\nC_BOT_BC, 5, 5')
    # adim
    L.append('*Step, name=CURE, nlgeom=NO, inc=1000000\nFirin kurlemesi (%s)\n'
             '*Coupled Temperature-displacement, deltmx=%g\n%g, %.6g, %g, %g'
             % (case, DELTMX, DT_INIT, tend, DT_MIN, DT_MAX))
    L.append('*Boundary, amplitude=AMP_TM\nM_IN, 11, 11, 1.')
    L.append('*Boundary, amplitude=AMP_TC\nC_OUT, 11, 11, 1.')
    out = ['*Output, field, number interval=%d' % N_FIELD_INTERVALS,
           '*Node Output\nU, NT, RF',
           '*Element Output, elset=MANDREL\nS, E, THE, EE, HFL',
           '*Element Output, elset=COMPOSITE\nS, E, THE, EE, HFL, DOC, DOCR, CURESE']
    if inter != 'TIE':
        out.append('*Contact Output\nCSTRESS, CDISP')
    out.append('*Output, history, frequency=1')
    out.append('*Node Output, nset=N_MASTER\nU2, RF2')
    for nm, _, _ in gauges:
        out.append('*Node Output, nset=%s\nU1, U2, NT11' % nm)
    out.append('*Element Output, elset=EL_H2\nE22, E33, TEMP, DOC, DOCR, CURESE')
    L += out
    L.append('*End Step')

    txt = '\n'.join(L) + '\n'
    return txt, dict(nodes=len(nM) + len(nCn), elems=len(eM) + len(eC), tend=tend, T0=T0,
                     eqs=len(eqs))


if __name__ == '__main__':
    if not os.path.isdir(OUTDIR):
        os.makedirs(OUTDIR)
    for args in MODELS:
        txt, info = build_inp(*args)
        p = os.path.join(OUTDIR, args[0] + '.inp')
        with open(p, 'w') as f:
            f.write(txt)
        print('%-14s -> %s  (%d dugum, %d eleman, %d denklem, t_son=%.0f s, T0=%.2f K)'
              % (args[0], os.path.relpath(p), info['nodes'], info['elems'], info['eqs'],
                 info['tend'], info['T0']))
