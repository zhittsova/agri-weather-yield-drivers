# Notebooks

EDA and evaluation notebooks for the agri-weather-yield-drivers project. Each notebook is a self-contained unit of work. They build on a shared DuckDB analytical store but can generally be read independently.

Notebooks are ordered by the prefix in their filename. EDA 2 (data source evaluation) notebooks assess individual data sources; each ends with an ingest/skip/defer decision. EDA 3 and above build on the winners.

GPU-intensive notebooks (2.13, 5.1) link to Google Colab at the top of the notebook. All others run in Binder or locally via `make sync && jupyter lab`.

---

## Completed and available

These notebooks are released, clean and reproducible.

File | # | Goal | Key questions | Outcome | Data sources | Approach
--- | --- | --- | --- | --- | --- | ---
[`0-explore-data-sources.ipynb`](0-explore-data-sources.ipynb) | 0 | First pass over publicly available data sources for Germany-level agricultural and weather data | What sources exist? What are their schemas, coverage, and access patterns? | Candidate list of ~10 sources with schema notes and access method; inputs to the EDA 2 evaluation plan | DWD CDC, Eurostat, Destatis, GISCO, SoilGrids, CORINE, ERA5 | Manual API exploration, schema inspection, coverage spot checks
[`0_5-explore-sandiness-proxies.ipynb`](0_5-explore-sandiness-proxies.ipynb) | 0.5 | Evaluate eight open-data proxies for soil sandiness at NUTS-3 level | Which proxies have sufficient coverage to substitute for direct sand-percentage measurements? Does coniferous forest cover (CORINE class 312) correlate with SoilGrids sand%? | Pine/conifer cover selected as the primary proxy; SoilGrids confirmed as ground truth where available; basis for the pine-as-proxy narrative | SoilGrids v2.0, CORINE Land Cover 2018, LUCAS, DWD phenology, Copernicus Global Land | Correlation analysis, coverage comparison, scatter plots per NUTS-3
[`1-nuts3-duckdb-data-lake.ipynb`](1-nuts3-duckdb-data-lake.ipynb) | 1 | Build a persistent DuckDB analytical store with all EU NUTS boundaries (levels 0–3) and enable spatial joins | How do we load 1,500+ NUTS polygons into DuckDB spatial? Does the 20 M scale GISCO shapefile give sufficient boundary resolution? | Fully populated `nuts_regions` table (all EU NUTS 0–3, ~1,522 features); spatial extension confirmed; basis for all subsequent region-level joins | Eurostat GISCO NUTS 2021 shapefiles (20 M scale) | GeoPandas load, GeoParquet interchange, DuckDB spatial extension, NUTS level filters
[`2_1-eval-dwd-stations-nuts3.ipynb`](2_1-eval-dwd-stations-nuts3.ipynb) | 2.1 | Map ~1,400 DWD CDC climate stations to NUTS-3 polygons and assess station density per district | How many stations fall in each NUTS-3 district? Which districts have zero coverage? Is the network dense enough to support NUTS-3 level weather aggregation? | Station density table per NUTS-3; 80%+ of German districts have at least one station; decision: ingest | DWD CDC station inventory (open, no auth) | Point-in-polygon join, DuckDB spatial, station density choropleth
[`2_2-eval-regionalstatistik-yields.ipynb`](2_2-eval-regionalstatistik-yields.ipynb) | 2.2 | Fetch NUTS-3 (Kreise) crop yields from Destatis Genesis API and assess coverage for Brandenburg and Saxony | Can the Regionalstatistik Genesis API reliably deliver Kreise-level yields? What is the AGS-to-NUTS-3 mapping coverage? | `yields_kreise` DuckDB table with ~75,500 rows; 96.8% AGS-to-NUTS-3 mapping rate; decision: ingest | Destatis Regionalstatistik Genesis, table 41241-01-03-4 (10 crops, 1999–2025) | Async job export pattern (Code 98), CSV pivot expansion, fuzzy Kreis-to-NUTS-3 mapping

## Being prepared for release

I'm wrapping up these notebooks for release, ensuring reproducibility.

File | # | Goal | Key questions | Outcome | Data sources | Approach
--- | --- | --- | --- | --- | --- | ---
[`2_3-eval-dwd-gridded.ipynb`](2_3-eval-dwd-gridded.ipynb) | 2.3 | Compare DWD HYRAS/REGNIE gridded climate products against station-based interpolation for NUTS-3 aggregation | Does the 1 km gridded product add signal over station interpolation? Is the additional complexity and download size justified? | Gridded vs station correlation assessed for temperature and precipitation; decision: skip for German-only scope, defer for EU extension | DWD CDC gridded (HYRAS, REGNIE), DWD station daily climate | Rasterio zonal stats, NUTS-3 polygon masking, correlation comparison
[`2_4-eval-corine-landcover.ipynb`](2_4-eval-corine-landcover.ipynb) | 2.4 | Compute NUTS-3 land-use fractions from the CORINE Land Cover 2018 100 m raster | What share of each NUTS-3 district is arable, forested, or urban? Does coniferous forest fraction (class 312) map to known sandy-soil regions? | Land-use fraction table per NUTS-3; coniferous forest fraction confirmed as sandy-soil proxy; decision: ingest | CORINE Land Cover 2018 (Copernicus, 100 m raster) | Rasterio zonal stats, class aggregation, choropleth maps

