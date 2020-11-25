/*
 * The table Chart Events filters as before for the required HADM_ID's, ITEMID's and the columns. 
 * Additionally we map the ITEMID's into readable entries. We save the result as a view
 */
create or replace view vw_ce_filtered as
SELECT c.hadm_id, c.icustay_id, c.itemid, c.charttime,
    c.value, c.valuenum, c.valueuom,
    case 
		when c.itemid in (211, 220045) then 'hr' 
		when c.itemid in (52, 456, 225312, 220181, 220052) then 'blood_pr'
		when c.itemid in (676,  677, 223762) then 'temp'
		when c.itemid in (646, 834, 220277, 220227) then 'SaO2'
		when c.itemid in (618 ,  220210 , 224688) then 'resp_rat'
		when c.itemid in (445, 448, 449, 224687, 1340, 1486, 1600) then 'breath_min_vol'
		when c.itemid in (189, 190, 3420, 3422, 223835) then 'FiO2'
		when c.itemid in (681, 682, 683, 684, 224685, 224684, 224686) then 'tidal_vol'
		when c.itemid in (444, 224697) then 'mean_insp_pressure'
		when c.itemid in (506, 220339) then 'PEEP'
		when c.itemid in (1127, 861, 1542, 220546) then 'leuko'
		when c.itemid in (225668, 1531, 818) then 'lactic_acid'
	end as item,
	c.storetime, c.cgid, c.warning , c.error , c.resultstatus , c.stopped 
   FROM chartevents c
  WHERE (c.hadm_id IN (SELECT hadm_overview.hadm_id FROM hadm_overview))
 	and c.itemid in (211, 220045,
					52, 456, 225312, 220181, 220052,
					676,  677, 223762,
					646, 834, 220277, 220227,
					618 ,  220210 , 224688,
					445, 448, 449, 224687, 1340, 1486, 1600,
					189, 190, 3420, 3422, 223835,
					681, 682, 683, 684, 224685, 224684, 224686,
					444, 224697,
					506, 220339,
					1127, 861, 1542, 220546,
					225668, 1531, 818);
