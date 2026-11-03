# -*- coding: utf-8 -*-
"""
Calius, Lee & Springer (1990), "Filament Winding Cylinders: II. Validation of
the Process Model", J. Composite Materials 24:1299-1343.

Bu modul makaledeki TUM sayisal veriyi tek yerde toplar (saf Python, numpy yok;
hem normal python3 hem de Abaqus 2025 CAE python'u ile import edilebilir).

Birim sistemi (Abaqus'a giden her sey):  m, kg, s, N, Pa, J, K
  - Sicakliklar KELVIN (cure kinetigi Arrhenius oldugu icin, HETVAL dogrudan K kullanir)
  - Makaledeki ingiliz birimleri asagida acikca donusturulur.

Kaynak tablolar / sekiller:
  Table 1  : F-6 benzeri "kiyaslama" silindiri (Lee-Springer vs Calius-Springer)
  Table 2  : malzeme ozellikleri (T300/976 iki kolon: alpha<=0.2 ve alpha>=0.6; Al 6061-T6)
  Table 3  : 976 recinesi kur kinetigi
  Table 4  : test silindiri geometrileri
  Table 5  : sarim / firin parametreleri
  Fig. 2   : kiyaslama icin ideal sicaklik profili (Table 1 rampalarindan TAM olarak kurulur)
  Fig. 9   : termokupl (T) ve strain gauge (S) yerleri
  Fig.13-14: olculen ic (mandrel ic yuzeyi, Tm) ve dis (kompozit dis yuzeyi, Tc) sicakliklari
"""
from __future__ import print_function
import math

# ---------------------------------------------------------------------------
# Birim donusumleri
# ---------------------------------------------------------------------------
IN = 0.0254                      # in -> m
MSI = 6.894757e9                 # Msi -> Pa
LBIN3 = 27679.9047               # lb/in^3 -> kg/m^3
BTU_LBF = 4186.8                 # Btu/(lb F) -> J/(kg K)
BTU_HFTF = 1.730735              # Btu/(hr ft F) -> W/(m K)
PER_F = 1.8                      # 1/F -> 1/K
HR = 3600.0


def f2k(tf):
    """Fahrenheit -> Kelvin"""
    return (tf - 32.0) * 5.0 / 9.0 + 273.15


def k2f(tk):
    return (tk - 273.15) * 9.0 / 5.0 + 32.0


# ---------------------------------------------------------------------------
# Table 4 + Table 5 : silindirler  (makale birimleri: in, deg, lb, F, F/min, hr)
# ---------------------------------------------------------------------------
# t_mandrel_in : F-6 icin 1/4 in (Fig. 1, Fig. 29). F-1 ve F-4 icin makalede
#                VERILMEMIS -> 0.25 in VARSAYIM (alüminyum mandrel). Kendi
#                bilginiz varsa burada degistirin.
# n_plies      : sekillerdeki "Layup = .. plies" degerleri (Fig. 18, 21, 29)
# phi_deg      : sarim acisi, silindir EKSENINDEN olculur (+phi/-phi ardisik)
CYLINDERS = {
    'F1': dict(material='T300/976', D_in=3.0, h_in=0.27, L_in=14.0, Lt_in=18.0,
               phi_deg=55.0, n_plies=28, Db_in=1.25, Lb_in=0.5,
               t_mandrel_in=0.25, t_mandrel_assumed=True, mandrel='AL6061',
               bandwidth_in=0.135, tows_per_band=1, tension_lb=8.5,
               cure_F=350.0, ramp_Fmin=3.8, cool_Fmin=-0.5, oven_hr=14.0,
               dome='hemispherical (Fig.11 alt)'),
    'F4': dict(material='T300/976', D_in=3.0, h_in=1.125, L_in=16.5, Lt_in=26.5,
               phi_deg=32.0, n_plies=82, Db_in=1.25, Lb_in=5.0,
               t_mandrel_in=0.25, t_mandrel_assumed=True, mandrel='AL6061',
               bandwidth_in=0.125, tows_per_band=1, tension_lb=8.0,
               cure_F=350.0, ramp_Fmin=1.2, cool_Fmin=-0.8, oven_hr=13.0,
               dome='ozel (Fig.11 ust: 1 in konik + 4 in kubbe, delik r=1.25 in)'),
    'F6': dict(material='T300/976', D_in=6.0, h_in=5.0 / 32.0, L_in=18.0, Lt_in=25.0,
               phi_deg=40.0, n_plies=18, Db_in=2.0, Lb_in=0.5,
               t_mandrel_in=0.25, t_mandrel_assumed=False, mandrel='AL6061',
               bandwidth_in=0.135, tows_per_band=1, tension_lb=10.0,
               cure_F=350.0, ramp_Fmin=1.5, cool_Fmin=-1.0, oven_hr=10.0,
               dome='hemispherical (Fig.11 alt)'),
}

