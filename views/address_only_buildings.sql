-- View: plandata.address_only_buildings

-- DROP VIEW plandata.address_only_buildings;

CREATE OR REPLACE VIEW plandata.address_only_buildings
 AS
 SELECT adresse,
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

ALTER TABLE plandata.address_only_buildings
    OWNER TO crawler;

