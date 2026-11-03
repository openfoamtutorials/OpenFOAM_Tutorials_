# -*- coding: utf-8 -*-
"""
Abaqus 2025'e ELLE eklenecek keyword bloklarini uretir (saf Python).
ALT PROGRAM YOK: kur kinetigi, ekzoterm ve buzulme Abaqus 2025'in yerlesik
"Curing Processes in Polymers" secenekleriyle tanimlanir:
    *CURE KINETICS, *CURE HEAT GENERATION, *CURE MAX CONVERSION,
    *CURE SHRINKAGE, *USER DEFINED FIELD, TYPE=SPECIFIED (FV1 = DOC)

  - build_model.py (CAE) bunu import eder ve her model icin kw_<MODEL>.txt yazar
    (o dosyada dugum numarali *EQUATION bloklari da olur).
  - Tek basina:
        python3 kw_gen.py BENCH | F1 | F4 | F6     -> bloklari ekrana basar (EQUATION haric)
        python3 kw_gen.py tabular                   -> cure976_tabular.txt (TABULAR kinetik)

Eksen/siralama: CGAX global 1=r, 2=z, 3=theta ; Voigt 11,22,33,12,13,23.
Kompozite CAE'de global eksenlerle CAKISIK bir *Orientation atanir (CURE
SHRINKAGE ANISO yerel oryantasyon istiyor); bu yuzden asagidaki tum
anizotrop veriler (r, z, theta) eksenlerinde verilmistir.
Birim: m, kg, s, N, Pa, J, K   (*Physical Constants, absolute zero = 0)
"""
from __future__ import print_function
import sys
import calius_data as cd

MAT_AL = 'AL6061_EFF'
MAT_P = 'T300_976_P'     # +phi plylari (ic yuzeyden 1., 3., 5., ...)
MAT_M = 'T300_976_M'     # -phi plylari

# 'KAMAL'  : HT/Hu = 1, Lee-Springer ile birebir (Fig.3'teki alpha -> 1 egrisi)
# 'TABULAR': Table 3'teki HT/Hu(T) dahil birebir (alpha_max ~ 0.88 @ 350 F);
#            veri cure976_tabular.txt dosyasinda (python3 kw_gen.py tabular)
KINETICS = 'KAMAL'

# Buzulme (sadece *_EXP): Appendix'te eta, d(alpha) = alpha2 - alpha1 = 0.4
# ile turetilmis -> buzulme sadece 0.2 < alpha < 0.6 araliginda isletilir.
SHRINK_WINDOW = (cd.ALPHA1, cd.ALPHA2)


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


def cure_blocks(m2, case):
    """Kur kinetigi + ekzoterm (+ maks. donusum)."""
    s = []
    if KINETICS == 'KAMAL':
        s.append('** Lee-Springer (Table 3, HT/Hu=1) -> Kamal: Z [1/s], E/R [K], m, n, b\n'
                 '*Cure Kinetics, definition=KAMAL\n' +
                 '\n'.join(_fmt(t) for t in cd.kamal_terms()))
    else:
        s.append('** Lee-Springer (Table 3, HT/Hu(T) dahil): satir = a_dot [1/s], alpha, T [K]\n'
                 '*Cure Kinetics, definition=TABULAR\n'
                 '** >>> cure976_tabular.txt icerigini buraya yapistirin <<<')
    Q = cd.RESIN_MASS_FRACTION * cd.KIN_976['Hu']
    s.append('** q = rho * Q * a_dot ;  Q = w_resin * Hu = %.2f * %.0f J/kg  (kompozit kutlesi basina)\n'
             '** (veri satiri bicimini 2025 dokumaninda *CURE HEAT GENERATION sayfasindan teyit edin)\n'
             '*Cure Heat Generation\n%s' % (cd.RESIN_MASS_FRACTION, cd.KIN_976['Hu'], _fmt([Q])))
    return '\n'.join(s)


def _ply_blocks(phi, m_cols, case):
    dep = case != 'BENCH'
    m2 = m_cols['A2']
    k = cd.ply_conductivity_global(m2, phi)
    cte = cd.ply_vec_global(m2['b11'], m2['b22'], m2['b33'], phi)
    s = []
    s.append('*Conductivity, type=ORTHO\n' + _fmt(k))
    s.append('*Density\n' + _fmt([m2['rho']]))
    if not dep:
        D = cd.abaqus_aniso_list(cd.ply_D_global(m2, phi))
        s.append('** Table 2, alpha >= 0.6 kolonu, sabit (Table 1 kiyaslama kabulu)\n'
                 '*Elastic, type=ANISOTROPIC\n' + _fmt(D))
    else:
        rows = []
        for col, a in (('A1', cd.ALPHA1), ('A2', cd.ALPHA2)):
            D = cd.abaqus_aniso_list(cd.ply_D_global(m_cols[col], phi))
            rows.append(_fmt(D + [None, a]))   # 21 sabit, sicaklik (bos), FV1 = DOC
        s.append('** satir: 21 sabit, sicaklik (bos), FV1 = DOC. DOC<=0.2 ve >=0.6 sabit, arasi lineer\n'
                 '*Elastic, type=ANISOTROPIC, dependencies=1\n' + '\n'.join(rows))
    s.append('** CTE: TENSOR bilesenleri (11,22,33,12,13,23); README 4.3 testine bakin\n'
             '*Expansion, type=ANISO\n' + _fmt(cte))
    s.append(cure_blocks(m2, case))
    if dep:
        g = cd.ply_vec_global(m2['eta11'], m2['eta22'], m2['eta33'], phi)  # tensor
        a1, a2 = SHRINK_WINDOW
        eps = 1e-3
        rows = [_fmt([0.0] * 6 + [None, a1]),
                _fmt(g + [None, a1 + eps]),
                _fmt(g + [None, a2 - eps]),
                _fmt([0.0] * 6 + [None, a2])]
        s.append('** eps_s_dot = -gamma * a_dot ; gamma = eta (Table 2, Appendix), plyda 22=33=1.25e-2, 11=0\n'
                 '** sadece %.1f < DOC < %.1f araliginda (toplam enine ~ %.0f ue)\n'
                 '** satir: g11,g22,g33,g12,g13,g23, sicaklik(bos), FV1=DOC\n'
                 '*Cure Shrinkage, type=ANISO, dependencies=1\n%s'
                 % (a1, a2, m2['eta22'] * (a2 - a1) * 1e6, '\n'.join(rows)))
        s.append('*User Defined Field, type=SPECIFIED\n1, DOC')
    s.append('*Specific Heat\n' + _fmt([m2['c']]))
    return '\n'.join(s)