# Table 1: Lee-Springer / Calius-Springer kiyaslama silindiri = F-6 geometrisi,
# ama Fig.2'deki IDEAL profil, sabit (kurlenmis) ozellikler, buzulme YOK, mandrel
# ile TAM YAPISIK (ayni eksenel uzama). Kullanicinin "ilk adim" dogrulamasi.
BENCH = dict(material='T300/976', D_in=6.0, h_in=0.156, L_in=25.0, Lt_in=25.0,
             phi_deg=40.0, n_plies=18, t_mandrel_in=0.25, t_mandrel_assumed=False,
             mandrel='AL6061', bandwidth_in=0.125, tows_per_band=1, tension_lb=6.0,
             omega_rads=3.14, cure_F=350.0, ramp_Fmin=4.7, cool_Fmin=-1.57,
             oven_hr=6.0, T0_F=75.0)

# ---------------------------------------------------------------------------
# Table 2 : malzeme ozellikleri (makale birimleri)
#   'A1' : alpha <= alpha1 = 0.2 kolonu (kurlenmemis)
#   'A2' : alpha >= alpha2 = 0.6 kolonu (kurlenmis)
#   1 = lif yonu, 2 = duzlem ici enine, 3 = radyal (enine)
# ---------------------------------------------------------------------------
ALPHA1, ALPHA2 = 0.2, 0.6

T300_976 = {
    'A1': dict(rho=0.057, c=0.24, K11=1.49, K22=0.42, K33=0.42,
               E11=0.015, E22=0.015, E33=0.015, G12=0.006, G13=0.006, G23=0.006,
               nu12=0.25, nu13=0.25, nu23=0.25,
               b11=0.56e-6, b22=17.8e-6, b33=17.8e-6,
               eta11=0.0, eta22=1.25e-2, eta33=1.25e-2),
    'A2': dict(rho=0.057, c=0.24, K11=1.49, K22=0.42, K33=0.42,
               E11=22.5, E22=1.6, E33=1.6, G12=1.09, G13=1.09, G23=1.09,
               nu12=0.25, nu13=0.25, nu23=0.25,
               b11=0.56e-6, b22=17.8e-6, b33=17.8e-6,
               eta11=0.0, eta22=1.25e-2, eta33=1.25e-2),
}
# NOT: G23 = 1.09 Msi ve nu23 = 0.25 Table 2'de boyle verilmis (transversely
# isotropic iliskisi G23 = E22/(2(1+nu23)) = 0.64 Msi ile UYUMSUZ). Makaleyi
# birebir tekrar etmek icin tablo degeri kullanildi.

# Al 6061-T6, "etkin" CTE mandrel uzerinde olculmus (Table 2)
AL6061 = dict(rho=0.100, c=0.31, K=96.8, E=10.0, nu=0.33, b=15.8e-6)

# Table 3 : Fiberite 976 kur kinetigi
#   da/dt = (HT/Hu)*(K1 + K2*psi^a)*(B - psi)^b*(1 - psi^d)^c
#   psi   = (Hu/HT)*alpha        K_i = A_i exp(-dE_i/(R T))
#   HT/Hu = 0.0044 T - 1.1  (T < 480 K) ; 1.0 (T >= 480 K)
#   mu    = mu_inf exp(U/(R T) + kappa*alpha)   (Abaqus'ta gerekmez)
KIN_976 = dict(A1=4400.0, A2=7500.0, dE1=6.25e4, dE2=5.68e4, B=1.0,
               a=1.03, b=1.22, c=0.0, d=0.0, Hu=530.0e3,   # Hu J/kg recine
               HT_slope=0.0044, HT_icpt=-1.1, HT_Tlim=480.0,
               mu_inf=1.06e-6, U=3.76e4, kappa=18.8)
