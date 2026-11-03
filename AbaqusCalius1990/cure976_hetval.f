C=======================================================================
C  Fiberite 976 kur kinetigi  (Calius-Lee-Springer 1990, Table 3)
C
C    da/dt = (HT/Hu) (K1 + K2 psi^a) (B - psi)^b ,  psi = alpha Hu/HT
C    Ki    = Ai exp(-dEi / (R T))          T [K]
C    HT/Hu = 0.0044 T - 1.1   (T < 480 K),  1 (T >= 480 K)
C    q     = rho_c * w_r * Hu * da/dt   [W/m3]
C
C  SDV1 = alpha , SDV2 = psi , SDV3 = da/dt      (*Depvar = 3)
C
C  IHT = 1 : HT/Hu tablosu kullanilir (alpha_max ~ 0.88 @ 350 F)
C  IHT = 0 : HT/Hu = 1 (Fig.3'teki alpha -> 1.0 egrisine daha yakin,
C            check_1d.py ciktisina bakin). Iki durumda da psi -> 1.
C
C  Birimler: SI, sicaklik KELVIN olmali.
C  Kullanim: abaqus job=JOB user=cure976_hetval.f
C=======================================================================
      SUBROUTINE HETVAL(CMNAME,TEMP,TIME,DTIME,STATEV,FLUX,
     1 PREDEF,DPRED)
C
      INCLUDE 'ABA_PARAM.INC'
C
      CHARACTER*80 CMNAME
      DIMENSION TEMP(2),STATEV(*),PREDEF(*),TIME(2),FLUX(2),
     1 DPRED(*)
C
      PARAMETER (A1=4400.D0, A2=7500.D0, DE1=6.25D4, DE2=5.68D4,
     1  BB=1.D0, AA=1.03D0, BEXP=1.22D0, RG=8.314D0, HU=530.D3,
     2  RHOC=1577.75D0, WR=0.30D0, IHT=1, NSUB=20)
C
      FLUX(1) = 0.D0
      FLUX(2) = 0.D0
      IF (DTIME .LE. 0.D0) RETURN
C
      TK   = TEMP(1)
      ALP0 = STATEV(1)
C
      HT = 1.D0
      IF (IHT .EQ. 1 .AND. TK .LT. 480.D0) HT = 0.0044D0*TK - 1.1D0
      HT = MIN(MAX(HT, 1.D-3), 1.D0)
C
      RK1 = A1*EXP(-DE1/(RG*TK))
      RK2 = A2*EXP(-DE2/(RG*TK))
C
C     artim icinde acik alt-adimlama (T = artim sonu sicakligi)
      ALP = ALP0
      DTS = DTIME/DBLE(NSUB)
      DO 10 K = 1, NSUB
         PSI = ALP/HT
         IF (PSI .GE. BB) GOTO 20
         RATE = HT*(RK1 + RK2*PSI**AA)*(BB - PSI)**BEXP
         ALP  = MIN(ALP + RATE*DTS, HT*BB)
   10 CONTINUE
   20 CONTINUE
C
      DADT = (ALP - ALP0)/DTIME
      Q    = RHOC*WR*HU*DADT
      FLUX(1) = Q
C     yaklasik dq/dT (yakinsama icin): q * dE2/(R T^2)
      FLUX(2) = Q*DE2/(RG*TK*TK)
C
      STATEV(1) = ALP
      STATEV(2) = MIN(ALP/HT, 1.D0)
      STATEV(3) = DADT
C
      RETURN
      END
C=======================================================================
C  USDFLD : FV1 = alpha  (sadece F1/F4/F6 modellerinde, *User Defined
C           Field + *Elastic, dependencies=1 icin; BENCH'te cagrilmaz)
C=======================================================================
      SUBROUTINE USDFLD(FIELD,STATEV,PNEWDT,DIRECT,T,CELENT,
     1 TIME,DTIME,CMNAME,ORNAME,NFIELD,NSTATV,NOEL,NPT,LAYER,
     2 KSPT,KSTEP,KINC,NDI,NSHR,COORD,JMAC,JMATYP,MATLAYO,LACCFLA)
C
      INCLUDE 'ABA_PARAM.INC'
C
      CHARACTER*80 CMNAME,ORNAME
      CHARACTER*3  FLGRAY(15)
      DIMENSION FIELD(NFIELD),STATEV(NSTATV),DIRECT(3,3),
     1 T(3,3),TIME(2)
      DIMENSION ARRAY(15),JARRAY(15),JMAC(*),JMATYP(*),COORD(*)
C
      FIELD(1) = STATEV(1)
C
      RETURN
      END
