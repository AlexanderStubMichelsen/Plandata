-- View: plandata.building_plan_overview

-- DROP VIEW plandata.building_plan_overview;

CREATE OR REPLACE VIEW plandata.building_plan_overview
 AS
 SELECT a.vejnavn,
    k.planid,
    k.plannavn
   FROM plandata.address_only_buildings a
     JOIN plandata.komuneplan_oversigt_vedtaget_uden_geometri_v k ON a.kommune = k.komnr;

ALTER TABLE plandata.building_plan_overview
    OWNER TO crawler;