## In refinement

These notebooks are complete but in dirty state.
Most outcomes claimed here are preliminary but pending a rigorous validation pass before I can assure their reproducibility.

File | # | Goal | Key questions | Outcome | Data sources | Approach
--- | --- | --- | --- | --- | --- | ---
[`2_5-eval-soilgrids-zonal.ipynb`](2_5-eval-soilgrids-zonal.ipynb) | 2.5 | Try to replace point-centroid SoilGrids queries with polygon bounding-box tile download and rasterio zonal median | Does the zonal approach fix the null-return problem observed for urban centroids? Does it recover the missing chunk of state-capital measurements? | Provisionally: Null rate drops from 33% to <2%; full sand-percentage coverage for German NUTS-3; decision: ingest | SoilGrids v2.0 WCS (ISRIC), sand fraction at 0–30 cm depth | WCS tile download, rasterio zonal statistics, NUTS-3 polygon masks
[`2_6-eval-era5-land.ipynb`](2_6-eval-era5-land.ipynb) | 2.6 | Check whether ERA5-Land (0.1° reanalysis) adds climate signal beyond DWD stations for German NUTS-3 districts | Does ERA5-Land correlate sufficiently with DWD daily station observations? Is the 0.1° resolution fine enough for NUTS-3 aggregation within Germany? | ERA5-Land agrees closely with DWD for Germany; no significant additional signal at NUTS-3 scale; decision: skip (Germany-only), defer (EU extension) | ERA5-Land daily (Copernicus CDS), DWD station daily | Time-series correlation, bias check per district, sample NUTS-3 scatter plots
[`2_7-eval-eobs.ipynb`](2_7-eval-eobs.ipynb) | 2.7 | Evaluate E-OBS gridded observation dataset as an alternative or supplement to DWD stations | How does E-OBS 0.1° observation-based gridded data compare to DWD station interpolation for five sample NUTS-3 districts? | E-OBS adds value for cross-border EU studies but duplicates DWD for Germany-only; decision: defer | E-OBS v28 (Copernicus, 0.1°), DWD CDC station daily | Correlation by district, bias statistics, side-by-side time series
[`2_8-eval-bgr-buek.ipynb`](2_8-eval-bgr-buek.ipynb) | 2.8 | Evaluate the BGR BÜK 1000 federal soil map (1:1 M scale) as a supplement to SoilGrids | Does the BGR WFS deliver reliable particle-size fractions for German NUTS-3? How does it compare to SoilGrids sand%? | BGR BÜK covers Germany only; useful as a validation layer; decision: defer (SoilGrids sufficient for MVP) | BGR BÜK 1000 WFS, SoilGrids v2.0 | WFS feature download, KA5 particle-fraction lookup table, NUTS-3 join
[`2_9-eval-dwd-phenology.ipynb`](2_9-eval-dwd-phenology.ipynb) | 2.9 | Assess DWD phenology observations (crop growth stage dates) for joinability to yield and weather data | How many NUTS-3 districts have phenology station coverage? Does growing-season length (emergence to harvest) explain yield variance? | Phenology coverage is sparse (<40% of districts); growing-season length weakly correlated with yield; decision: defer | DWD CDC phenology station observations | Station-to-NUTS-3 point-in-polygon, growing-season day-count, yield correlation scatter
[`2_10-eval-esdac.ipynb`](2_10-eval-esdac.ipynb) | 2.10 | Survey ESDAC (European Soil Data Centre) datasets for soil information beyond SoilGrids | Which ESDAC layers overlap with SoilGrids? Is ESDAC a better source for Germany-specific soil hydraulic properties? | ESDAC provides complementary erosion and organic-carbon layers; hydraulic properties require registration; decision: defer | ESDAC dataset catalogue, SoilGrids v2.0 | Dataset-level comparison, coverage assessment, download feasibility check
[`3-ingest-winners.ipynb`](3-ingest-winners.ipynb) | 3 | Ingest all sources with an ingest decision into standardised DuckDB feature tables | Do the winner sources produce clean, joinable tables on `nuts_id`? Are schemas consistent across sources? | Four standardised tables: `weather_daily_nuts3`, `yields_nuts3`, `soil_nuts3`, `landcover_nuts3`; all joinable on `nuts_id` | DWD stations, Regionalstatistik Genesis, SoilGrids v2.0, CORINE Land Cover 2018 | Standardised ingest scripts per source, DuckDB COPY, schema validation
[`4-validation-coverage-signal.ipynb`](4-validation-coverage-signal.ipynb) | 4 | Validate NUTS-3 data lake coverage and test the core sandy-soil drought signal | What share of German NUTS-3 districts have complete data across all four feature tables? Is there a measurable correlation between sand% and yield loss under moisture deficit? | Coverage matrix showing >90% completeness; sand% × moisture deficit shows statistically significant negative correlation with wheat yield anomaly in Brandenburg/Saxony | All four standardised tables | Coverage matrix, join completeness audit, Pearson correlation, scatter with regression line
[`5-analysis-real-data.ipynb`](5-analysis-real-data.ipynb) | 5 | Pull live data from four public sources and assemble a wheat yield risk assessment | Can we replicate the synthetic DEMO results with real data? How stable is the sandy-soil drought signal across years? | Wheat yield risk scores by NUTS-3 district; sandy-soil regions consistently score higher risk; confirms the main project hypothesis | `weather_daily_nuts3`, `yields_nuts3`, `soil_nuts3`, `landcover_nuts3` | Feature engineering (GDD, rainfall deficit, sand-weighted indices), risk scoring, choropleth map
[`6-analysis-summary.ipynb`](6-analysis-summary.ipynb) | 6 | Read the pipeline output and produce stakeholder-ready charts and commentary | What does the risk distribution look like across German NUTS-3 districts? Which regions are most exposed? | One-page summary with risk map, top-10 at-risk districts table, and a plain-language interpretation | Pipeline output CSVs and GeoJSON from EDA 5 | Plotly choropleth, ranked table, summary prose

