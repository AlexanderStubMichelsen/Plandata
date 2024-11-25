# Start

1. I [load](load-org.sh) ændre SCHEMA variablen til det schema dataen skal gemmes i
2. Lav det schema i databasen
3. Kør "sh load-org.sh" 

# Delta opdater

1. I de 6 scripts der blever kaldt inde fra "[update](update_all_Relevant_features.sh)" skal SCHEMA variablen ændres til det schema dataen skal gemmes i
- [kommuneplan forslag](theme_pdk_kommuneplan_oversigt_forslag_v_update.sh)
- [kommuneplan vedtaget](theme_pdk_kommuneplan_oversigt_vedtaget_v_update.sh)
- [Lokalplan forslag](theme_pdk_lokalplan_forslag_v_update.sh)
- [Lokalplan vedtaget](theme_pdk_lokalplan_vedtaget_v_update.sh)
- [zonekort](theme_pdk_zonekort_v.sh)
- [zonekort samlet](theme_pdk_zonekort_samlet_v_update.sh)
2. kør "sh update_all_Relevant_features.sh" 

# org2org manual for postgres

https://gdal.org/en/latest/drivers/vector/pg.html#vector-pg


# Log gui
[gui](flask_app/README.md)

# Tests
[test folder](tests)
## Happy paths
[delta](tests/happy_delta_test.sh)
## Unhappy paths
[delta](tests/unhappy_delta_test.sh)