def material_blocks(case):
    """case: 'BENCH' (sabit kurlenmis ozellikler, buzulme yok) veya 'F1','F4','F6'."""
    cyl = cd.BENCH if case == 'BENCH' else cd.CYLINDERS[case]
    phi = cyl['phi_deg']
    al = cd.aluminum_SI()
    cols = {'A1': cd.material_SI('A1'), 'A2': cd.material_SI('A2')}
    txt = []
    txt.append('** ===================== FIZIKSEL SABIT =====================\n'
               '** Model verisi: *Heading / *Preprint blogundan sonra ekleyin.\n'
               '*Physical Constants, absolute zero=0.')
    txt.append('** ===================== MALZEMELER =====================\n'
               '** CAE "*Material, name=..." satirlarinin HEMEN ALTINA ekleyin\n'
               '** (Model > Edit Keywords, ilgili *Material blogunu secip "Add After").')
    txt.append('** >>> *Material, name=%s altina:\n' % MAT_AL +
               '*Conductivity\n%s\n*Density\n%s\n*Elastic\n%s\n*Expansion\n%s\n*Specific Heat\n%s'
               % (_fmt([al['K']]), _fmt([al['rho']]), _fmt([al['E'], al['nu']]),
                  _fmt([al['b']]), _fmt([al['c']])))
    txt.append('** >>> *Material, name=%s (+%.0f deg) altina:\n' % (MAT_P, phi) + _ply_blocks(+phi, cols, case))
    txt.append('** >>> *Material, name=%s (-%.0f deg) altina:\n' % (MAT_M, phi) + _ply_blocks(-phi, cols, case))
    return '\n**\n'.join(txt)


def boundary_twist_block(mandrel_inst='MANDREL-1', comp_inst='COMPOSITE-1'):
    return ('** ===================== BURULMA (DOF 5) =====================\n'
            '** *End Assembly sonrasina, *Step ONCESINE (Initial adim) ekleyin.\n'
            '** Alt yuz: burulma acisi 0. (U2=0 CAE icinde BC_BOT_U2 olarak tanimli.)\n'
            '*Boundary\n%s.BOT_N, 5, 5\n%s.BOT_N_BC, 5, 5' % (mandrel_inst, comp_inst))


def output_block(comp_inst='COMPOSITE-1'):
    return ('** ===================== KUR CIKTILARI =====================\n'
            '** *Step icinde, CAE cikti isteklerinden sonra, *End Step ONCESINE ekleyin.\n'
            '*Output, field, number interval=200\n'
            '*Element Output, elset=%s.ALL\nDOC, DOCR, CURESE\n'
            '*Output, history, frequency=1\n'
            '*Element Output, elset=%s.EL_H2\nDOC, DOCR, CURESE' % (comp_inst, comp_inst))


def job_notes(case):
    s = ['** ===================== IS =====================',
         '** Alt program GEREKMEZ:  abaqus job=<JOB> cpus=1',
         '** Adim *Coupled Temperature-Displacement, transient; CREEP=NONE KULLANMAYIN',
         '** (CREEP=NONE ile kur hesabi devre disi kalir).']
    if case != 'BENCH':
        s += ['** !!! *Elastic toplam formdur: sigma = D(DOC) * eps_el. Jelasyonda D ~100 kat artinca',
              '** !!! birikmis elastik gerinim sahte gerilmeye donusebilir. Sonuclarda tutma',
              '** !!! (hold) basindaki gerinim sicramasini kontrol edin -> README "2. asama".']
    return '\n'.join(s)


def all_blocks(case):
    return '\n**\n'.join([material_blocks(case), boundary_twist_block(), output_block(),
                          job_notes(case)])


def write_tabular(path='cure976_tabular.txt', use_HT=True):
    rows = cd.tabular_kinetics(use_HT=use_HT)
    with open(path, 'w') as f:
        for r, a, T in rows:
            f.write('%.6e, %.4f, %.2f\n' % (r, a, T))
    return path, len(rows)


if __name__ == '__main__':
    arg = sys.argv[1] if len(sys.argv) > 1 else 'BENCH'
    if arg.lower() == 'tabular':
        p, n = write_tabular()
        print('%s yazildi (%d satir: a_dot, alpha, T)' % (p, n))
    else:
        print(all_blocks(arg))
