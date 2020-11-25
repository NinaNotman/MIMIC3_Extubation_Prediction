/*
 * In this Query, we will find all entries with the 'Acute respiratory failure' called ARDS.
 * We ignore entries vom the Neonatal intensive care unit.
 * The entries we get back are stored in a view for later access.
 */

CREATE OR REPLACE VIEW public.vw_ards_patient
AS (
SELECT diagnoses_icd.hadm_id
FROM diagnoses_icd
WHERE diagnoses_icd.icd9_code::text = '51881'::text 
  	AND NOT (diagnoses_icd.hadm_id IN ( 
  				SELECT t.hadm_id FROM transfers t
          		WHERE t.curr_careunit::text = 'NICU'::text)
          	)
);
