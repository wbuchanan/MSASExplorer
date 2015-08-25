/* Script to clean up MSAS Results Sets and build a single file to be pushed to
MSAS Explorer. */

cd ~/Desktop/acctTesting/final

use distgrades, clear
tempfile dist
drop if inlist(distid, "1420", "2560", "2561") | keep == 0 | mi(distnm)
rename (distid distnm)(ddistid ddistnm)
// clean up addresses
//foreach v of var diststreet1 distcity diststate distzip {

//	qui: replace `v' = itrim(`v')
//	qui: replace `v' = subinstr(`v', " ", "+", .)
	
//}

//qui: g addressstr = diststreet1 + ",+" + distcity + ",+" + diststate + ",+" + distzip

//geocode3, address(addressstr) quality

rename dist* sch*
drop keep group  *street* *city *state *zip* *phone ///   
hg12 *_l25d grolrla raw_* cohort* esflag *text 
rename (ddistid ddistnm)(distid distnm)
rename ddropgrade sdropgrade
rename *dl25 *sl25
rename *dend *dens
rename *numd *nums
qui: g distsch = "District"
save `dist'.dta, replace

use allgrades.dta, clear
rename (distid distnm)( ddistid ddistnm)
drop if mi(schnm) | inlist(ddistid, "1420", "2560", "2561") | ///  
keep == 0 | inlist(sch, "200", "500") | mi(ddistnm)

//qui: tostring schzip, format(%05.0f) replace

// clean up addresses
//foreach v of var schstreet1 schcity schstate schzip {

//	qui: replace `v' = itrim(`v')
//	qui: replace `v' = subinstr(`v', " ", "+", .)
	
//}

//qui: g addressstr = schstreet1 + ",+" + schcity + ",+" + schstate + ",+" + schzip

//geocode3, address(addressstr) quality

drop dist* keep group *street* *city *state *zip* *phone ///   
schlow25 grolrla raw_* cohort* *text hasgrow needgrow hasprof needprof 		 ///   
demostatus schdaperf1 *numd *dend *_l25d *dl25 mastermrg 		 ///   
 sch_sname 
rename (ddistid ddistnm)(distid distnm)
rename (pnumrlas pdenrlas pnummths pdenmths pnumscis pdenscis pnumhiss pdenhiss) ///  
(schprorlanum schprorladen schpromthnum schpromthden schproscinum			 ///   
schprosciden schprohisnum schprohisden) 
tempfile sch
qui: g distsch = "School"
save `sch'.dta, replace
append using `dist'.dta
sort schid
replace schnm = "District" if sch == "001" & mi(schnm)
drop if mi(schid) | mi(distnm) | distid == "0000"
la drop _merge 

la def colors 	1 "0-20 %ile" 2 "21-40 %ile" 3 "41-60 %ile" 4 "61-80 %ile"	 ///   
				5 "80-100 %ile", modify
				
la def grtyp 1 "Has 12th Grade" 2 "Has Science" 3 "No Gr. 12 or Science" 	 ///   
			 4 "No Tested Grades", modify
			 
la def dalabel .e "NA", modify

la copy dalabel dalabels, replace
				
la def sdropgrade 1 "< 95% Tested" 0 ">= 95% Tested", modify
la copy sdropgrade ddropgrade, replace

foreach v of var schwaivedgrade schnowaivegrade schpriorgrade {

		qui: replace `v' = cond(`v' == "A", "1", cond(`v' == "B", "2", 		 ///   
		cond(`v' == "C", "3", cond(`v' == "D", "4", cond(`v' == "F", "5", ""))))) 
		qui: destring `v', replace
		la val `v' grades
		
}

foreach v of var schdalabel1 schgrtyp schoverallrla schoverallmth			 ///   
schoveralloth schmetallamos schwaivedgrade schnowaivegrade schpriorgrade	 ///   
schdalabel schgrade *_q sdropgrade {

	decode `v', gen(`v'2)
	
	loc lab : var l `v'
	
	la var `v'2 `"`lab'"'
	
	qui: drop `v'
	
	rename `v'2 `v'
	
}

