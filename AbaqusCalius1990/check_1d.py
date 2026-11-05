# -*- coding: utf-8 -*-
"""
Abaqus'a girmeden ONCE hedef degerleri ve girdileri kontrol etmek icin
bagimsiz 1D model (normal python3 + numpy; Abaqus GEREKMEZ).

 1) Kur kinetigi: BENCH sicaklik profili (Fig.2) altinda alpha(t) ve psi(t)
    -> Fig.3 ile karsilastirin.
 2) Termoelastik gerinimler: genellestirilmis duzlem gerinim + burulma,
    ply-ply +-phi, mandrel+kompozit TAM YAPISIK, sabit kurlenmis ozellikler,
    buzulme yok  ->  Fig.5 (h/2'de hoop ve eksenel) ile karsilastirin.
    Abaqus CGAX dilim modeli BIREBIR bu problemi cozer; Abaqus sonucu bu
    script ile ayni cikmalidir (malzeme sirasi/CTE kayma konvansiyonu testi).

Kullanim:  python3 check_1d.py
"""
import math
import numpy as np
import calius_data as cd


# ---------------------------------------------------------------- kinetik
def dadt(T, alpha, use_HT=True):
    """Lee-Springer hizi (calius_data.ls_rate). Abaqus KAMAL (HT/Hu=1) ve
    TABULAR (HT/Hu tablosu) tanimlari bununla birebir aynidir."""
    return cd.ls_rate(T, alpha, use_HT), min(alpha / cd.ht_ratio(T, use_HT), 1.0)


def interp(pts, t):
    for (t0, y0), (t1, y1) in zip(pts[:-1], pts[1:]):
        if t0 <= t <= t1:
            return y0 + (y1 - y0) * (t - t0) / (t1 - t0)
    return pts[-1][1]


def cure_history(case='BENCH', use_HT=True, dt=5.0):
    tm, tc = cd.surface_amplitudes_SI(case)
    tend = tc[-1][0]
    t, a, out = 0.0, 0.0, []
    while t <= tend:
        T = interp(tc, t)
        r, psi = dadt(T, a, use_HT)
        out.append((t, T, a, min(psi, 1.0)))
        a += r * dt
        t += dt
    return out


# ---------------------------------------------------------------- 1D FE
def solve_1d(cyl, dT, col='A2', shear_cte_factor=1.0, nel_m=20, nel_ply=4):
    """Lineer elemanlar. Bilinmeyenler: u_r (dugum), eps_z, kappa (burulma/boy).
    shear_cte_factor: 1 -> tensor kayma CTE'si x2 = engineering (dogru fizik)."""
    g = cd.geometry_SI(cyl)
    al = cd.aluminum_SI()
    m = cd.material_SI(col)
    # bolgeler: (r0, r1, D, eps_th_vector)
    regs = []
    lam, mu_ = al['E'] * al['nu'] / ((1 + al['nu']) * (1 - 2 * al['nu'])), al['E'] / (2 * (1 + al['nu']))
    Dal = np.zeros((6, 6))
    Dal[:3, :3] = lam
    Dal[[0, 1, 2], [0, 1, 2]] += 2 * mu_
    Dal[3, 3] = Dal[4, 4] = Dal[5, 5] = mu_
    eal = np.array([1, 1, 1, 0, 0, 0.]) * al['b'] * dT
    rr = np.linspace(g['r_m_in'], g['r_if'], nel_m + 1)
    for i in range(nel_m):
        regs.append((rr[i], rr[i + 1], Dal, eal))
    for p in range(g['n_plies']):
        phi = g['phi'] if p % 2 == 0 else -g['phi']
        D = np.array(cd.ply_D_global(m, phi))
        tv = np.array(cd.ply_vec_global(m['b11'], m['b22'], m['b33'], phi))
        tv[3:] *= 2.0 * shear_cte_factor        # tensor -> engineering
        e = tv * dT
        r0 = g['r_if'] + p * g['t_ply']
        rs = np.linspace(r0, r0 + g['t_ply'], nel_ply + 1)
        for i in range(nel_ply):
            regs.append((rs[i], rs[i + 1], D, e))
    nn = len(regs) + 1
    ndof = nn + 2
    K = np.zeros((ndof, ndof))
    F = np.zeros(ndof)
    gp = [(-1 / math.sqrt(3), 1.0), (1 / math.sqrt(3), 1.0)]
    for e, (r0, r1, D, eth) in enumerate(regs):
        L = r1 - r0
        for xi, w in gp:
            N = np.array([(1 - xi) / 2, (1 + xi) / 2])
            dN = np.array([-1 / L, 1 / L])
            r = N @ np.array([r0, r1])
            B = np.zeros((6, ndof))
            B[0, [e, e + 1]] = dN          # eps_rr
            B[1, nn] = 1.0                  # eps_zz
            B[2, [e, e + 1]] = N / r        # eps_tt
            B[5, nn + 1] = r                # gamma_zt = kappa r
            wJ = w * L / 2 * r              # 2*pi atlandi
            K += B.T @ D @ B * wJ
            F += B.T @ D @ eth * wJ
    q = np.linalg.solve(K, F)
    nodes_r = np.concatenate([[regs[0][0]], [x[1] for x in regs]])
    u = q[:nn]

    def hoop_at(rq):
        return np.interp(rq, nodes_r, u) / rq
    return dict(g=g, eps_z=q[nn], kappa=q[nn + 1], hoop=hoop_at, r=nodes_r, u=u)


