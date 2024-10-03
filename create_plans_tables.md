``` sql
DROP TABLE IF EXISTS plandata.lokalplan_for_adresse;
CREATE TABLE plandata.lokalplan_for_adresse as
    SELECT a.adresse, a.adgangsadressebetegnelse, l.plannavn plan_navn, l.doklink plandata_link, l.datoforsl dato_forslået, l.datovedt dato_vedtaget, l.datoaflyst dato_aflyst, l.datoikraft dato_i_kraft, l.datostart dato_start, l.datoslut dato_slut
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
    SELECT a.adresse, a.adgangsadressebetegnelse, k.plannavn plan_navn, k.doklink plandata_link, k.datoforsl dato_forslået, k.datovedt dato_vedtaget, k.datoaflyst dato_aflyst, k.datoikraft dato_i_kraft, k.datostart dato_start, k.datoslut dato_slut
    FROM plandata.address_only_buildings AS a
    JOIN plandata.komuneplan_oversigt_vedtaget_uden_geometri_v AS k ON a.kommune = k.komnr;
INSERT INTO plandata.komuneplan_for_adresse
    SELECT a.adresse, k.doklink, false vedtaget
    FROM plandata.address_only_buildings AS a
    JOIN plandata.komuneplan_oversigt_forslag_uden_geometri_v AS k ON a.kommune = k.komnr;
```