la drop _all


ds, not(type string)
foreach v in `r(varlist)' {

	qui: replace `v' = round(`v', .1)
	format `v' %09.0g
	qui: replace `v' = . if inlist(`v', .n, .z)
	
}

order schid distnm schnm schwaivedgrade schpriorgrade schgrade schtotpts 	 ///   
schprorla schpromth schprosci schprohis schgrorla schgromth schgrolrla  	 ///   
schgrolmth schgrad schpartic dropout stillenr completer schtotpts_rank 		 ///   
schprorla_rank schpromth_rank schprosci_rank schprohis_rank schgrorla_rank   ///   
schgromth_rank schgrolrla_rank schgrolmth_rank schgrad_rank schpartic_rank 	 ///   
schtotpts_q schprorla_q schpromth_q schprosci_q schprohis_q schgrorla_q 	 ///   
schgromth_q schgrolrla_q schgrolmth_q schgrad_q schpartic_q title1 			 ///
targetedtitle1 qdi schdalabel1  schoverallrla schoverallmth schoveralloth 	 ///   
schmetallamos schnowaivegrade schdalabel schgrade sdropgrade schgrtyp

la var schprorla "Reading Proficiency Points" 
la var schpromth "Math Proficiency Points"  
la var schprosci "Science Proficiency Points"  
la var schprohis "US History Proficiency Points"  
la var schgrorla "Reading Growth All Points"  
la var schgromth "Math Growth All Points"  
la var schgrolrla "Reading Growth Low 25% Points"  
la var schgrolmth "Math Growth Low 25% Points"  
la var schprorla_rank "Reading Proficiency Percentile"  
la var schpromth_rank "Math Proficiency Percentile"  
la var schprosci_rank "Science Proficiency Percentile"  
la var schprohis_rank "US History Proficiency Percentile"  
la var schgrorla_rank "Reading Growth All Percentile"  
la var schgromth_rank "Math Growth All Percentile"  
la var schgrolrla_rank "Reading Growth Low 25% Percentile"  
la var schgrolmth_rank "Math Growth Low 25% Percentile"  
la var schprorla_q "Reading Proficiency Quintiles"  
la var schpromth_q "Math Proficiency Quintiles"  
la var schprosci_q "Science Proficiency Quintiles"  
la var schprohis_q "US History Proficiency Quintiles"  
la var schgrorla_q "Reading Growth All Quintiles"  
la var schgromth_q "Math Growth All Quintiles"  
la var schgrolrla_q "Reading Growth Low 25% Quintiles"  
la var schgrolmth_q "Math Growth Low 25% Quintiles" 
la var schid "School ID"
la var distnm "District Name"
la var schnm "School Name"
la var schgrtyp "Grade Configuration/Scale"
la var schwaivedgrade "Grade w/ESEA Flexibility Waiver"
la var schgrad "Graduation Rate Points"
la var schtotpts "Total Points"
la var schpartic "Participation Rate"
la var schgrad_q "Graduation Rate Quintile"
la var schtotpts_q "Total Points Quintile"
la var schpartic_q "Participation Rate Quintile"
la var schgrad_rank "Graduation Rate Points Percentile"
la var schtotpts_rank "Total Points Percentile"
la var schpartic_rank "Participation Rate Percentile"
la var dropout "Dropout Rate"
la var stillenr "Still Enrolled Rate"
la var completer "Completion Rate"
la var title1 "Title I Indicator" 
la var targetedtitle1 "Targetted Title I Indicator" 
la var qdi "2012-13 QDI"
la var schdalabel1 "2012-13 DA Label"
la var schpriorgrade "2012-13 Grade"
la var schoverallrla "Met Reading AMOs"
la var schoverallmth "Met Math AMOs"
la var schoveralloth "Met Other AMOs"
la var schmetallamos "Met All AMOs"
la var schdalabel "Current DA Label"
la var sdropgrade "Participation Rate Flag"
la var distid "District ID"
la var sch "School Number"
la var ncesid "NCES School ID"
la var schprorlanum "Reading Proficiency Numerator"
la var schprorladen "Reading Proficiency Denominator" 
la var es1rlanum "Backmapped RLA Pr. Numerator 1"
la var es1rladen "Backmapped RLA Pr. Denominator 1"
la var schbankrlanum "Banked RLA Pr. Numerator"
la var schbankrladen "Banked RLA Pr. Denominator"
la var es2rlanum "Backmapped RLA Pr. Numerator 2"
la var es2rladen "Backmapped RLA Pr. Denominator 2"
la var schpromthnum "Math Proficiency Numerator"
la var schpromthden "Math Proficiency Denominator"
la var es1mthnum "Backmapped Math Pr. Numerator 1"
la var es1mthden "Backmapped Math Pr. Denominator 1"
la var schbankmthnum "Banked Math Pr. Numerator"
la var schbankmthden "Banked Math Pr. Denominator"
la var es2mthnum "Backmapped Math Pr. Numerator 2"
la var es2mthden "Backmapped Math Pr. Denominator 2"
la var schproscinum "Science Proficiency Numerator"
la var schprosciden "Science Proficiency Denominator"
la var schbankscinum "Banked Science Pr. Numerator"
la var schbanksciden "Banked Science Pr. Denominator"
la var schprohisnum "US History Proficiency Numerator"
la var schprohisden "US History Proficiency Denominator"
la var schbankhisnum "Banked US History Pr. Numerator"
la var schbankhisden "Banked US History Pr. Denominator"
la var metrlanums "Combined Reading Growth Numerator"
la var metrladens "Combined Reading Growth Denominator" 
la var metmthnums "Combined Math Growth Numerator" 
la var metmthdens "Combined Math Growth Denominator" 
la var es3rlanum "Backmapped RLA Growth All Numerator 3"
la var es3mthnum "Backmapped Math Growth All Numerator 3"
la var es3rladen "Backmapped RLA Growth All Denominator 3"
la var es3mthden "Backmapped Math Growth All Denominator 3"
la var hsrlanum "Banked RLA Growth All Numerator"
la var hsrladen "Banked RLA Growth All Denominator"
la var hsmthnum "Banked Math Growth All Numerator"
la var hsmthden "Banked Math Growth All Denominator"
la var regrlanum "Current RLA Growth All Numerator"
la var regrladen "Current RLA Growth All Denominator"
la var regmthnum "Current Math Growth All Numerator"
la var regmthden "Current Math Growth All Denominator"
la var metrlanumsl25 "RLA Growth Low 25% Numerator"
la var metrladensl25 "RLA Growth Low 25% Numerator"
la var metmthnumsl25 "Math Growth Low 25% Numerator"
la var metmthdensl25 "Math Growth Low 25% Numerator"
la var es1rlanumsl25 "Backmapped RLA Growth Low 25% Numerator 1"
la var es1mthnumsl25 "Backmapped Math Growth Low 25% Numerator 1"
la var es2rlanumsl25 "Backmapped RLA Growth Low 25% Numerator 2"
la var es2mthnumsl25 "Backmapped Math Growth Low 25% Numerator 2"
la var es3rlanumsl25 "Backmapped RLA Growth Low 25% Numerator 3"
la var es3mthnumsl25 "Backmapped Math Growth Low 25% Numerator 3"
la var es1rladensl25 "Backmapped RLA Growth Low 25% Denominator 1"
la var es1mthdensl25 "Backmapped Math Growth Low 25% Denominator 1"
la var es2rladensl25 "Backmapped RLA Growth Low 25% Denominator 2"
la var es2mthdensl25 "Backmapped Math Growth Low 25% Denominator 2"
la var es3rladensl25 "Backmapped RLA Growth Low 25% Denominator 3"
la var es3mthdensl25 "Backmapped Math Growth Low 25% Denominator 3"
la var regrlanums "Current RLA Growth Low 25% Numerator"
la var regrladens "Current RLA Growth Low 25% Denominator"
la var regmthnums "Current Math Growth Low 25% Numerator"
la var regmthdens "Current Math Growth Low 25% Denominator"
la var schpartrlanum "RLA Participation Numerator"
la var schpartrladen "RLA Participation Denominator"
la var schpartmthnum "Math Participation Numerator"
la var schpartmthden "Math Participation Denominator"
la var schpartscinum "Science Participation Numerator"
la var schpartsciden "Science Participation Denominator"
la var schpartnum "Participation Rate Numerator"
la var schpartden "Participation Rate Denominator"
la var schrlapartic "Reading Participation Rate"
la var schmthpartic "Math Participation Rate"
la var schscipartic "Science Participation Rate"
la var schyr "Academic Year Beginning"
la var denominator "Cohort Denominator"
la var dropout_n "Dropout Numerator"
la var stillenr_n "Still Enrolled Numerator"
la var completer_n "Completer Numerator"
la var graduate_n "Graduates Numerator"
la var graduate "Graduation Rate w/o Weighting"
la var nceslea "NCES District ID"
la var distsch "School/District Indicator"
//la var addressstr "Address string used for Google Geocoding API" 
//la var g_lat "Latitude from Google Geocoding API"
//la var g_lon "Longitude from Google Geocoding API"
//la var g_status "Google Geocoding API Status Message"
//la var g_quality "Degree of Accuracy from Google Geocoding API"
//la var g_partial "Partial Address String Match from Google Geocoding API"