R_GAS = 8.314
# Kompozitte recine KUTLE orani (makalede yok). vf=0.65 (Appendix) ve
# rho_c=1578 kg/m3 ile ~0.28-0.31 cikar. Eksoterm (F-4 overshoot) buna duyarli.
RESIN_MASS_FRACTION = 0.30


def ht_ratio(T, use_HT=True):
    """HT/Hu (Table 3). use_HT=False -> 1 (Fig.3'teki alpha->1 egrisi)."""
    k = KIN_976
    if not use_HT or T >= k['HT_Tlim']:
        return 1.0
    return min(max(k['HT_slope'] * T + k['HT_icpt'], 1e-3), 1.0)


def ls_rate(T, alpha, use_HT=True):
    """Lee-Springer kur hizi d(alpha)/dt [1/s], T [K]."""
    k = KIN_976
    r = ht_ratio(T, use_HT)
    psi = alpha / r
    if psi >= k['B']:
        return 0.0
    K1 = k['A1'] * math.exp(-k['dE1'] / (R_GAS * T))
    K2 = k['A2'] * math.exp(-k['dE2'] / (R_GAS * T))
    rate = r * (K1 + K2 * psi ** k['a']) * (k['B'] - psi) ** k['b']
    if k['c'] != 0.0:
        rate *= (1.0 - psi ** k['d']) ** k['c']
    return rate


def kamal_terms():
    """Abaqus *CURE KINETICS, DEFINITION=KAMAL terimleri (HT/Hu = 1, B = 1, c = 0):
         a_dot = sum Z_i exp(-(E_i/R)/T) (b_i + a^m_i) (a_max - a)^n_i
       Lee-Springer ile BIREBIR:  1. terim Z=A1, m=0 ; 2. terim Z=A2, m=a ; n=b
       Satir: Z [1/s], E/R [K], m, n, b"""
    k = KIN_976
    return [(k['A1'], k['dE1'] / R_GAS, 0.0, k['b'], 0.0),
            (k['A2'], k['dE2'] / R_GAS, k['a'], k['b'], 0.0)]


def tabular_kinetics(T_list=None, a_step=0.01, use_HT=True):
    """*CURE KINETICS, DEFINITION=TABULAR satirlari: (a_dot, alpha, T).
       Table 3'teki HT/Hu(T) dahil Lee-Springer'i BIREBIR verir.
       Siralama: her sicaklik blogu icinde alpha artar."""
    if T_list is None:
        T_list = [285.0 + 5.0 * i for i in range(45)]      # 285..505 K
    n = int(round(1.0 / a_step))
    rows = []
    for T in T_list:
        for i in range(n + 1):
            a = i * a_step
            rows.append((ls_rate(T, a, use_HT), a, T))
    return rows


def material_SI(col='A2'):
    """T300/976 ozelliklerini SI'ya cevirir. col: 'A1' veya 'A2'."""
    p = T300_976[col]
    return dict(rho=p['rho'] * LBIN3, c=p['c'] * BTU_LBF,
                K11=p['K11'] * BTU_HFTF, K22=p['K22'] * BTU_HFTF, K33=p['K33'] * BTU_HFTF,
                E11=p['E11'] * MSI, E22=p['E22'] * MSI, E33=p['E33'] * MSI,
                G12=p['G12'] * MSI, G13=p['G13'] * MSI, G23=p['G23'] * MSI,
                nu12=p['nu12'], nu13=p['nu13'], nu23=p['nu23'],
                b11=p['b11'] * PER_F, b22=p['b22'] * PER_F, b33=p['b33'] * PER_F,
                eta11=p['eta11'], eta22=p['eta22'], eta33=p['eta33'])


def aluminum_SI():
    a = AL6061
    return dict(rho=a['rho'] * LBIN3, c=a['c'] * BTU_LBF, K=a['K'] * BTU_HFTF,
                E=a['E'] * MSI, nu=a['nu'], b=a['b'] * PER_F)


