/*
 * Create the query to get the static features of entries already found in hadm_overview 
 */

CREATE OR REPLACE VIEW public.vw_patient_group
AS (
SELECT DISTINCT vle.label,
    ho.hadm_id,
    icu.icustay_id,
    a."SUBJECT_ID",
    p.gender,
    a.admittime,
    p.dob,
        CASE
            WHEN (date_part('year'::text, a.admittime) - date_part('year'::text, p.dob)) > 89::double precision THEN 90::double precision
            ELSE date_part('year'::text, a.admittime) - date_part('year'::text, p.dob)
        END AS sub_age, -- Age of a patient. If older than 89 years: Fixed to 90.
    last_diagnosis.icd9_code AS last_icd9_code,
    last_diagnosis.amount AS numb_diagn, -- Amount of diagnostics
    icu.last_careunit,
    icu.los,
    -- Flag 1 for Tracheostomy
    CASE
        WHEN trach.hadm_id IS NOT NULL THEN 1
        ELSE 0
    END AS tracheo
FROM hadm_overview ho
JOIN admissions a ON a.hadm_id = ho.hadm_id
JOIN patients p ON p.subject_id = a."SUBJECT_ID"
-- Count the amount of diagnostics
JOIN ( SELECT di.hadm_id,
        di.icd9_code,
        max_seq.last AS amount
       FROM diagnoses_icd di
         JOIN ( SELECT di_1.hadm_id,
                max(di_1.seq_num) AS last
               FROM diagnoses_icd di_1
              GROUP BY di_1.hadm_id) max_seq ON max_seq.hadm_id = di.hadm_id AND max_seq.last = di.seq_num) last_diagnosis 
              ON last_diagnosis.hadm_id = ho.hadm_id
 -- Determine the intensive care unit where the extubation took place.
 JOIN ( SELECT DISTINCT i.hadm_id,
        i.icustay_id,
        i.last_careunit,
        i.los
       FROM icustays i
         LEFT JOIN ( SELECT vte.icustay_id,
                min(vte.charttime) AS first_extubation
               FROM vw_timestamp_extubation vte
              GROUP BY vte.icustay_id) ts ON ts.icustay_id = i.icustay_id::numeric
      WHERE (i.hadm_id IN ( SELECT hadm_overview.hadm_id
               FROM hadm_overview)) AND ts.first_extubation >= i.intime AND ts.first_extubation <= i.outtime) icu ON icu.hadm_id = ho.hadm_id
-- Join the label-query
JOIN (SELECT vte.hadm_id, vte.icustay_id, vte.hour_to_reintub::numeric as dauer,
            CASE
                WHEN vte.hour_to_reintub IS NULL THEN 1
                WHEN vte.hour_to_reintub > 48::double precision THEN 1
                ELSE 0
            END AS label
        FROM vw_ts_extubations vte ) vle ON vle.icustay_id = icu.icustay_id::numeric
LEFT JOIN ( SELECT d.hadm_id
       FROM drgcodes d
      WHERE d.description::text ~~ '%Tracheostomy%'::text) trach ON ho.hadm_id = trach.hadm_id
WHERE (ho.hadm_id IN ( SELECT hadm_overview.hadm_id
           FROM hadm_overview))
ORDER BY ho.hadm_id
);
