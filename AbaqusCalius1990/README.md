# Calius, Lee & Springer (1990): F-1, F-4, F-6 silindirlerinin Abaqus 2025 ile doğrulanması

Kaynak: *Filament Winding Cylinders: II. Validation of the Process Model*, J. Composite Materials 24 (1990), 1299–1343.

## 1. Dosyalar ve çalıştırma sırası

| Dosya | Ne işe yarar | Nasıl çalışır |
|---|---|---|
| `calius_data.py` | Makaledeki tüm veriler: Tablo 1–5, Şekil 2, Şekil 13–14 yüzey sıcaklıkları, gauge yerleri. SI birime dönüşüm ve ±φ ply rijitliğinin global eksenlere döndürülmesi | `python3 calius_data.py` (geometri özetini basar) |
| `check_1d.py` | Abaqus'tan bağımsız 1D kontrol modeli: kür kinetiği ve termoelastik gerinim hedefleri | `python3 check_1d.py` |
| `build_model.py` | **Abaqus/CAE betiği.** Geometri, mesh, setler, yüzeyler, adım, amplitüdler, sınır koşulları, etkileşimler ve çıktı isteklerini kurar. **inp yazmaz.** | `abaqus cae noGUI=build_model.py` |
| `kw_gen.py` | Elle eklenecek keyword bloklarını üretir. CAE betiği bunu çağırır ve `kw_<MODEL>.txt` dosyalarını yazar | `python3 kw_gen.py BENCH` (önizleme) |
| `cure976_tabular.txt` | `*CURE KINETICS, DEFINITION=TABULAR` için hazır veri (α̇, α, T); Tablo 3'teki HT/Hu(T) ile birebir | `python3 kw_gen.py tabular` ile yeniden üretilir |

**Alt program yok.** Kür kinetiği, ekzoterm ve büzülme Abaqus 2025'in yerleşik *Curing Processes in Polymers* seçenekleriyle tanımlanır: `*CURE KINETICS`, `*CURE HEAT GENERATION`, `*CURE SHRINKAGE` ve `*USER DEFINED FIELD, TYPE=SPECIFIED` (FV1 = DOC).

Çalışma sırası:

1. `abaqus cae noGUI=build_model.py`: `calius1990_cylinders.cae` dosyasını ve `kw_BENCH_F6_TIE.txt`, `kw_F6_EXP.txt`, `kw_F1_EXP.txt`, `kw_F4_EXP.txt` dosyalarını üretir.
2. CAE'de ilgili modeli açın. **Model → Edit Keywords** ile `kw_<MODEL>.txt` içindeki blokları dosyada belirtilen yerlere ekleyin (bkz. §4).
3. Job → Write Input, ardından `abaqus job=BENCH_F6_TIE cpus=1`.
4. Sonuçları ölçümlerle karşılaştırın (§5).

> Mesh'i değiştirirseniz düğüm numaraları da değişir. Bu durumda `build_model.py`'yi yeniden çalıştırıp güncel `kw_*.txt` dosyasını kullanın, çünkü `*Equation` blokları düğüm numarası içerir.

## 2. Geometriler (Tablo 4, Tablo 5, şekillerdeki katman sayıları)

| | F-1 | F-4 | F-6 | BENCH (Tablo 1) |
|---|---|---|---|---|
| İç çap D (in) | 3 | 3 | 6 | 6 |
| Et kalınlığı h (in) | 0.27 | 1.125 | 0.156 (5/32) | 0.156 |
| Ply sayısı | 28 | 82 | 18 | 18 |
| Sarım açısı (eksenden) | ±55° | ±32° | ±40° | ±40° |
| Membran boyu L / toplam Lt (in) | 14 / 18 | 16.5 / 26.5 | 18 / 25 | 25 |
| Kubbe deliği Db, Lb (in) | 1.25, 0.5 | 1.25, 5 (özel kubbe, Şekil 11 üst) | 2, 0.5 | – |
| Mandrel (Al 6061-T6) kalınlığı | **0.25 VARSAYIM** | **0.25 VARSAYIM** | 0.25 (Şekil 1, 29) | 0.25 |
| Gerginlik (lb) / bant (in) | 8.5 / 0.135 | 8 / 0.125 | 10 / 0.135 | 6 / 0.125 |
| Rampa / soğuma (°F/dk), süre (saat) | 3.8 / −0.5, 14 | 1.2 / −0.8, 13 | 1.5 / −1, 10 | 4.7 / −1.57, 6 |

