/*
 * The table Chart Events filters as before for the required HADM_ID's, ITEMID's and the columns. 
 * Additionally we map the ITEMID's into readable entries. We save the result as a view
 * Adding weight
 */
create or replace view vw_ce_filtered_new1 as
select ce.icustay_id,
	case 
	    when ce.itemid in (211, 220045) then 'hr' 
	    when ce.itemid in (52, 456, 225312, 220181, 220052) then 'blood_pr'
	    when ce.itemid in (646, 834, 220277, 220227) then 'SaO2'
	    when ce.itemid in (189, 190, 3420, 3422, 223835) then 'FiO2'
	    when ce.itemid in (1127, 861, 1542, 220546) then 'leuko'
	end as item,
	ce.charttime,
	ce.value,
	ce.hours_bevor_ext
from (
		SELECT c.itemid,
			c.icustay_id,
			c.charttime,
			c.value,
			round((date_part('epoch', min_ts.ext_ts - c.charttime) / 3600)::numeric,2) as hours_bevor_ext
		FROM chartevents c
		-- Join the timestamp with the first extubation, by filtering the labevent.charttime less then 
		-- timestamp of the extubation. We want the labevents bevor the extubation
		JOIN ( SELECT vte.icustay_id,
		            min(vte.charttime) AS ext_ts
		           FROM vw_timestamp_extubation vte
		          GROUP BY vte.hadm_id, vte.icustay_id) min_ts ON min_ts.icustay_id = c.icustay_id AND min_ts.ext_ts > c.charttime
		WHERE c.itemid = ANY (ARRAY[211, 220045,
					52, 456, 225312, 220181, 220052,
					646, 834, 220277, 220227,
					189, 190, 3420, 3422, 223835,
					1127, 861, 1542, 220546])) ce
where ce.hours_bevor_ext < 48
order by ce.icustay_id, ce.itemid, ce.charttime;