-- View: plandata.building_plan_overview_by_gst_kvhx_w_dotlink

-- DROP VIEW plandata.building_plan_overview_by_gst_kvhx_w_dotlink;

CREATE OR REPLACE VIEW plandata.building_plan_overview_by_gst_kvhx_w_dotlink
 AS
 SELECT a.gst_kvhx,
    a.adresse,
    k.planid,
    k.plannavn,
    k.doklink
   FROM plandata.address_only_buildings a
     JOIN plandata.komuneplan_oversigt_vedtaget_uden_geometri_v k ON a.kommune = k.komnr
  WHERE a.etagebetegnelse IS NULL;

ALTER TABLE plandata.building_plan_overview_by_gst_kvhx_w_dotlink
    OWNER TO crawler;