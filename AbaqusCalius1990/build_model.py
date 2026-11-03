# -*- coding: utf-8 -*-
"""
Abaqus/CAE 2025 - Calius, Lee & Springer (1990) F-1, F-4, F-6 silindirleri
==========================================================================

Calistirma (bu klasorde):
    abaqus cae noGUI=build_model.py
  veya CAE icinde: File > Run Script... > build_model.py

Ne yapar (inp YAZMAZ):
  * Her durum icin ayri model kurar:
        BENCH_F6_TIE : Table 1 / Fig.2 kiyaslama (F-6 geometrisi, tam yapisik, buzulmesiz)
        F6_EXP, F1_EXP, F4_EXP : deneysel yuzey sicakliklari (Fig.13-14) + kontakt
  * Geometri: genellestirilmis eksenel simetrik (CGAX4T, burulmali) DILIM modeli
        - mandrel (Al) + kompozit; kompozit ply ply bolunur (+phi / -phi ardisik)
        - eksenel boy DZ, uzun silindir (makaledeki 1-D model) varsayimi
  * Setler / yuzeyler / gauge dugumleri, kesitler (malzemeler BOS - keyword ile dolacak)
  * Adim: *Coupled Temperature-Displacement, transient
  * Sinir kosullari: ic yuzey T = Tm(t), dis yuzey T = Tc(t) (amplitude), alt yuz U2=0
  * Etkilesim: BENCH -> *Tie ; EXP -> hard kontakt (ayrilabilir) + gap conductance
  * Cikti istekleri (gauge dugumleri U1, NT11 ; h/2 elemanlari E22, E33, SDV)
  * Her model icin kw_<MODEL>.txt yazar: ELLE eklenecek keyword bloklari
        (malzemeler, *Depvar, *Heat Generation, burulma *Boundary, dugum
         numarali *Equation bloklari)
  * Job olusturur (user=cure976_hetval.f) ama input YAZMAZ / calistirmaz.
"""
from abaqus import *
from abaqusConstants import *
import mesh
import os
import sys

HERE = os.getcwd()
if HERE not in sys.path:
    sys.path.insert(0, HERE)
import calius_data as cd
import kw_gen as kw

# ---------------------------------------------------------------------------
# KULLANICI SECENEKLERI
# ---------------------------------------------------------------------------
# (model adi, durum, etkilesim 'TIE'|'CONTACT', eksenel 'EQUAL'|'SLIP')
#   EQUAL : mandrel ve kompozit ayni eksenel uzamayi yapar (makale varsayimi)
#   SLIP  : kompozit eksenelde serbest (Fig.31'deki kayma icin ust sinir)
MODELS = [
    ('BENCH_F6_TIE', 'BENCH', 'TIE', 'EQUAL'),
    ('F6_EXP', 'F6', 'CONTACT', 'EQUAL'),
    ('F1_EXP', 'F1', 'CONTACT', 'EQUAL'),
    ('F4_EXP', 'F4', 'CONTACT', 'EQUAL'),
]
DZ = 0.5e-3            # dilimin eksenel boyu [m]
NZ = 1                 # eksenel eleman sayisi
NEL_MANDREL = 10       # mandrel kalinligi boyunca eleman
EL_PER_PLY = 2         # ply basina radyal eleman (2 -> h/4, 3h/4 dugume denk gelir)
H_CONTACT = 1.0e6      # temas iletkenligi [W/m2K] (pratikte mukemmel temas)
H_GAP, GAP1, GAP2 = 300.0, 1.0e-4, 1.0e-3   # acilmada hava boslugu iletkenligi
DT_MAX = 60.0          # maks artim [s]
DELTMX = 5.0           # artim basina maks sicaklik degisimi [K]


def _tie(m, name, main, sec):
    try:
        m.Tie(name=name, main=main, secondary=sec, positionToleranceMethod=COMPUTED,
              adjust=OFF, tieRotations=ON, thickness=ON)
    except TypeError:   # eski surum argumanlari
        m.Tie(name=name, master=main, slave=sec, positionToleranceMethod=COMPUTED,
              adjust=OFF, tieRotations=ON, thickness=ON)


def _contact(m, name, main, sec, prop):
    kwargs = dict(name=name, createStepName='Initial', sliding=SMALL,
                  interactionProperty=prop, adjustMethod=NONE, initialClearance=OMIT,
                  datumAxis=None, clearanceRegion=None)
    try:
        m.SurfaceToSurfaceContactStd(main=main, secondary=sec, **kwargs)
    except TypeError:
        m.SurfaceToSurfaceContactStd(master=main, slave=sec, **kwargs)


