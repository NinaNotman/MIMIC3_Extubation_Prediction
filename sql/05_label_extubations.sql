/*
 * Getting the label from the duraton between extubation and intubation.
 */

CREATE OR REPLACE VIEW public.vw_label_extubations
AS 
SELECT vte.hadm_id, vte.icustay_id, vte.hour_to_reintub,
	CASE
        WHEN vte.hour_to_reintub IS NULL THEN 1
        WHEN vte.hour_to_reintub > 48::double precision THEN 1
        ELSE 0
    END AS label
FROM vw_ts_extubations vte 