// Save the file to load into the explorer application
saveold ~/Desktop/Shiny/accountability/data/msasexplorer.dta, replace

log using ~/Desktop/Shiny/accountability/data/fullCodebook.txt, text replace
desc
log c _all


// Get/ build the AMO files
use schid_amoresults.dta, clear
merge m:1 schid using finschoollist.dta, keepus(schnm distnm distid sch keep) 
drop if _merge == 2 | keep == 0 | inlist(distid, "0000", "1420", "2560", "2561") | ///   
inlist(sch, "200", "500")
drop _merge keep

// Apply variable labels
la var rlapctgr `"RLA Proficiency Index"'
la var mthpctgr `"Math Proficiency Index"'
la var rladengr `"RLA Proficiency Index Denominator"'
la var mthdengr `"Math Proficiency Index Denominator"'
la var rlagoalgr `"RLA AMO Goal"'
la var mthgoalgr `"Math AMO Goal"'
la var metrlagr `"RLA Performance AMO Goal Indicator"'
la var metmthgr `"Math Performance AMO Goal Indicator"'
la var rlapartgr `"RLA Participation Rate"'
la var mthpartgr `"Math Participation Rate"'
la var rlapartlabgr `"RLA Participation Rate Indicator"'
la var mthpartlabgr `"Math Participation Rate Indicator"'
la var amorlagr `"Met RLA Subgroup AMO Goal"'
la var amomthgr `"Met Math Subgroup AMO Goal"'
la var overallrla `"Met All RLA AMO Goals"'
la var overallmth `"Met All Math AMO Goals"'