Makale F-1 ve F-4 mandrellerinin kalınlığını vermiyor. Elinizde bilgi varsa `calius_data.py` içindeki `t_mandrel_in` değerini değiştirin.

## 3. Model, sınır koşulları ve etkileşimler

**Model tipi.** Genelleştirilmiş eksenel simetrik, burulmalı, coupled temperature-displacement **dilim** modeli (`CGAX4T`). Eksenel boy `DZ = 0.5 mm`, eksende 1 eleman. Bu kurgu makaledeki WINDTHICK modelini birebir temsil eder: uzun silindir varsayılır, değişkenler yalnızca r'ye bağlıdır ve mandrel ile kompozit aynı eksenel uzamayı yapar. Kompozit ply ply bölünür; iç yüzeyden başlayarak +φ / −φ ardışık dizilir. Ply başına 2 eleman kullanıldığı için h/4, h/2 ve 3h/4 noktaları birer düğüme denk gelir. ±φ ply'lar Z–θ düzleminde kayma kuplajı taşıdığından CAX değil CGAX kullanılır.

**Birimler.** m, kg, s, N, Pa, J, **K**. Kür kinetiği Arrhenius tipinde olduğu için sıcaklık doğrudan Kelvin cinsindendir.

| Bileşen | BENCH_F6_TIE (1. aşama) | F1/F4/F6_EXP (2. aşama) |
|---|---|---|
| Adım | `*Coupled Temperature-Displacement`, transient, DELTMX = 5 K, maks. artım 60 s | aynı |
| Mandrel iç yüzeyi `MANDREL-1.E_IN` | T = Tm(t), `AMP_TM` (Şekil 2, Tablo 1 rampalarından tam olarak kurulur) | T = Tm(t), Şekil 13–14 |
| Kompozit dış yüzeyi `COMPOSITE-1.E_OUT` | T = Tc(t) = Tm(t) | T = Tc(t), Şekil 13–14 |
| Alt yüz (z = 0) | U2 = 0 (CAE), DOF5 burulma = 0 (keyword) | aynı |
| Üst yüz (z = DZ) | Tüm düğümler `*Equation` ile tek master düğüme bağlanır (DOF 2 ve 5): eşit eksenel uzama, eksenel kuvvet = 0, tork = 0 | aynı (`EQUAL`); kompozit için ayrı master (`SLIP`) |
| Mandrel–kompozit | `*Tie` (tam yapışık; sıcaklık da bağlanır) | Hard kontakt, ayrılabilir, sürtünmesiz + gap conductance (temasta 1e6, açılınca 300 → 0 W/m²K) |
| Başlangıç sıcaklığı | 75 °F (Şekil 2) | iki yüzeyin t = 0 sıcaklıklarının ortalaması |

Kontakt modunda eksenel eşitlik `*Equation` ile zaten sağlandığı için sürtünme bilerek kullanılmadı; aksi halde aşırı kısıt oluşur. Kontakt, soğuma sırasında mandrelin kompozitten ayrılmasını yakalar. Şekil 30'da yaklaşık 6.8. saatteki hoop sıçraması bu ayrılmadır.