if __name__ == '__main__':
    print('=== 1) BENCH kur kinetigi (Fig.3 ile karsilastir) ===')
    for use_HT in (True, False):
        h = cure_history('BENCH', use_HT)
        print('  HT/Hu %s:' % ('Table3 (0.0044T-1.1)  -> Abaqus *CURE KINETICS, TABULAR' if use_HT else '= 1  -> Abaqus *CURE KINETICS, KAMAL'))
        for th in (0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 6.0):
            row = min(h, key=lambda x: abs(x[0] - th * 3600))
            print('    t=%4.2f h  T=%6.1f F  alpha=%.3f  psi=%.3f' % (th, cd.k2f(row[1]), row[2], row[3]))

    print('\n=== 2) BENCH termoelastik gerinim, dT = 350-75 = 275 F (Fig.5: hoop~3800, eksenel~2600 ue) ===')
    dT = (cd.BENCH['cure_F'] - cd.BENCH['T0_F']) / 1.8
    for f, lab in ((1.0, 'CTE kayma dogru (engineering = 2 x tensor)'), (0.5, 'yanlis konvansiyon testi (yarim)')):
        s = solve_1d(cd.BENCH, dT, shear_cte_factor=f)
        g = s['g']
        print('  [%s]' % lab)
        print('    kompozit h/2 : hoop = %7.0f ue   eksenel = %7.0f ue' %
              (s['hoop'](g['r_if'] + g['h'] / 2) * 1e6, s['eps_z'] * 1e6))
        print('    mandrel ic   : hoop = %7.0f ue   (Fig.29 hedef ~4000-4100 ue, deneysel profil)'
              % (s['hoop'](g['r_m_in']) * 1e6))
        print('    burulma kappa = %.3e rad/m' % s['kappa'])
    al = cd.aluminum_SI()
    print('  serbest Al genlesmesi = %.0f ue' % (al['b'] * dT * 1e6))

    print('\n=== 3) Deney silindirleri, ayni varsayimlarla 1 K basina (yaklasik egim) ===')
    for name in ('F1', 'F4', 'F6'):
        s = solve_1d(cd.CYLINDERS[name], 1.0)
        g = s['g']
        print('  %s: h/2 hoop = %.2f ue/K, eksenel = %.2f ue/K, mandrel ic hoop = %.2f ue/K' %
              (name, s['hoop'](g['r_if'] + g['h'] / 2) * 1e6, s['eps_z'] * 1e6, s['hoop'](g['r_m_in']) * 1e6))