// Apply sample size masking
foreach v of var rladengr mthdengr rlapctgr mthpctgr rlagoalgr mthgoalgr ///   
metrlagr metmthgr rlapartgr mthpartgr { 

	la def `v' .n "< 10" .z "N/A", modify

	la val `v' `v'
	
	format `v' %05.0g
	
}
drop if mi(rladengr) & mi(mthdengr)
format %05.0g mthpartgr rlapartgr
tempfile schamo
save `schamo'.dta, replace


use distid_amoresults.dta, clear
merge m:1 distid using districtList.dta, keepus(distnm keep) 
drop if _merge == 2 | keep == 0 | inlist(distid, "1420", "2560", "2561") 
g sch = "001"
g schid = distid + "-" + sch
g schnm = "District"
drop _merge keep

// Apply variable labels
la var rlapctgr `"RLA Proficiency Index"'
la var mthpctgr `"Math Proficiency Index"'
la var rladengr `"RLA Proficiency Index Denominator"'
la var mthdengr `"Math Proficiency Index Denominator"'
la var rlagoalgr `"RLA AMO Goal"'
la var mthgoalgr `"Math AMO Goal"'
la var metrlagr `"RLA Performance AMO Goal Indicator"'
la var metmthgr `"Math Performance AMO Goal Indicator"'
la var rlapartgr `"RLA Participation Rate"'
la var mthpartgr `"Math Participation Rate"'
la var rlapartlabgr `"RLA Participation Rate Indicator"'
la var mthpartlabgr `"Math Participation Rate Indicator"'
la var amorlagr `"Met RLA Subgroup AMO Goal"'
la var amomthgr `"Met Math Subgroup AMO Goal"'
la var overallrla `"Met All RLA AMO Goals"'
la var overallmth `"Met All Math AMO Goals"'
drop if mi(rladengr) & mi(mthdengr)
append using `schamo'.dta
la drop _all
la def yn 0 "N" 1 "Y"
recode rlapartlabgr (1 2 3 = 1)
recode mthpartlabgr (1 2 3 = 1)

// make all missing values consistent
foreach v of var rladengr mthdengr rlapctgr mthpctgr rlagoalgr mthgoalgr ///   
metrlagr metmthgr rlapartgr mthpartgr { 

	qui: replace `v' = . if mi(`v')
		
}