# ---------------------------------------------------------------------------
# Geometri (SI)
# ---------------------------------------------------------------------------
def geometry_SI(cyl):
    """cyl: CYLINDERS[...] veya BENCH sozlugu -> SI yaricaplar ve ply kalinligi."""
    r_c_in = 0.5 * cyl['D_in'] * IN          # mandrel dis = kompozit ic yaricap
    t_m = cyl['t_mandrel_in'] * IN
    h = cyl['h_in'] * IN
    return dict(r_m_in=r_c_in - t_m,        # mandrel ic yaricap
                r_if=r_c_in,                # arayuz
                r_out=r_c_in + h,           # kompozit dis yaricap
                t_m=t_m, h=h, n_plies=cyl['n_plies'],
                t_ply=h / cyl['n_plies'], phi=cyl['phi_deg'],
                L=cyl['L_in'] * IN, Lt=cyl['Lt_in'] * IN)


# ---------------------------------------------------------------------------
# Gauge / termokupl yerleri (Fig. 9) ve ilgili veri sekilleri
#   'mandrel_in' : mandrel ic yuzeyi        'if' : arayuz (mandrel dis yuzeyi)
#   'h4','h2','h34' : kompozit icinde h/4, h/2, 3h/4      'out' : dis yuzey
# ---------------------------------------------------------------------------
GAUGES = {
    'F1': dict(T=['out', 'h2', 'mandrel_in'], S=['out', 'h2', 'if'],
               data='Sic.: Fig.18 (h/2).  Gerinim verisi makalede YOK (sadece sicaklik dogrulanir).'),
    'F4': dict(T=['out', 'h34', 'h2', 'h4', 'if', 'mandrel_in'],
               S=['out', 'h34', 'h2', 'h4', 'if'],
               data='Sic.: Fig.21 a=if,b=h/4,c=h/2,d=3h/4. Hoop: Fig.25, Eksenel: Fig.26 (a=if ... e=out). Kubbe: Fig.32'),
    'F6': dict(T=['out', 'h2', 'mandrel_in'], S=['h2', 'mandrel_in'],
               data='Mandrel ic yuzey gerinimi: Fig.29, h/2: Fig.30, eksenel kayma: Fig.31, halka: Fig.37'),
    'BENCH': dict(T=['h2'], S=['h2'],
                  data='Fig.3 (T, alpha, viskozite), Fig.5 (gerilme/gerinim, h/2), Fig.4 (lif gerginligi)'),
}


def gauge_radius(g, key):
    return {'mandrel_in': g['r_m_in'], 'if': g['r_if'],
            'h4': g['r_if'] + 0.25 * g['h'], 'h2': g['r_if'] + 0.5 * g['h'],
            'h34': g['r_if'] + 0.75 * g['h'], 'out': g['r_out']}[key]


# ---------------------------------------------------------------------------
# Sicaklik sinir kosullari (F, saat)
#   Tm : mandrel IC yuzeyi    Tc : kompozit DIS yuzeyi
# Fig.2 (BENCH) Table 1 rampalarindan TAM kurulur.
# F1/F4/F6 Fig.13-14'ten GOZLE okunmus YAKLASIK noktalardir (+-10 F).
# !!! Dogrulamadan once WebPlotDigitizer ile sayisallastirip degistirin. !!!
# ---------------------------------------------------------------------------
def bench_profile_F():
    b = BENCH
    T0, Tc = b['T0_F'], b['cure_F']
    t1 = (Tc - T0) / b['ramp_Fmin'] / 60.0         # h
    t3 = b['oven_hr']
    t2 = 3.0                                        # Fig.2: bekleme 3. saate kadar
    Tend = Tc + b['cool_Fmin'] * (t3 - t2) * 60.0
    pts = [(0.0, T0), (t1, Tc), (t2, Tc), (t3, Tend)]
    return pts, pts                                  # ic = dis (Fig.2)


