/*
 * Filtering the labevents for some specific itemis's bevor the extubation.
 */

CREATE OR REPLACE VIEW public.vw_labev_values
AS (
SELECT l.hadm_id,
    last_val.icustay_id,
    l.itemid,
    l.value,
    last_val.ts,
        CASE
            WHEN l.itemid = 50821 THEN 'Pa02'::text
            WHEN l.itemid = 50802 THEN 'base_excess'::text
            WHEN l.itemid = 50820 THEN 'pH'::text
            WHEN l.itemid = 51222 THEN 'hb'::text
            WHEN l.itemid = 51221 THEN 'hct'::text
            WHEN l.itemid = 50912 THEN 'creatinin'::text
            ELSE NULL::text
        END AS item
   FROM labevents l
   	 -- Joining now the labevents bevor the extubation. The highest charttime is closest to the extubation
    JOIN ( SELECT last_events.hadm_id,
            last_events.icustay_id,
            last_events.itemid,
            max(last_events.charttime) AS ts
           FROM ( SELECT l2.hadm_id,
                    l2.itemid,
                    min_ts.icustay_id,
                    l2.charttime,
                    l2.value
                   FROM labevents l2
                   -- Join the timestamp with the first extubation, by filtering the labevent.charttime less then 
                   -- timestamp of the extubation. We want the labevents bevor the extubation
                   JOIN ( SELECT vte.hadm_id,
                            vte.icustay_id,
                            min(vte.charttime) AS ext_ts
                           FROM vw_timestamp_extubation vte
                          GROUP BY vte.hadm_id, vte.icustay_id) min_ts ON min_ts.hadm_id = l2.hadm_id AND min_ts.ext_ts > l2.charttime
                  WHERE l2.itemid = ANY (ARRAY[50821, 50802, 50820, 51222, 51221, 50912])) last_events
          GROUP BY last_events.hadm_id, last_events.icustay_id, last_events.itemid) last_val ON last_val.hadm_id = l.hadm_id AND last_val.itemid = l.itemid AND last_val.ts = l.charttime
  ORDER BY l.hadm_id, last_val.icustay_id, l.itemid
  );
  