## Business value advisory examples

These notebooks support my upcoming posts. Will be released with the posts.

DISCLAIMER: I am not assuming any obligations or responsibility, full disclaimer, use at your own risk. Only for personal purposes. Illustrative only.

File | # | Goal | Key questions | Outcome | Data sources | Approach
--- | --- | --- | --- | --- | --- | ---
[`lp14-brandenburg-solar-siting.ipynb`](lp14-brandenburg-solar-siting.ipynb) | LP14 | Supporting analysis for post on solar siting on sandy soils in Brandenburg | Which Landkreise have the highest combination of sandy soils, low arable yield, and solar irradiance? | Ranked candidate districts for ground-mounted PV; narrative linking poor arable land to solar potential | Planned: SoilGrids sand%, CORINE arable fraction, DWD irradiance proxies, Regionalstatistik yields | TBD; planned: Composite-score ranking, choropleth
[`lp15-grid-congestion-drought.ipynb`](lp15-grid-congestion-drought.ipynb) | LP15 | Supporting analysis for post on connecting sandy-soil geography to Germany's grid congestion | Do the districts with highest solar generation also face grid curtailment? Is drought stress correlated with congestion zones? | Qualitative spatial overlap between sandy-soil PV hotspots and Bundesnetzagentur congestion zones; stop short of a causal claim? Unlikely causality analysis will be approachable with these data sets | Planned: Bundesnetzagentur redispatch data, NUTS-3 PV capacity estimates, DWD drought indices | Planned: Spatial overlay, choropleth
[`lp16-lusatia-lignite-to-solar.ipynb`](lp16-lusatia-lignite-to-solar.ipynb) | LP16 | Supporting analysis for post on the Strukturwandel narrative in Lusatia | What does the land-use transition from lignite extraction to solar parks look like quantitatively? What is the scale of the opportunity? | Area estimates of former mining land, projected PV capacity, and social context (employment, timeline) | Planned: Lausitzer Seenland data, CORINE land cover, Bundesnetzagentur, Thünen Institute | Planned: Land-use area calculation, PV capacity estimation

## Regulatory value advisory (CSRD) examples

These notebooks provide a nonbinding regulatory advisory. Will be published with upcoming posts.

DISCLAIMER: I am not assuming any obligations or responsibility, full disclaimer, use at your own risk. Only for personal purposes. Illustrative only.

File | # | Goal | Key questions | Outcome | Data sources | Approach
--- | --- | --- | --- | --- | --- | ---
[`adv-csrd-physical-climate-risk.ipynb`](adv-csrd-physical-climate-risk.ipynb) | adv | Map the sandy-soil drought risk findings to CSRD/ESRS E1 physical climate risk disclosure requirements | Which ESRS E1 disclosure categories apply? How should a company with agricultural supply chain exposure in sandy-soil regions report under ESRS E1-6? | Annotated risk assessment mapped to ESRS E1 categories; illustrative disclosure text; limitations acknowledged | EDA 4 and 5 outputs, ESRS E1 technical standard (EFRAG) | Risk taxonomy mapping, qualitative materiality assessment, illustrative disclosure drafting
