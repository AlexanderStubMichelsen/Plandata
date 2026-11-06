# Plandata

Scripts that load Danish **planning data** (municipal plans, local plans and zone maps) from [Plandata.dk](https://plandata.dk/)'s WFS service into a PostGIS database, keep it up to date with delta updates, and verify the data with hashing.

Built as part of a final exam project. The data powers the zone map in [skraafoto.devdisplay](https://github.com/AlexanderStubMichelsen/skraafoto.devdisplay) ([live](https://skraafoto.machinemal.eu)).

## Layers

| Layer | Content |
|---|---|
| `theme_pdk_kommuneplan_oversigt_forslag_v` / `_vedtaget_v` | Municipal plans: proposed / adopted |
| `theme_pdk_lokalplan_forslag_v` / `_vedtaget_v` | Local plans: proposed / adopted |
| `theme_pdk_zonekort_v` / `_samlet_v` | Zone map |

## Requirements

- PostgreSQL with PostGIS
- GDAL (`ogr2ogr`): [PostgreSQL driver docs](https://gdal.org/en/latest/drivers/vector/pg.html)
- bash; Python 3 + Flask for the log viewer

## Usage

### 1. Initial load

1. Set the `SCHEMA` variable in [load-ogr.sh](load-ogr.sh) to the schema the data should go in.
2. Create that schema in the database (tables: [create_plans_tables.sql](update/sql_scripts/create_plans_tables.sql)).
3. Run:
   ```bash
   sh load-ogr.sh
   ```

### 2. Delta updates

Fetches only what changed since the last run.

1. Set `SCHEMA` in each script in [update/bash_scripts](update/bash_scripts).
2. Run:
   ```bash
   sh master_scripts/update/update_all_relevant_features.sh
   ```

### 3. Verify with hashing

Hashes every table and compares the results, to detect changes or inconsistencies:

```bash
sh master_scripts/hashing/hash_all_tables.sh
sh master_scripts/comparing/compare_all_tables_hash.sh   # results: master_scripts/comparing/comparing_results/
```

## Structure

```
load-ogr.sh                initial load
update/                    per-layer delta-update scripts + SQL table definitions
hashing_and_comparing/     per-layer hash and compare scripts
master_scripts/            run all layers at once (update, hash, compare) + results
tests/                     delta and hash tests (logs in tests/logs)
flask_app/                 small web GUI for viewing the logs (see flask_app/README.md)
```

## Tests

```bash
sh tests/delta_test.sh
sh tests/hash_changes_test.sh
sh tests/hash_no_changes_test.sh
```

> Database connection details are set in the scripts. Use your own local credentials, and don't commit real passwords.
