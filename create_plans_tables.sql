
-- komuneplan oversigt forslag
CREATE OR REPLACE VIEW plandata.komuneplan_oversigt_forslag_uden_geometri_v
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
   FROM plandata.theme_pdk_kommuneplan_oversigt_forslag_v;

-- komuneplan oversigt vedtaget
CREATE OR REPLACE VIEW plandata.komuneplan_oversigt_vedtaget_uden_geometri_v
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
   FROM plandata.theme_pdk_kommuneplan_oversigt_vedtaget_v;
  
-- address only view
CREATE OR REPLACE VIEW plandata.address_only_buildings
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
   FROM adresse
  WHERE etagebetegnelse IS NULL;

-- Lokalplan
DROP TABLE IF EXISTS plandata.lokalplan_for_adresse;
CREATE TABLE plandata.lokalplan_for_adresse as
    SELECT a.adresse, a.adgangsadressebetegnelse, l.plannavn plan_navn, l.doklink plandata_link, l.datoforsl dato_forslået, l.datovedt dato_vedtaget, l.datoaflyst dato_aflyst, l.datoikraft dato_i_kraft, l.datostart dato_start, l.datoslut dato_slut, l.datoopdt dato_opdateret
        FROM plandata.theme_pdk_lokalplan_vedtaget_v l
        JOIN plandata.address_only_buildings a on a.kommune = l.komnr
        WHERE st_isvalid(l.geometri) and st_within(a.koord_25832, l.geometri);
INSERT INTO plandata.lokalplan_for_adresse
    SELECT a.adresse, l.doklink, false vedtaget
    FROM plandata.theme_pdk_lokalplan_forslag_v l
    JOIN plandata.address_only_buildings a on a.kommune = l.komnr
    WHERE st_isvalid(l.geometri) and st_within(a.koord_25832, l.geometri)

-- Komuneplan

DROP TABLE if EXISTS plandata.komuneplan_for_adresse;
CREATE TABLE plandata.komuneplan_for_adresse as
    SELECT a.adresse, a.adgangsadressebetegnelse, k.plannavn plan_navn, k.doklink plandata_link, k.datoforsl dato_forslået, k.datovedt dato_vedtaget, k.datoaflyst dato_aflyst, k.datoikraft dato_i_kraft, k.datostart dato_start, k.datoslut dato_slut, k.datoopdt dato_opdateret
    FROM plandata.address_only_buildings AS a
    JOIN plandata.komuneplan_oversigt_vedtaget_uden_geometri_v AS k ON a.kommune = k.komnr;
INSERT INTO plandata.komuneplan_for_adresse
    SELECT a.adresse, k.doklink, false vedtaget
    FROM plandata.address_only_buildings AS a
    JOIN plandata.komuneplan_oversigt_forslag_uden_geometri_v AS k ON a.kommune = k.komnr;

-- Zonekort
DROP TABLE if EXISTS plandata.Zonekort_for_adresse;
CREATE TABLE plandata.Zonekort_for_adresse as
    SELECT a.adresse, a.adgangsadressebetegnelse, z.zone, z.zonestatus
    FROM plandata.address_only_buildings AS a
    JOIN plandata.theme_pdk_zonekort_v AS z ON a.kommune = z.komnr
    WHERE st_isvalid(z.geometri) and st_within(a.koord_25832, z.geometri)