**Gerinim çıktısı.** Gauge'lar yüzeye yapıştırıldığı için gerinimler düğüm yer değiştirmesinden hesaplanır:
- hoop: ε_θ = U1 / r (her `G_*` düğümünün history çıktısı)
- eksenel: ε_z = U2(`MANDREL-1.TOP_MASTER`) / DZ
- Ayrıca h/2 elemanlarında (`EL_H2`) E33 (hoop), E22 (eksenel) ve TEMP (CAE'den), DOC, DOCR ve CURESE (keyword ile) history olarak alınır.

**Oryantasyon.** `*CURE SHRINKAGE, TYPE=ANISO` yerel oryantasyon istediği için CAE betiği kompozite global (r, z, θ) eksenleriyle çakışan bir `*Orientation` atar. Böylece tüm anizotrop veriler global eksenlerde, ±φ'ye göre önceden döndürülmüş olarak girilir.

## 4. Eklenecek keyword'ler

`kw_<MODEL>.txt` içinde hazır gelir. Aşağıda ne olduklarını ve nereye konduklarını listeliyorum.

### 4.1 BENCH_F6_TIE (F-6, Tablo 1 kabulleri: büzülme yok, tam yapışık, sabit kürlenmiş özellikler)

| # | Keyword | Yer | Not |
|---|---|---|---|
| 1 | `*Physical Constants, absolute zero=0.` | model verisi, `*Heading` sonrası | sıcaklıklar K cinsinden |
| 2 | `*Conductivity`, `*Density`, `*Elastic`, `*Expansion`, `*Specific Heat` | `*Material, name=AL6061_EFF` altı | E = 10 Msi, ν = 0.33, **etkin** CTE = 15.8e-6/°F (Tablo 2) |
| 3 | `*Conductivity, type=ORTHO`, `*Density`, `*Specific Heat` | `T300_976_P` ve `_M` altı | global (r, z, θ) eksenlerine döndürülmüş |
| 4 | `*Elastic, type=ANISOTROPIC` (21 sabit) | aynı | Tablo 2, α ≥ 0.6 kolonu, ±φ'ye göre döndürülmüş |
| 5 | `*Expansion, type=ANISO` | aynı | Tablo 2 CTE'leri (§4.3'teki teste bakın) |
| 6 | `*Cure Kinetics, definition=KAMAL` (2 terim) | aynı | Lee-Springer ile birebir (aşağıya bakın) |
| 7 | `*Cure Heat Generation` | aynı | Q = w_reçine · Hu = 0.30 × 530 J/g = 1.59e5 J/kg; q = ρ·Q·α̇ |
| 8 | `*Boundary` (`BOT_N`, DOF 5) | `*End Assembly` sonrası, `*Step` öncesi | burulma referansı |
| 9 | `*Equation` (DOF 2 ve 5) | `*Assembly` içinde, `*End Assembly` öncesi | genelleştirilmiş düzlem gerinim ve burulma |
| 10 | `*Output, field/history` + `*Element Output: DOC, DOCR, CURESE` | `*Step` içinde, `*End Step` öncesi | kür çıktıları |

**Lee-Springer → Kamal eşlemesi.** Tablo 3'teki model dα/dt = (HT/Hu)(K₁ + K₂ψᵃ)(1 − ψ)ᵇ şeklindedir. HT/Hu = 1 alınırsa Abaqus Kamal formu α̇ = Σ Zᵢ e^{−(Eᵢ/R)/θ}(bᵢ + α^{mᵢ})(α_max − α)^{nᵢ} ile birebir aynı olur:

| Terim | Z (1/s) | E/R (K) | m | n | b |
|---|---|---|---|---|---|
| 1 | 4400 | 7517.4 | 0 | 1.22 | 0 |
| 2 | 7500 | 6831.9 | 1.03 | 1.22 | 0 |

m₁ = 0 olduğu için reaksiyon α = 0'dan kendiliğinden başlar; `*Initial Conditions, type=CURE` gerekmez. İki modelin hızlarını birkaç (T, α) noktasında sayısal olarak karşılaştırdım, aynı çıkıyor.

Tablo 3'teki HT/Hu = 0.0044T − 1.1 terimi Z'yi sıcaklığa bağlı yaptığı için Kamal formuna girmez. Bu terimle birebir sonuç isterseniz `kw_gen.py` içinde `KINETICS = 'TABULAR'` yapın ve `cure976_tabular.txt` içeriğini `*Cure Kinetics, definition=TABULAR` altına yapıştırın (45 sıcaklık × 101 α = 4545 satır). Bu durumda α en fazla HT/Hu değerine ulaşır, ayrıca `*Cure Max Conversion` gerekmez.