def _rect_part(m, pname, ra, rb):
    s = m.ConstrainedSketch(name='sk_' + pname, sheetSize=1.0)
    s.sketchOptions.setValues(viewStyle=AXISYM)
    s.ConstructionLine(point1=(0.0, -1.0), point2=(0.0, 1.0))
    s.rectangle(point1=(ra, 0.0), point2=(rb, DZ))
    p = m.Part(name=pname, dimensionality=AXISYMMETRIC, type=DEFORMABLE_BODY)
    p.BaseShell(sketch=s)
    return p


def _hedges(p, ra, rb):
    rm = 0.5 * (ra + rb)
    return p.edges.findAt(((rm, 0.0, 0.0),), ((rm, DZ, 0.0),))


def _vedges(p, rlist):
    return p.edges.findAt(*[((r, 0.5 * DZ, 0.0),) for r in rlist])


def _node_labels(p, r=None, y=None, tol_r=1e-9, tol_y=1e-9, exclude_r=None):
    out = []
    for n in p.nodes:
        x, yy = n.coordinates[0], n.coordinates[1]
        if r is not None and abs(x - r) > tol_r:
            continue
        if y is not None and abs(yy - y) > tol_y:
            continue
        if exclude_r is not None and abs(x - exclude_r) <= tol_r:
            continue
        out.append(n.label)
    return out


def _nearest_bottom_node(p, r):
    best = min(p.nodes, key=lambda n: abs(n.coordinates[0] - r) + abs(n.coordinates[1]))
    return best.label, best.coordinates[0]


