\set env_schema `echo "$SCHEMA"`

CREATE OR REPLACE VIEW :env_schema.komuneplan_oversigt_forslag_uden_geometri_v
AS SELECT ogc_fid,
    gml_id,
    oid_,
    id,
    planid,
    objektkode,
    komnr,
    plannavn,
    doklink,
    datoforsl,
    datovedt,
    datoaflyst,
    datoikraft,
    datoslut,
    aktuel,
    datooprt,
    datoopdt,
    status,
    datostart,
    glkomnr,
    kommunenavn,
    glkomnavn
   FROM :env_schema.theme_pdk_kommuneplan_oversigt_forslag_v;

-- komuneplan oversigt vedtaget
CREATE OR REPLACE VIEW :env_schema.komuneplan_oversigt_vedtaget_uden_geometri_v
AS SELECT ogc_fid,
    gml_id,
    oid_,
    id,
    planid,
    objektkode,
    komnr,
    plannavn,
    doklink,
    datoforsl,
    datovedt,
    datoaflyst,
    datoikraft,
    datoslut,
    aktuel,
    datooprt,
    datoopdt,
    status,
    datostart,
    glkomnr,
    kommunenavn,
    glkomnavn
   FROM :env_schema.theme_pdk_kommuneplan_oversigt_vedtaget_v;
  
-- address only view
CREATE OR REPLACE VIEW :env_schema.address_only_buildings
AS SELECT adresse,
    validitet,
    enhedadressebetegnelse,
    etagebetegnelse,
    doerbetegnelse,
    adgangsadressebetegnelse,
    adgangspunkt,
    position_point,
    esr_zone,
    udtalt_vejnavn,
    vejadresseringsnavn,
    vejnavn,
    kommune,
    vejkode,
    husnummertekst,
    supplerende_by,
    postnr,
    by,
    adressepunkt_lokalid,
    navngivenvej_lokalid,
    navngivenvejkommunedel_lokalid,
    supplerende_bynavn_lokalid,
    postnummer_lokalid,
    husnummer,
    gst_kvhx,
    gst_kvhx_part8,
    gst_kvhx_part12,
    bbr_kvhx,
    koord_25832_x,
    koord_25832_y,
    koord_4326_x,
    koord_4326_y,
    koord_25832,
    koord_4326
   FROM public.adresse
  WHERE etagebetegnelse IS NULL;

-- Lokalplan
DROP TABLE IF EXISTS :env_schema.lokalplan_for_adresse ;
CREATE TABLE :env_schema.lokalplan_for_adresse as
    SELECT a.adresse, a.adgangsadressebetegnelse, l.id plan_id, l.plannavn plan_navn, l.doklink dok_link, l.datoforsl dato_forslået, l.datovedt dato_vedtaget, l.datoaflyst dato_aflyst, l.datoikraft dato_i_kraft, l.datostart dato_start, l.datoslut dato_slut, l.datoopdt dato_opdateret
        FROM :env_schema.theme_pdk_lokalplan_vedtaget_v l
        JOIN public.address_only_buildings a on a.kommune = l.komnr
        WHERE st_isvalid(l.geometri) and st_within(a.koord_25832, l.geometri);
INSERT INTO :env_schema.lokalplan_for_adresse
    SELECT a.adresse, a.adgangsadressebetegnelse, l.id plan_id, l.plannavn plan_navn, l.doklink dok_link, l.datoforsl dato_forslået, l.datovedt dato_vedtaget, l.datoaflyst dato_aflyst, l.datoikraft dato_i_kraft, l.datostart dato_start, l.datoslut dato_slut, l.datoopdt dato_opdateret
    FROM :env_schema.theme_pdk_lokalplan_forslag_v l
    JOIN public.address_only_buildings a on a.kommune = l.komnr
    WHERE st_isvalid(l.geometri) and st_within(a.koord_25832, l.geometri);

-- Komuneplan

DROP TABLE if EXISTS :env_schema.komuneplan_for_adresse;
CREATE TABLE :env_schema.komuneplan_for_adresse as
    SELECT a.adresse, a.adgangsadressebetegnelse, k.id plan_id, k.plannavn plan_navn, k.doklink dok_link, k.datoforsl dato_forslået, k.datovedt dato_vedtaget, k.datoaflyst dato_aflyst, k.datoikraft dato_i_kraft, k.datostart dato_start, k.datoslut dato_slut, k.datoopdt dato_opdateret
    FROM public.address_only_buildings AS a
    JOIN :env_schema.komuneplan_oversigt_vedtaget_uden_geometri_v AS k ON a.kommune = k.komnr;
INSERT INTO :env_schema.komuneplan_for_adresse
    SELECT a.adresse, a.adgangsadressebetegnelse, k.id plan_id, k.plannavn plan_navn, k.doklink dok_link, k.datoforsl dato_forslået, k.datovedt dato_vedtaget, k.datoaflyst dato_aflyst, k.datoikraft dato_i_kraft, k.datostart dato_start, k.datoslut dato_slut, k.datoopdt dato_opdateret
    FROM public.address_only_buildings AS a
    JOIN :env_schema.komuneplan_oversigt_forslag_uden_geometri_v AS k ON a.kommune = k.komnr;

-- Zonekort
DROP TABLE if EXISTS :env_schema.Zonekort_for_adresse;
CREATE TABLE :env_schema.Zonekort_for_adresse as
    SELECT a.adresse, a.adgangsadressebetegnelse, z.zone, z.zonestatus
    FROM public.address_only_buildings AS a
    JOIN :env_schema.theme_pdk_zonekort_v AS z ON a.kommune = z.komnr
    WHERE st_isvalid(z.geometri) and st_within(a.koord_25832, z.geometri);