### 4.2 F1/F4/F6_EXP (deneysel yüzey sıcaklıkları), §4.1'e ek olarak

| Keyword | Amaç |
|---|---|
| `*User Defined Field, type=SPECIFIED` / `1, DOC` | FV1 = DOC (USDFLD gerekmez) |
| `*Elastic, type=ANISOTROPIC, dependencies=1` (iki satır: FV1 = 0.2 ve FV1 = 0.6) | Özellikler α ≤ 0.2 ve α ≥ 0.6 için sabit, arada doğrusal (makaledeki kabul) |
| `*Cure Shrinkage, type=ANISO, dependencies=1` | ε̇ˢ = −γ α̇; plyda γ₂₂ = γ₃₃ = η = 1.25e-2, γ₁₁ = 0, global eksenlere döndürülmüş. Yalnızca 0.2 < DOC < 0.6 aralığında etkin (Appendix'te η, Δα = α₂ − α₁ = 0.4 ile türetilmiş); toplam enine büzülme yaklaşık 5000 µε |

> **Önemli uyarı (2. aşama).** Abaqus `*Elastic` total formdadır: σ = D(DOC)·ε_el. Jelleşmede D yaklaşık 100 kat arttığı için, ısınmada birikmiş elastik gerinim sahte gerilmeye dönüşebilir. Ölçümler, kompozitin mandrel genleşmiş haldeyken kürlendiğini gösteriyor (Şekil 29–30'da tutma süresince yaklaşık 4000 µε sabit kalıyor). Sonuçlarda bekleme başında gerinim sıçraması görürseniz yerleşik kür çerçevesinin önerdiği şekilde `*Viscoelastic` + `*TRS` (DOC'a bağlı) tanımı ya da artımsal bir UMAT gerekebilir. 1. aşamada özellikler sabit olduğundan bu sorun yoktur.

### 4.3 CTE kayma konvansiyonu testi (bir kez yapın)

`*Expansion, type=ANISO` girdisinin 12, 13 ve 23 bileşenleri **tensör** bileşeni olarak yazıldı: α_zθ = (α₁ − α₂)·sinφ·cosφ. Kontrol için tek bir CGAX4T elemanını serbest genleştirin (tek düğümde U1/U2/DOF5 kısıtlı, ΔT = 100 K, malzeme `T300_976_P`). Beklenen sonuç E23 = 2·α₂₃·100 (BENCH için −3.06e-3). Sonuç bunun yarısı çıkarsa Abaqus engineering değer bekliyordur; 4–6. bileşenleri ikiyle çarpın.

`check_1d.py` bu konuda bir ipucu veriyor. Doğru konvansiyonla h/2'de 3606 µε hoop ve 2554 µε eksenel buluyorum; yanlış konvansiyonla 3802 ve 2997. Şekil 5'teki eksenel değer yaklaşık 2600 µε ve doğru konvansiyonu destekliyor.

## 5. Hedef değerler

**BENCH (Şekil 3 ve 5, h/2).** `check_1d.py` sonuçları:

| t (saat) | T (°F) | α (TABULAR, Tablo 3 HT/Hu) | ψ | α (KAMAL, HT/Hu = 1) |
|---|---|---|---|---|
| 0.75 | 287 | 0.019 | 0.027 | 0.030 |
| 1.00 | 350 | 0.19 | 0.21 | 0.24 |
| 1.25 | 350 | 0.58 | 0.66 | 0.68 |
| 1.50 | 350 | 0.78 | 0.89 | 0.89 |
| 2.00 | 350 | 0.86 | 0.98 | 0.98 |

Şekil 3'teki α eğrisi 1.0'a gidiyor. Tablo 3'teki HT/Hu ile α en fazla 0.88'e ulaşır; bu yüzden Şekil 3'ün ψ'yi ya da HT/Hu = 1 durumunu çizdiğini düşünüyorum. Varsayılan `KAMAL` tanımı HT/Hu = 1 durumuna karşılık gelir. `TABULAR` tanımıyla iki durum karşılaştırılabilir.

| Gerinim, hold (ΔT = 275 °F) | Şekil 5 | 1D kontrol | Abaqus'ta beklenen |
|---|---|---|---|
| hoop, h/2 | ≈ 3800 µε | 3606 µε | ≈ 3606 µε |
| eksenel | ≈ 2600 µε | 2554 µε | ≈ 2554 µε |

Sabit özellikler ve büzülmesiz durumda gerinim ΔT ile doğrusaldır ve soğuma sonunda yaklaşık 0'a döner. Abaqus dilim modeli 1D kontrolle aynı problemi çözdüğü için bu iki sonuç birbirini tutmalıdır. Kalan yaklaşık %5'lik hoop farkı makalenin lif hareketi ve sargı alt modellerinden ya da şekil okumasından kaynaklanabilir.

**Deneysel veriler (2. aşama):**

| | Sıcaklık | Gerinim |
|---|---|---|
| F-1 | Şekil 18 (h/2) | **makalede yok**; F-1 yalnızca sıcaklıkla doğrulanabilir |
| F-4 | Şekil 21 a–d (a = arayüz, b = h/4, c = h/2, d = 3h/4) | Şekil 25 (hoop), Şekil 26 (eksenel), a = mandrel dış yüzeyi … e = dış yüzey |
| F-6 | makalede verilmemiş (et ince, yüzey sıcaklığına eşit) | Şekil 29 (mandrel iç yüzeyi), Şekil 30 (h/2), Şekil 31 (eksenel kayma), Şekil 37 (halka) |

Notlar:
- F-4'te mandrel yüzeyi yaklaşık 415 °F'a çıkıyor (ekzoterm). Bu tepe `RESIN_MASS_FRACTION = 0.30` değerine (yani `*Cure Heat Generation` içindeki Q'ya) duyarlı; makale bu oranı vermiyor.
- F-6'da eksenel gerinim ölçümü modelden yaklaşık 500 µε düşük. Makaleye göre bunun nedeni mandrel ile kompozit arasındaki eksenel kayma (Şekil 31). Ölçümle karşılaştırmak için `SLIP` modunu bir üst sınır olarak deneyin.
- Kubbe etkisi 6 inç çaplı silindirlerde hoop gerinimini yaklaşık 600 µε etkiliyor (Şekil 33–34). Dilim modeli bu etkiyi içermez.

## 6. Kabuller ve eksikler

- Şekil 13–14'ten okunan yüzey sıcaklıkları **gözle okunmuş yaklaşık değerlerdir** (±10 °F). Doğrulamadan önce WebPlotDigitizer ile sayısallaştırıp `calius_data.SURFACE_T_F` içine yazın. BENCH profili ise Tablo 1'den tam olarak kurulur.
- Sargı gerginliğinden gelen başlangıç gerilmesi ve lif hareketi/sıkışma (Şekil 4) modellenmedi. Gauge'lar fırın başında sıfırlandığı için gerinim karşılaştırması bundan az etkilenir; gerilme karşılaştırması ise etkilenir. Gerekirse `*Initial Conditions, type=STRESS` ile eklenebilir.
- Tablo 2'deki G₂₃ = 1.09 Msi ve ν₂₃ = 0.25 birbiriyle uyumsuz ama makaleye sadık kalmak için tablo değerleri kullanıldı.
- `*Cure Heat Generation` veri satırını (tek değer: Q) yüklediğiniz belgelerdeki q = ρ₀Qα̇ tanımından çıkardım; o keyword'ün kendi sayfası elimde yoktu. 2025 dokümanından satır biçimini bir kez teyit edin.
- `build_model.py` bu ortamda Abaqus olmadığı için **çalıştırılmadı**; yalnızca sözdizimi kontrol edildi. CAE'de hata çıkarsa (ör. `CGAX4T` sabiti veya `main=`/`secondary=` argümanları) bana mesaj satırını iletin.