SURFACE_T_F = {
    'F6': dict(  # Fig.13 alt: ic ve dis neredeyse ayni
        Tc=[(0, 75), (0.25, 80), (0.5, 95), (1.0, 135), (1.5, 175), (2.0, 215),
            (2.5, 255), (3.0, 300), (3.3, 330), (3.6, 340), (4.0, 340), (5.0, 337),
            (6.2, 336), (6.5, 320), (7.0, 290), (7.5, 255), (8.0, 222), (8.5, 197),
            (9.0, 177), (9.5, 162), (9.8, 145), (10.3, 100)],
        Tm=None),  # None -> Tc ile ayni
    'F1': dict(  # Fig.13 ust
        Tc=[(0, 70), (0.15, 75), (0.4, 105), (0.85, 200), (0.95, 300), (1.05, 322),
            (1.2, 320), (1.5, 330), (1.75, 336), (2.0, 337), (2.08, 370), (2.15, 435),
            (2.22, 440), (2.28, 380), (2.33, 340), (2.38, 360), (2.6, 352), (2.8, 352),
            (3.2, 342), (3.6, 320), (4.0, 295), (4.5, 270), (5.0, 252), (5.5, 237),
            (6.0, 222), (6.5, 213), (7.0, 203)],
        Tm=[(0, 70), (0.15, 75), (0.4, 100), (0.9, 200), (1.1, 300), (1.25, 318),
            (1.5, 330), (1.75, 340), (2.0, 342), (2.1, 380), (2.2, 428), (2.27, 420),
            (2.35, 370), (2.6, 360), (2.8, 355), (3.2, 348), (3.6, 330), (4.0, 302),
            (4.5, 278), (5.0, 258), (5.5, 243), (6.0, 229), (6.5, 218), (7.0, 208)]),
    'F4': dict(  # Fig.14: sol = silindir yuzeyi, sag = mandrel yuzeyi
        Tc=[(0, 95), (1, 140), (2, 190), (3, 240), (4, 305), (4.6, 365), (5.0, 350),
            (5.5, 338), (6.5, 328), (7.7, 322), (8.0, 300), (9.0, 240), (10.0, 190),
            (10.6, 165), (11.0, 130), (11.5, 100), (12.2, 82), (12.8, 76)],
        Tm=[(0, 80), (0.7, 95), (1.5, 130), (2.5, 180), (3.5, 235), (4.1, 290),
            (4.4, 360), (4.6, 412), (4.8, 410), (5.2, 380), (5.8, 350), (6.5, 335),
            (7.5, 325), (8.0, 318), (9.0, 270), (10.0, 215), (11.0, 170), (12.0, 120),
            (12.8, 92)]),
}


def surface_amplitudes_SI(case):
    """(t[s], T[K]) listeleri: (Tm_inner, Tc_outer)"""
    if case == 'BENCH':
        tm, tc = bench_profile_F()
    else:
        d = SURFACE_T_F[case]
        tc = d['Tc']
        tm = d['Tm'] if d['Tm'] is not None else d['Tc']
    conv = lambda pts: [(t * HR, f2k(T)) for (t, T) in pts]
    return conv(tm), conv(tc)


# ---------------------------------------------------------------------------
# Ply rijitligi / CTE / iletkenlik -> Abaqus GENEL eksenleri
#   CGAX (genellestirilmis eksenel simetri, burulmali) eleman global eksenleri:
#   1 = r, 2 = z, 3 = theta.   Abaqus Voigt sirasi: 11,22,33,12,13,23
#   (yani rr, zz, tt, rz, rt, zt), kayma ENGINEERING.
# Lif yonu: z ekseninden theta'ya dogru phi acisi:  e1 = (0, cos phi, sin phi)
# ---------------------------------------------------------------------------
def _mat_axes(phi_deg):
    c, s = math.cos(math.radians(phi_deg)), math.sin(math.radians(phi_deg))
    # satirlar: malzeme eksenleri (1=lif, 2=duzlem ici enine, 3=radyal) global (r,z,t) koordinatlarinda
    return [[0.0, c, s], [0.0, -s, c], [1.0, 0.0, 0.0]]