def build(mname, case, inter, axial):
    cyl = cd.BENCH if case == 'BENCH' else cd.CYLINDERS[case]
    g = cd.geometry_SI(cyl)
    r0, r1, r2 = g['r_m_in'], g['r_if'], g['r_out']
    N, tp = g['n_plies'], g['t_ply']
    hel = tp / EL_PER_PLY
    tol_r, tol_y = 0.01 * min(hel, g['t_m'] / NEL_MANDREL), 0.01 * DZ / NZ

    if mname in mdb.models.keys():
        del mdb.models[mname]
    m = mdb.Model(name=mname, modelType=STANDARD_EXPLICIT)

    # ---------------- malzeme isimleri (ozellikler keyword ile) ----------------
    for nm in (kw.MAT_AL, kw.MAT_P, kw.MAT_M):
        m.Material(name=nm, description='Ozellikler kw_%s.txt ile eklenecek' % mname)
    m.HomogeneousSolidSection(name='SEC_AL', material=kw.MAT_AL, thickness=None)
    m.HomogeneousSolidSection(name='SEC_PLY_P', material=kw.MAT_P, thickness=None)
    m.HomogeneousSolidSection(name='SEC_PLY_M', material=kw.MAT_M, thickness=None)

    # ---------------- parcalar ----------------
    pM = _rect_part(m, 'MANDREL', r0, r1)
    pC = _rect_part(m, 'COMPOSITE', r1, r2)

    # kompoziti plylara bol
    if N > 1:
        s = m.ConstrainedSketch(name='__ply__', sheetSize=1.0)
        for k in range(1, N):
            rk = r1 + k * tp
            s.Line(point1=(rk, 0.0), point2=(rk, DZ))
        pC.PartitionFaceBySketch(faces=pC.faces, sketch=s)
        del m.sketches['__ply__']

    rP = [r1 + (k + 0.5) * tp for k in range(0, N, 2)]   # +phi (ic yuzeyden baslar)
    rMn = [r1 + (k + 0.5) * tp for k in range(1, N, 2)]  # -phi
    for k in range(N):
        pC.Set(name='PLY_%03d' % (k + 1), faces=pC.faces.findAt(((r1 + (k + 0.5) * tp, 0.5 * DZ, 0.0),)))
    setP = pC.Set(name='PLIES_P', faces=pC.faces.findAt(*[((r, 0.5 * DZ, 0.0),) for r in rP]))
    pC.SectionAssignment(region=setP, sectionName='SEC_PLY_P', offset=0.0,
                         offsetType=MIDDLE_SURFACE, offsetField='', thicknessAssignment=FROM_SECTION)
    if rMn:
        setMm = pC.Set(name='PLIES_M', faces=pC.faces.findAt(*[((r, 0.5 * DZ, 0.0),) for r in rMn]))
        pC.SectionAssignment(region=setMm, sectionName='SEC_PLY_M', offset=0.0,
                             offsetType=MIDDLE_SURFACE, offsetField='', thicknessAssignment=FROM_SECTION)
    setAl = pM.Set(name='ALL', faces=pM.faces)
    pM.SectionAssignment(region=setAl, sectionName='SEC_AL', offset=0.0,
                         offsetType=MIDDLE_SURFACE, offsetField='', thicknessAssignment=FROM_SECTION)
    pC.Set(name='ALL', faces=pC.faces)

    # geometrik kenar setleri / yuzeyler
    pM.Set(name='E_IN', edges=_vedges(pM, [r0]))
    pM.Surface(name='S_IN', side1Edges=_vedges(pM, [r0]))
    pM.Surface(name='S_OUT', side1Edges=_vedges(pM, [r1]))
    pC.Surface(name='S_IN', side1Edges=_vedges(pC, [r1]))
    pC.Surface(name='S_OUT', side1Edges=_vedges(pC, [r2]))
    pC.Set(name='E_OUT', edges=_vedges(pC, [r2]))

    # ---------------- mesh ----------------
    pM.seedEdgeByNumber(edges=_hedges(pM, r0, r1), number=NEL_MANDREL, constraint=FIXED)
    pM.seedEdgeByNumber(edges=_vedges(pM, [r0, r1]), number=NZ, constraint=FIXED)
    for k in range(N):
        pC.seedEdgeByNumber(edges=_hedges(pC, r1 + k * tp, r1 + (k + 1) * tp),
                            number=EL_PER_PLY, constraint=FIXED)
    pC.seedEdgeByNumber(edges=_vedges(pC, [r1 + k * tp for k in range(N + 1)]),
                        number=NZ, constraint=FIXED)
    et4 = mesh.ElemType(elemCode=CGAX4T, elemLibrary=STANDARD)
    et3 = mesh.ElemType(elemCode=CGAX3T, elemLibrary=STANDARD)
    for p in (pM, pC):
        p.setMeshControls(regions=p.faces, elemShape=QUAD, technique=STRUCTURED)
        p.setElementType(regions=(p.faces,), elemTypes=(et4, et3))
        p.generateMesh()

    # ---------------- dugum setleri ----------------
    pM.SetFromNodeLabels(name='BOT_N', nodeLabels=tuple(_node_labels(pM, y=0.0, tol_y=tol_y)))
    pM.SetFromNodeLabels(name='TOP_N', nodeLabels=tuple(_node_labels(pM, y=DZ, tol_y=tol_y)))
    pC.SetFromNodeLabels(name='BOT_N', nodeLabels=tuple(_node_labels(pC, y=0.0, tol_y=tol_y)))
    pC.SetFromNodeLabels(name='TOP_N', nodeLabels=tuple(_node_labels(pC, y=DZ, tol_y=tol_y)))
    # TIE'da kompozit arayuz dugumleri tie ile bagli -> BC/Equation'dan cikar (asiri kisit olmasin)
    excl = r1 if inter == 'TIE' else None
    pC.SetFromNodeLabels(name='BOT_N_BC', nodeLabels=tuple(
        _node_labels(pC, y=0.0, tol_y=tol_y, tol_r=tol_r, exclude_r=excl)))

    # gauge dugumleri (alt yuz, y=0). Hoop gerinim = U1 / r ; eksenel = U2(ust master) / DZ
    gauge_sets = []
    gkeys = sorted(set(cd.GAUGES[case]['T'] + cd.GAUGES[case]['S']))
    if case == 'BENCH':
        gkeys = ['mandrel_in', 'if', 'h4', 'h2', 'h34', 'out']
    report = []
    for key in gkeys:
        rg = cd.gauge_radius(g, key)
        if key == 'mandrel_in':
            parts = [('MANDREL-1', pM)]
        elif key == 'if':
            parts = [('MANDREL-1', pM), ('COMPOSITE-1', pC)]
        else:
            parts = [('COMPOSITE-1', pC)]
        for iname, p in parts:
            lab, rr = _nearest_bottom_node(p, rg)
            sname = 'G_' + key.upper()
            p.SetFromNodeLabels(name=sname, nodeLabels=(lab,))
            gauge_sets.append((iname, sname))
            report.append('%-12s %-7s r_hedef=%.6f r_dugum=%.6f m  dugum=%d'
                          % (iname, key, rg, rr, lab))

    # h/2 civarindaki elemanlar (SDV, E22=eksenel, E33=hoop)
    rh2 = cd.gauge_radius(g, 'h2')
    labs = []
    for e in pC.elements:
        ns = e.getNodes()
        rc = sum(n.coordinates[0] for n in ns) / len(ns)
        if abs(rc - rh2) < 0.75 * hel:
            labs.append(e.label)
    pC.SetFromElementLabels(name='EL_H2', elementLabels=tuple(labs))

    # ---------------- montaj ----------------
    a = m.rootAssembly
    a.DatumCsysByDefault(CARTESIAN)
    iM = a.Instance(name='MANDREL-1', part=pM, dependent=ON)
    iC = a.Instance(name='COMPOSITE-1', part=pC, dependent=ON)
    a.Set(name='ALL', faces=iM.faces[:] + iC.faces[:])
    a.Set(name='BOT_U2', nodes=iM.sets['BOT_N'].nodes + iC.sets['BOT_N_BC'].nodes)

    # ---------------- adim, genlikler ----------------
    tm, tc = cd.surface_amplitudes_SI(case)
    tend = max(tm[-1][0], tc[-1][0])
    m.CoupledTempDisplacementStep(name='CURE', previous='Initial', response=TRANSIENT,
                                  timePeriod=tend, maxNumInc=1000000, initialInc=10.0,
                                  minInc=1.0e-4, maxInc=DT_MAX, deltmx=DELTMX, nlgeom=OFF,
                                  description='Firin kurlemesi (%s)' % case)
    m.TabularAmplitude(name='AMP_TM', timeSpan=STEP, smooth=SOLVER_DEFAULT, data=tuple(tm))
    m.TabularAmplitude(name='AMP_TC', timeSpan=STEP, smooth=SOLVER_DEFAULT, data=tuple(tc))

    # ---------------- baslangic ve sinir kosullari ----------------
    T0 = 0.5 * (tm[0][1] + tc[0][1])
    m.Temperature(name='T_INIT', createStepName='Initial', region=a.sets['ALL'],
                  distributionType=UNIFORM, crossSectionDistribution=CONSTANT_THROUGH_THICKNESS,
                  magnitudes=(T0,))
    m.TemperatureBC(name='BC_TM_MANDREL_IC', createStepName='CURE', region=iM.sets['E_IN'],
                    fixed=OFF, distributionType=UNIFORM, fieldName='', magnitude=1.0,
                    amplitude='AMP_TM')
    m.TemperatureBC(name='BC_TC_KOMPOZIT_DIS', createStepName='CURE', region=iC.sets['E_OUT'],
                    fixed=OFF, distributionType=UNIFORM, fieldName='', magnitude=1.0,
                    amplitude='AMP_TC')
    m.DisplacementBC(name='BC_BOT_U2', createStepName='Initial', region=a.sets['BOT_U2'],
                     u2=SET)
    # Burulma (DOF 5) ve ust yuz esit eksenel uzama/burulma -> keyword (kw_<MODEL>.txt)

    # ---------------- etkilesim ----------------
    mainR, secR = iM.surfaces['S_OUT'], iC.surfaces['S_IN']
    if inter == 'TIE':
        _tie(m, 'TIE_MANDREL_KOMPOZIT', mainR, secR)
    else:
        ip = m.ContactProperty('IP_MANDREL_KOMPOZIT')
        ip.NormalBehavior(pressureOverclosure=HARD, allowSeparation=ON,
                          constraintEnforcementMethod=DEFAULT)
        # Eksenel esitlik EQUAL modunda *Equation ile saglanir -> surtunmesiz (asiri kisit yok)
        ip.TangentialBehavior(formulation=FRICTIONLESS)
        ip.ThermalConductance(definition=TABULAR, clearanceDependency=ON, pressureDependency=OFF,
                              temperatureDependencyC=OFF, massFlowRateDependencyC=OFF,
                              dependenciesC=0,
                              clearanceDepTable=((H_CONTACT, 0.0), (H_GAP, GAP1), (0.0, GAP2)))
        _contact(m, 'CP_MANDREL_KOMPOZIT', mainR, secR, 'IP_MANDREL_KOMPOZIT')

    # ---------------- cikti ----------------
    fo = m.fieldOutputRequests['F-Output-1']
    fvars = ['S', 'E', 'THE', 'EE', 'U', 'NT', 'HFL', 'SDV']
    if inter != 'TIE':
        fvars += ['CSTRESS', 'CDISP']
    fo.setValues(variables=tuple(fvars), numIntervals=200)
    for iname, sname in gauge_sets:
        m.HistoryOutputRequest(name='H_%s_%s' % (iname.split('-')[0][:4], sname),
                               createStepName='CURE', variables=('U1', 'U2', 'NT11'),
                               region=a.instances[iname].sets[sname], frequency=1)
    m.HistoryOutputRequest(name='H_EL_H2', createStepName='CURE',
                           variables=('E22', 'E33', 'TEMP', 'SDV1', 'SDV2', 'SDV3'),
                           region=iC.sets['EL_H2'], frequency=1)

    # ---------------- keyword dosyasi (Equation'lar dugum numarasiyla) ----------------
    topM = [(n.label, n.coordinates[0]) for n in pM.sets['TOP_N'].nodes]
    topC = [(n.label, n.coordinates[0]) for n in pC.sets['TOP_N'].nodes]
    masterM = min(topM, key=lambda t: abs(t[1] - r1))[0]
    masterC = min(topC, key=lambda t: abs(t[1] - r2))[0]
    mlab = 'MANDREL-1.%d' % masterM
    pM.SetFromNodeLabels(name='TOP_MASTER', nodeLabels=(masterM,))
    m.HistoryOutputRequest(name='H_TOP_MASTER', createStepName='CURE', variables=('U2', 'RF2'),
                           region=iM.sets['TOP_MASTER'], frequency=1)
    eqs = []
    for dof in (2, 5):
        for lab, _ in topM:
            if lab != masterM:
                eqs.append('2\nMANDREL-1.%d, %d, 1.\n%s, %d, -1.' % (lab, dof, mlab, dof))
        for lab, rr in topC:
            if inter == 'TIE' and abs(rr - r1) <= tol_r:
                continue   # tie ile zaten mandrel dugumune bagli
            if axial == 'EQUAL':
                eqs.append('2\nCOMPOSITE-1.%d, %d, 1.\n%s, %d, -1.' % (lab, dof, mlab, dof))
            elif lab != masterC:
                eqs.append('2\nCOMPOSITE-1.%d, %d, 1.\nCOMPOSITE-1.%d, %d, -1.' % (lab, dof, masterC, dof))
    eq_block = ('** ===================== UST YUZ KISITLARI =====================\n'
                '** *Assembly icinde, *End Assembly satirindan HEMEN ONCE ekleyin.\n'
                '** DOF2: esit eksenel uzama (genellestirilmis duzlem gerinim), DOF5: esit burulma.\n'
                '** Bagimsiz (master) dugum serbest -> eksenel kuvvet = 0, tork = 0.\n'
                '** Eksenel gerinim = U2(MANDREL-1.TOP_MASTER) / DZ,  DZ = %.6g m\n'
                '*Equation\n%s' % (DZ, '\n'.join(eqs)))

    head = ['** ' + '=' * 70,
            '** MODEL %s  (durum=%s, etkilesim=%s, eksenel=%s)' % (mname, case, inter, axial),
            '** r_mandrel_ic=%.6f  r_arayuz=%.6f  r_dis=%.6f m ; %d ply x %.4e m ; +-%.0f deg'
            % (r0, r1, r2, N, tp, g['phi']),
            '** Mandrel kalinligi %s' % ('VARSAYIM (makalede yok)' if cyl['t_mandrel_assumed'] else 'makaleden'),
            '** Baslangic sicakligi T0 = %.2f K (%.1f F),  adim suresi = %.0f s' % (T0, cd.k2f(T0), tend),
            '** Dogrulama verisi: ' + cd.GAUGES[case]['data'],
            '** Gauge dugumleri:'] + ['**   ' + r for r in report] + ['** ' + '=' * 70]
    with open(os.path.join(HERE, 'kw_%s.txt' % mname), 'w') as f:
        f.write('\n'.join(head) + '\n' + kw.all_blocks(case) + '\n**\n' + eq_block + '\n')

    mdb.Job(name=mname, model=mname, type=ANALYSIS, numCpus=1,
            userSubroutine=os.path.join(HERE, 'cure976_hetval.f'),
            description='Calius 1990 - %s' % case)
    print('[OK] %s kuruldu -> kw_%s.txt' % (mname, mname))


for _args in MODELS:
    build(*_args)
if 'Model-1' in mdb.models.keys() and len(mdb.models.keys()) > 1:
    del mdb.models['Model-1']
mdb.saveAs(pathName=os.path.join(HERE, 'calius1990_cylinders.cae'))
print('[OK] calius1990_cylinders.cae kaydedildi. Simdi kw_*.txt bloklarini Edit Keywords ile ekleyin.')
