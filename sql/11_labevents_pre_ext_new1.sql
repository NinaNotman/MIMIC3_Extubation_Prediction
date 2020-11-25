/* 
 * Erzeugen einer neue Abfrage auf labevents, um die letzten x Werte vor der Extubation
 * zu bestimmen
 */

CREATE OR REPLACE VIEW public.vw_labev_values_new
AS (
SELECT l.hadm_id,
    last_val.icustay_id,
    last_val.charttime,
    CASE
        WHEN l.itemid = 50821 THEN 'Pa02'::text
        WHEN l.itemid = 50820 THEN 'pH'::text
        ELSE NULL::text
    END AS item,
    l.value,
	last_val.hours_bevor_ext
FROM labevents l
-- Joining now the labevents bevor the extubation. The highest charttime is closest to the extubation
JOIN ( SELECT distinct last_events.hadm_id,
		last_events.icustay_id,
		last_events.itemid,
		last_events.charttime,
		last_events.hours_bevor_ext
	FROM (
		SELECT l2.hadm_id,
			l2.itemid,
			min_ts.icustay_id,
			l2.charttime,
			l2.value,
			round((date_part('epoch', min_ts.ext_ts - l2.charttime) / 3600)::numeric,2) as hours_bevor_ext
		FROM labevents l2
		-- Join the timestamp with the first extubation, by filtering the labevent.charttime less then 
		-- timestamp of the extubation. We want the labevents bevor the extubation
		JOIN ( SELECT vte.hadm_id,
		            vte.icustay_id,
		            min(vte.charttime) AS ext_ts
		           FROM vw_timestamp_extubation vte
		          GROUP BY vte.hadm_id, vte.icustay_id) min_ts ON min_ts.hadm_id = l2.hadm_id AND min_ts.ext_ts > l2.charttime
		WHERE l2.itemid = ANY (ARRAY[50821, 50820])) last_events
	where last_events.hours_bevor_ext <= 48
	) last_val ON (last_val.hadm_id = l.hadm_id AND last_val.itemid = l.itemid AND last_val.charttime = l.charttime)
 ORDER BY l.hadm_id, last_val.icustay_id, l.itemid, last_val.charttime
 );