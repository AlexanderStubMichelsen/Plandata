-- View: plandata.komuneplan_oversigt_vedtaget_uden_geometri_v

-- DROP VIEW plandata.komuneplan_oversigt_vedtaget_uden_geometri_v;

CREATE OR REPLACE VIEW plandata.komuneplan_oversigt_vedtaget_uden_geometri_v
 AS
 SELECT ogc_fid,
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

ALTER TABLE plandata.komuneplan_oversigt_vedtaget_uden_geometri_v
    OWNER TO crawler;

