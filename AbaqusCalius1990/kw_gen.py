# -*- coding: utf-8 -*-
"""
Abaqus'a ELLE eklenecek keyword bloklarini uretir (saf Python).
  - build_model.py (CAE) bunu import eder ve her model icin kw_<MODEL>.txt yazar
    (o dosyada dugum numarali *EQUATION bloklari da olur).
  - Tek basina:  python3 kw_gen.py BENCH   |  F1 | F4 | F6
    -> malzeme ve diger bloklari ekrana basar (EQUATION haric).

Eksen/siralama: CGAX global 1=r, 2=z, 3=theta ; Voigt 11,22,33,12,13,23.
Birim: m, kg, s, N, Pa, J, K
"""
from __future__ import print_function
import sys
import calius_data as cd

MAT_AL = 'AL6061_EFF'
MAT_P = 'T300_976_P'     # +phi plylari (ic yuzeyden 1., 3., 5., ...)
MAT_M = 'T300_976_M'     # -phi plylari
NDEPVAR = 3              # 1: alpha (kur derecesi), 2: psi = alpha*Hu/HT, 3: d(alpha)/dt


def _fmt(vals, per=8):
    out, line = [], []
    for v in vals:
        line.append('' if v is None else ('%.6g' % v))
        if len(line) == per:
            out.append(', '.join(line))
            line = []
    if line:
        out.append(', '.join(line))
    return '\n'.join(out)


def _ply_blocks(phi, m_cols, dependent):
    """phi: +-aci. m_cols: {'A1': SI dict, 'A2': SI dict}. dependent: alpha'ya bagli mi."""
    m2 = m_cols['A2']
    k = cd.ply_conductivity_global(m2, phi)
    cte = cd.ply_vec_global(m2['b11'], m2['b22'], m2['b33'], phi)
    s = []
    s.append('*Conductivity, type=ORTHO\n' + _fmt(k))
    s.append('*Density\n' + _fmt([m2['rho']]))
    s.append('*Depvar\n %d,\n1, ALPHA, "Kur derecesi"\n2, PSI, "alpha*Hu/HT"\n3, DADT, "d(alpha)/dt"' % NDEPVAR)
    if not dependent:
        D = cd.abaqus_aniso_list(cd.ply_D_global(m2, phi))
        s.append('*Elastic, type=ANISOTROPIC\n' + _fmt(D))
    else:
        rows = []
        for col, a in (('A1', cd.ALPHA1), ('A2', cd.ALPHA2)):
            D = cd.abaqus_aniso_list(cd.ply_D_global(m_cols[col], phi))
            rows.append(_fmt(D + [None, a]))   # 21 sabit, sicaklik (bos), FV1 = alpha
        s.append('*Elastic, type=ANISOTROPIC, dependencies=1\n'
                 '** satir: 21 sabit, sicaklik(bos), FV1=alpha.  alpha<=0.2 ve >=0.6 sabit, arasi lineer\n'
                 + '\n'.join(rows))
    s.append('** CTE: TENSOR kayma bileseni (11,22,33,12,13,23). KONVANSIYON TESTI icin README 4.3\n'
             '*Expansion, type=ANISO\n' + _fmt(cte))
    if dependent:
        s.append('** Buzulme eklemek icin yukaridaki *Expansion yerine:\n'
                 '** *Expansion, type=ANISO, user        (UEXPAN: termal + eta*d(alpha))')
    s.append('*Heat Generation')
    s.append('*Specific Heat\n' + _fmt([m2['c']]))
    if dependent:
        s.append('*User Defined Field')
    return '\n'.join(s)


def material_blocks(case):
    """case: 'BENCH' (sabit kurlenmis ozellikler) veya 'F1','F4','F6'."""
    cyl = cd.BENCH if case == 'BENCH' else cd.CYLINDERS[case]
    phi = cyl['phi_deg']
    al = cd.aluminum_SI()
    cols = {'A1': cd.material_SI('A1'), 'A2': cd.material_SI('A2')}
    dep = case != 'BENCH'
    txt = []
    txt.append('** ===================== MALZEMELER =====================\n'
               '** CAE "*Material, name=..." satirlarinin HEMEN ALTINA ekleyin\n'
               '** (Model > Edit Keywords, ilgili *Material blogunu secip "Add After").')
    txt.append('** >>> *Material, name=%s altina:\n' % MAT_AL +
               '*Conductivity\n%s\n*Density\n%s\n*Elastic\n%s\n*Expansion\n%s\n*Specific Heat\n%s'
               % (_fmt([al['K']]), _fmt([al['rho']]), _fmt([al['E'], al['nu']]),
                  _fmt([al['b']]), _fmt([al['c']])))
    txt.append('** >>> *Material, name=%s (+%.0f deg) altina:\n' % (MAT_P, phi) + _ply_blocks(+phi, cols, dep))
    txt.append('** >>> *Material, name=%s (-%.0f deg) altina:\n' % (MAT_M, phi) + _ply_blocks(-phi, cols, dep))
    return '\n**\n'.join(txt)


def boundary_twist_block(mandrel_inst='MANDREL-1', comp_inst='COMPOSITE-1'):
    return ('** ===================== BURULMA (DOF 5) =====================\n'
            '** *End Assembly sonrasina, *Step ONCESINE (Initial adim) ekleyin.\n'
            '** Alt yuz: burulma acisi 0. (U2=0 CAE icinde BC_BOT olarak tanimli.)\n'
            '*Boundary\n%s.BOT_N, 5, 5\n%s.BOT_N_BC, 5, 5' % (mandrel_inst, comp_inst))


def job_notes(case):
    s = ['** ===================== IS / ALT PROGRAM =====================',
         '** Is calistirma:  abaqus job=<JOB> user=cure976_hetval.f  (cpus=1 yeterli)',
         '** HETVAL : *Heat Generation icin kur kinetigi (Table 3) -> SDV1..3',
         '** Not: HETVAL icindeki RHOC, WR, IHT parametrelerini kontrol edin.']
    if case != 'BENCH':
        s += ['** USDFLD : FV1 = SDV1 (alpha) -> *Elastic dependencies=1 icin',
              '** !!! *Elastic toplam formdur: sigma = D(alpha) * eps_el. Jelasyonda D ~100 kat artinca',
              '** !!! sahte gerilme sicramasi olur. Makale (artimsal) ile uyum icin UMAT (dsigma = D(alpha) deps_el)',
              '** !!! onerilir -> README "2. asama".']
    return '\n'.join(s)


def all_blocks(case):
    return '\n**\n'.join([material_blocks(case), boundary_twist_block(), job_notes(case)])


if __name__ == '__main__':
    case = sys.argv[1] if len(sys.argv) > 1 else 'BENCH'
    print(all_blocks(case))
