``` sql
DROP TABLE IF EXISTS plandata.lokalplan_for_adresse;
CREATE TABLE plandata.lokalplan_for_adresse as
    SELECT a.adresse, l.doklink, true vedtaget
        FROM plandata.theme_pdk_lokalplan_vedtaget_v l
        JOIN plandata.address_only_buildings a on a.kommune = l.komnr
        WHERE st_isvalid(l.geometri) and st_within(a.koord_25832, l.geometri);
INSERT INTO plandata.lokalplan_for_adresse
    SELECT a.adresse, l.doklink, false vedtaget
    FROM plandata.theme_pdk_lokalplan_forslag_v l
    JOIN plandata.address_only_buildings a on a.kommune = l.komnr
    WHERE st_isvalid(l.geometri) and st_within(a.koord_25832, l.geometri)
```
``` sql
DROP TABLE if EXISTS plandata.komuneplan_for_adresse;
CREATE TABLE plandata.komuneplan_for_adresse as
SELECT a.adresse, k.doklink, true vedtaget
FROM plandata.address_only_buildings AS a
    JOIN plandata.komuneplan_oversigt_vedtaget_uden_geometri_v AS k ON a.kommune = k.komnr;
INSERT INTO plandata.komuneplan_for_adresse
SELECT a.adresse, k.doklink, false vedtaget
FROM plandata.address_only_buildings AS a
    JOIN plandata.komuneplan_oversigt_forslag_uden_geometri_v AS k ON a.kommune = k.komnr;
```