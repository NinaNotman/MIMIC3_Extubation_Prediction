/*
 * From the 08_chartevents_filtered.sql result the value matching icustay_id, item and last_ts must now be determined.
 */
create table chartev_values as 
select distinct vcf.* --vcf.hadm_id, vcf.icustay_id, vcf.item, vcf.value, vcf.charttime 
from vw_ce_filtered vcf 
inner join (select distinct ce.icustay_id, ce.item, max(ce.charttime) as last_ts
			from vw_ce_filtered ce
			inner join (select hadm_id, icustay_id, min(charttime) as ext_ts
						from vw_timestamp_extubation vte
						group by hadm_id, icustay_id) min_ts 
				on (min_ts.icustay_id = ce.icustay_id and min_ts.ext_ts > ce.charttime)
			group by ce.icustay_id, ce.item) last_events
	on (last_events.icustay_id = vcf.icustay_id and last_events.item = vcf.item and last_events.last_ts = vcf.charttime)
order by vcf.hadm_id , vcf.icustay_id;