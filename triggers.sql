-- Lokalplan
CREATE OR REPLACE FUNCTION plandata.remove_expired_lokalplan_f() RETURNS TRIGGER AS
$$
BEGIN
DELETE FROM plandata.lokalplan_for_adresse l
WHERE l.dato_aflyst NOTNULL;
END; 
$$
language plpgsql;

CREATE OR REPLACE TRIGGER remove_expired_lokalplan_t
   AFTER UPDATE or insert ON plandata.lokalplan_for_adresse
   EXECUTE FUNCTION remove_expired_lokalplan_f();

-- Komuneplan
CREATE OR REPLACE FUNCTION plandata.remove_expired_komuneplan_f() RETURNS TRIGGER AS
$$
BEGIN
DELETE FROM plandata.komuneplan_for_adresse k
WHERE k.dato_aflyst NOTNULL;
END; 
$$
language plpgsql;

CREATE OR REPLACE TRIGGER remove_expired_komuneplan_t
   AFTER UPDATE or insert ON plandata.komuneplan_for_adresse
   EXECUTE FUNCTION remove_expired_komuneplan_f();