// apply value labels for binary indicators
foreach v of var metrlagr metmthgr rlapartlabgr mthpartlabgr overallrla ///   
overallmth {

	la val `v' yn
	decode `v', gen(`v'2)
	la var `v'2 `"`:var label `v''"'
	drop `v'
	rename `v'2 `v'
	
}

// Define the value labels
	la def group 	1 "All Students" 2 "Asian" 3 "Black or African American" ///   
					4 "Hispanic or Latino" 5 "Two or More Races"			 ///   
					6 "American Indian or Alaskan Native"					 ///   
					7 "Native Hawaiian or Pacific Islander"					 ///
					8 "White" 9 "Female" 10 "Male"							 /// 
					11 "Economically Disadvantaged"							 ///
					12 "Limited English Proficiency"							 ///
					13 "Students w/Disabilities", modify
					
// Apply subgroup ID labels 
la val group group

order distid schid sch distnm schnm group  rladengr rlapctgr rlagoalgr		 ///  
metrlagr rlapartgr rlapartlabgr amorlagr overallrla mthdengr mthpctgr		 ///   
mthgoalgr metmthgr mthpartgr mthpartlabgr amomthgr overallmth

la var distid "District ID"
la var schid "School ID"
la var sch "School Number"
la var distnm "District Name"
la var schnm "School Name"

decode group, gen(group2)
la var group2 `"`: var label group'"'
drop group
rename group2 group
format %05.0g mthpartgr rlapartgr
order schid distnm schnm group rladengr rlapctgr rlagoalgr rlapartgr ///   
rlapartlabgr amorlagr overallrla mthdengr mthpctgr mthgoalgr metmthgr ///   
mthpartgr mthpartlabgr amomthgr overallmth

saveold ~/Desktop/Shiny/accountability/data/msasexplorer-amos.dta, replace


