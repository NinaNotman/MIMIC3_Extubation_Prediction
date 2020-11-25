/*
 * Using the view with the ards diagnostic from vw_ards_patient to get the hadm_id's with mechanical ventilation:
 * cptevents: cpt_cd in 94003, 94002
 * procedures_icd: ic9_code in 9672, 9671,  9670
 * procedureevents_mv: ic9_code in 225792
 * drgcodes: 1303, 475, 566, 576, 208
 * We save this result as a view.
 */

CREATE OR REPLACE VIEW public.hadm_overview
AS 
SELECT c2.hadm_id
FROM cptevents c2
WHERE c2.hadm_id IN (SELECT vw_ards_patient.hadm_id FROM vw_ards_patient)
	AND c2.cpt_cd::text = ANY (ARRAY['94003'::character varying::text, '94002'::character varying::text])
UNION
SELECT pi2.hadm_id
FROM procedures_icd pi2
WHERE pi2.hadm_id IN (SELECT vw_ards_patient.hadm_id FROM vw_ards_patient) 
	AND pi2.icd9_code::text = ANY (ARRAY['9672'::character varying::text, 
									'9671'::character varying::text, '9670'::character varying::text])
UNION
SELECT pm.hadm_id
FROM procedureevents_mv pm
WHERE pm.hadm_id IN (SELECT vw_ards_patient.hadm_id FROM vw_ards_patient)) 
	AND pm.itemid = 225792
UNION
SELECT d.hadm_id
FROM drgcodes d
WHERE d.hadm_id IN ( SELECT vw_ards_patient.hadm_id FROM vw_ards_patient)
	AND d.drg_code::text = ANY (ARRAY['1303'::character varying::text, '475'::character varying::text, 
										'566'::character varying::text, '576'::character varying::text, 
										'208'::character varying::text]);