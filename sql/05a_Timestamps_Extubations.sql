/* 
 * Herauslösen der relevanten TimeStamps für die Extubation
 */

CREATE OR REPLACE VIEW public.vw_ts_extubations
AS (
SELECT ve.hadm_id, ve.icustay_id, intub.ts_intubation, min(ve.charttime) AS ts_extubation,
	round(date_part('epoch', (min(ve.charttime) - intub.ts_intubation) / 3600)::numeric,2) as hour_mechvent,
	re_intub.ts_re_intubation,
	round(date_part('epoch', (re_intub.ts_re_intubation - min(ve.charttime)) / 3600)::numeric,2) as hour_to_reintub
FROM vw_extubations ve
Left join (SELECT ve.icustay_id, min(ve.charttime) AS ts_intubation
			FROM vw_extubations ve
			where ve.mechvent = 1
			GROUP BY ve.icustay_id) intub on ve.icustay_id = intub.icustay_id
left join (SELECT ve.icustay_id, min(ve.charttime) AS ts_re_intubation
			FROM vw_extubations ve
			LEFT join (SELECT ve.icustay_id, min(ve.charttime) AS ts_extubation
						FROM vw_extubations ve
						Left join (SELECT ve.icustay_id, min(ve.charttime) AS ts_intubation
							FROM vw_extubations ve
							where ve.mechvent = 1
							GROUP BY ve.icustay_id) intub on ve.icustay_id = intub.icustay_id
						where ve.mechvent = 0 and ve.ex = -1
						GROUP BY ve.icustay_id, intub.ts_intubation) ext on ve.icustay_id = ext.icustay_id
			where ve.mechvent = 1 and ve.charttime > ext.ts_extubation
			GROUP BY ve.icustay_id) re_intub on ve.icustay_id = re_intub.icustay_id
where ve.mechvent = 0 and ve.ex = -1
GROUP BY ve.hadm_id, ve.icustay_id, intub.ts_intubation, re_intub.ts_re_intubation
order by ve.icustay_id 
);