// Get and build the growth files
use schgro_Combined.dta, clear
merge m:1 schid using finschoollist.dta, keepus(schnm distnm keep) 
drop if _merge == 2 | keep == 0 | inlist(distid, "1420", "2560", "2561") | ///   
inlist(sch, "200", "500")
drop _merge keep
rename *_reg *
drop if mi(metmthdens) & mi(metrladens)
drop timestamp schyr ed sped lep race female
order distid schid sch distnm schnm group metmthdens metmthnums schgromth ///   
metrladens metrlanums schgrorla 
tempfile schgro
save `schgro'.dta, replace

use distgro_Combined.dta, clear
merge m:1 distid using districtList.dta, keepus(distnm keep) 
drop if _merge == 2 | keep == 0 | inlist(distid, "1420", "2560", "2561") 
g schnm = "District"
drop _merge keep
rename *numd *nums
rename *dend *dens
rename distgro* schgro*
drop if mi(metmthdens) & mi(metrladens)
drop timestamp schyr ed sped lep race female
order distid schid sch distnm schnm group metmthdens metmthnums schgromth ///   
metrladens metrlanums schgrorla 
tempfile distgro
append using `schgro'.dta
sort schid
save `distgro'.dta, replace

use stategro_Combined.dta, clear
foreach v in ed female lep race sped {
	append using stategro_`v'.dta
}
rename *numst *nums
rename *denst *dens
rename stategro* schgro*
drop timestamp schyr ed sped lep race female
g distnm = "Mississippi"
g schnm = "State"
order distid schid sch distnm schnm group metmthdens metmthnums schgromth ///   
metrladens metrlanums schgrorla 
append using `distgro'.dta
qui: replace metmthnums = . if inlist(metmthdens, 0, ., .n, .z) | ///   
inrange(metmthdens, 0, 9)
qui: replace schgromth = . if inlist(metmthdens, 0, ., .n, .z) | ///   
inrange(metmthdens, 0, 9)
qui: replace metmthdens = . if inlist(metmthdens, 0, ., .n, .z) | ///   
inrange(metmthdens, 0, 9)
qui: replace metrlanums = . if inlist(metrladens, 0, ., .n, .z) | ///   
inrange(metrladens, 0, 9)
qui: replace schgrorla = . if inlist(metrladens, 0, ., .n, .z) | ///   
inrange(metrladens, 0, 9)
qui: replace metrladens = . if inlist(metrladens, 0, ., .n, .z) | ///   
inrange(metrladens, 0, 9)
drop if mi(metmthdens) & mi(metrladens)
la var distid "District ID"
la var schid "Schoold ID"
la var sch "School Number"
la var distnm "District Name"
la var schnm "School Name"
la var group "AMO Subgroup"
la var metmthdens "Math Growth Denominator"
la var metmthnums "Math Growth Numerator"
la var schgromth "Math Growth"
la var metrladens "Reading Growth Denominator"
la var metrlanums "Reading Growth Numerator"
la var schgrorla "Reading Growth"
format %09.0g metmthdens metmthnums schgromth metrladens metrlanums schgrorla
saveold  ~/Desktop/Shiny/accountability/data/msasgrowth.dta, replace


// Get and assemble growth of the low25 % files
use schgro_l25_Combined.dta, clear
merge m:1 schid using finschoollist.dta, keepus(schnm distnm keep) 
drop if _merge == 2 | keep == 0 | inlist(distid, "1420", "2560", "2561") | ///   
inlist(sch, "200", "500")
drop _merge keep mth_l25sch timestamp schyr rla_l25sch ed sped lep race female
rename *_reg *
order distid schid sch distnm schnm group schlow25 metmthdensl25 			 ///
metmthnumsl25 schgrolmth metrladensl25 metrlanumsl25 schgrolrla 
tempfile schgrol25
save `schgrol25'.dta, replace

