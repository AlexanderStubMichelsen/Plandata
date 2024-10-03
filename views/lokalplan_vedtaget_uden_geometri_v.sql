-- View: plandata.lokalplan_vedtaget_uden_geometri_v

-- DROP VIEW plandata.lokalplan_vedtaget_uden_geometri_v;

CREATE OR REPLACE VIEW plandata.lokalplan_vedtaget_uden_geometri_v
 AS
 SELECT ogc_fid
   FROM plandata.theme_pdk_lokalplan_vedtaget_v;

ALTER TABLE plandata.lokalplan_vedtaget_uden_geometri_v
    OWNER TO crawler;