def _inv(M):
    n = len(M)
    A = [list(r) + [1.0 if i == j else 0.0 for j in range(n)] for i, r in enumerate(M)]
    for i in range(n):
        p = max(range(i, n), key=lambda k: abs(A[k][i]))
        A[i], A[p] = A[p], A[i]
        piv = A[i][i]
        A[i] = [v / piv for v in A[i]]
        for k in range(n):
            if k != i:
                f = A[k][i]
                A[k] = [a - f * b for a, b in zip(A[k], A[i])]
    return [r[n:] for r in A]


_PAIRS = [(0, 0), (1, 1), (2, 2), (0, 1), (0, 2), (1, 2)]


def ply_D_global(m, phi_deg):
    """6x6 rijitlik (Pa), Abaqus sirasi, engineering kayma."""
    E1, E2, E3 = m['E11'], m['E22'], m['E33']
    n12, n13, n23 = m['nu12'], m['nu13'], m['nu23']
    G12, G13, G23 = m['G12'], m['G13'], m['G23']
    # malzeme cercevesinde komplians, sira 11,22,33,12,13,23
    S = [[0.0] * 6 for _ in range(6)]
    S[0][0], S[1][1], S[2][2] = 1 / E1, 1 / E2, 1 / E3
    S[0][1] = S[1][0] = -n12 / E1
    S[0][2] = S[2][0] = -n13 / E1
    S[1][2] = S[2][1] = -n23 / E2
    S[3][3], S[4][4], S[5][5] = 1 / G12, 1 / G13, 1 / G23
    Cv = _inv(S)
    # 4. mertebe tensor
    C = {}
    for I, (i, j) in enumerate(_PAIRS):
        for J, (k, l) in enumerate(_PAIRS):
            v = Cv[I][J]
            for (a, b) in ((i, j), (j, i)):
                for (cc, d) in ((k, l), (l, k)):
                    C[(a, b, cc, d)] = v
    A = _mat_axes(phi_deg)
    D = [[0.0] * 6 for _ in range(6)]
    for I, (p, q) in enumerate(_PAIRS):
        for J, (r, s) in enumerate(_PAIRS):
            tot = 0.0
            for (i, j, k, l), v in C.items():
                tot += A[i][p] * A[j][q] * A[k][r] * A[l][s] * v
            D[I][J] = tot
    return D


def ply_vec_global(v1, v2, v3, phi_deg):
    """Malzeme eksenindeki diyagonal tensor (CTE, buzulme...) -> global TENSOR
    bilesenleri [11,22,33,12,13,23] (kayma = tensor bileseni, engineering DEGIL)."""
    A = _mat_axes(phi_deg)
    vm = (v1, v2, v3)
    T = [[sum(A[i][a] * A[i][b] * vm[i] for i in range(3)) for b in range(3)] for a in range(3)]
    out = [T[p][q] for (p, q) in _PAIRS]
    big = max(abs(v) for v in out) or 1.0
    return [0.0 if abs(v) < 1e-9 * big else v for v in out]


def ply_conductivity_global(m, phi_deg):
    """ORTHO iletkenlik global (r, z, theta). z-theta capraz terimi eksenel
    simetride (d/dtheta = 0) etkisizdir, ihmal edilir."""
    c, s = math.cos(math.radians(phi_deg)), math.sin(math.radians(phi_deg))
    return (m['K33'], m['K11'] * c * c + m['K22'] * s * s, m['K11'] * s * s + m['K22'] * c * c)


def abaqus_aniso_list(D):
    """*ELASTIC, TYPE=ANISOTROPIC veri sirasi (21 sabit)."""
    out = []
    for I in range(6):
        for J in range(I + 1):
            out.append(D[J][I])
    big = max(abs(v) for v in out)
    return [0.0 if abs(v) < 1e-9 * big else v for v in out]   # yuvarlama gurultusu


if __name__ == '__main__':
    for name, c in list(CYLINDERS.items()) + [('BENCH', BENCH)]:
        g = geometry_SI(c)
        print('%-5s r_m,in=%.5f r_if=%.5f r_out=%.5f m | h=%.5f m | %d ply x %.3e m | +-%.0f deg'
              % (name, g['r_m_in'], g['r_if'], g['r_out'], g['h'], g['n_plies'], g['t_ply'], g['phi']))