use distgro_l25_Combined.dta, clear
merge m:1 distid using districtList.dta, keepus(distnm keep) 
drop if _merge == 2 | keep == 0 | inlist(distid, "1420", "2560", "2561") 
g schnm = "District"
drop _merge keep mth_l25d timestamp schyr rla_l25d ed sped lep race female
rename *dl25 *sl25
rename (distlow25 distgrolrla distgrolmth)(schlow25 schgrolrla schgrolmth)
order distid schid sch distnm schnm group schlow25 metmthdensl25 			 ///
metmthnumsl25 schgrolmth metrladensl25 metrlanumsl25 schgrolrla 
append using `schgrol25'.dta
sort schid
tempfile distgrol25
save `distgrol25'.dta, replace

use stategro_l25_Combined.dta, clear
foreach v in ed female lep race sped {
	append using stategro_l25_`v'.dta
}
rename *numstl25 *numsl25
rename *denstl25 *densl25
rename stategrol* schgrol*
rename statelow25 schlow25
drop timestamp schyr ed sped lep race female *_l25st
g distnm = "Mississippi"
g schnm = "State"
order distid schid sch distnm schnm group schlow25 metmthdensl25 			 ///   
metmthnumsl25 schgrolmth metrladensl25 metrlanumsl25 schgrolrla 
append using `distgrol25'.dta
qui: replace metmthnumsl25 = . if inlist(metmthdensl25, 0, ., .n, .z) | ///   
inrange(metmthdensl25, 0, 9)
qui: replace schgrolmth = . if inlist(metmthdensl25, 0, ., .n, .z) | ///   
inrange(metmthdensl25, 0, 9)
qui: replace metmthdensl25 = . if inlist(metmthdensl25, 0, ., .n, .z) | ///   
inrange(metmthdensl25, 0, 9)
qui: replace metrlanumsl25 = . if inlist(metrladensl25, 0, ., .n, .z) | ///   
inrange(metrladensl25, 0, 9)
qui: replace schgrolrla = . if inlist(metrladensl25, 0, ., .n, .z) | ///   
inrange(metrladensl25, 0, 9)
qui: replace metrladensl25 = . if inlist(metrladensl25, 0, ., .n, .z) | ///   
inrange(metrladensl25, 0, 9)
drop if mi(metmthdensl25) & mi(metrladensl25)
la def schlow25 0 "Not in the Lowest 25%" 1 "In the Lowest 25%", modify
la val schlow25 schlow25
la var distid "District ID"
la var schid "Schoold ID"
la var sch "School Number"
la var distnm "District Name"
la var schnm "School Name"
la var group "AMO Subgroup"
la var schlow25 "Low 25% Group Indicator"
la var metmthdensl25 "Math Growth Denominator"
la var metmthnumsl25 "Math Growth Numerator"
la var schgrolmth "Math Growth"
la var metrladensl25 "Reading Growth Denominator"
la var metrlanumsl25 "Reading Growth Numerator"
la var schgrolrla "Reading Growth"
format %09.0g metmthdensl25 metmthnumsl25 schgrolmth metrladensl25			 ///   
metrlanumsl25 schgrolrla
replace group = subinstr(group, " and In District Low 25% in Math", "", .)
replace group = subinstr(group, " and Not in District Low 25% in Math", "", .)
replace group = subinstr(group, " and Not in School Low 25% in Math", "", .)
replace group = subinstr(group, " and In School Low 25% in Math", "", .)
replace group = subinstr(group, " and In State Low 25% in Math", "", .)
replace group = subinstr(group, " and Not in State Low 25% in Math", "", .)
replace group = subinstr(group, " and Not in School Low 25% in RLA", "", .)
replace group = subinstr(group, " and In School Low 25% in RLA", "", .)
replace group = subinstr(group, " and Not in District Low 25% in RLA", "", .)
replace group = subinstr(group, " and In District Low 25% in RLA", "", .)
replace group = subinstr(group, " and Not in State Low 25% in RLA", "", .)
replace group = subinstr(group, " and In State Low 25% in RLA", "", .)
compress

saveold  ~/Desktop/Shiny/accountability/data/msasgrowthlow25.dta, replace



