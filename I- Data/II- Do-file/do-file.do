/*
====================================================================
Project : STEPS BENIN 2023
Purpose: Data Cleaning
Name: Wadoudou MAKPENON
Organization: LEADD
Email: makpenonw@gmail.com
====================================================================
*/

clear all
	set more off
	capture log close
	
	global path "C:\Users\Wadoudou\Dropbox\STEPS\STEPS-PHASE 2\1- Nettoyage des données"
	
	global data "$path\I- Data"
	global iden "$data\1- Deidentified"
	global int "$data\2- Intermediate"
	global final "$data\3- Final"
	global dofile "$path\II- Do-file"
	global doc "$path\III- Documentation"
	
    cap mkdir "$data"
	cap mkdir "$iden"
	cap mkdir "$int"
	cap mkdir "$final"
	cap mkdir "$dofile"
	cap mkdir "$doc"
  
* Import Step 3 data base

import excel using "$iden\steps3.xlsx", firstrow clear
drop instanceID - _xform_id
rename QR3 QR
 drop if QR==""
duplicates report QR
save "$int\steps3", replace


* Import Step Lab data base
import excel using "$iden\steps_lab.xlsx", firstrow clear
ren QR_lab QR
duplicates report QR
drop instanceID - _xform_id
save "$int\steps_lab", replace

* Merge Steps 3 and Steps lab
use "$int\steps3", clear
merge 1:1 QR using "$int\steps_lab"
export excel QR  using "$doc\Code_QR.xlsx" if _merge==2 , sheet("QRStepsLab-no-QRSteps3", replace)  firstrow(variables)


* Import Step 1
import excel using "$iden\steps1.xlsx", firstrow clear
rename QR1 QR
drop if QR==""
duplicates report QR
drop instanceID - _xform_id
save "$int\steps1", replace 

* Merge Steps 1-2 and Steps 3
use "$int\steps1", clear
merge 1:1 QR using "$int\steps3"
export excel QR  using "$doc\Code_QR.xlsx" if _merge==2 , sheet("QRSteps3-no-QRSteps1", replace)  firstrow(variables)

* Merge Steps 1-2 and Steps Lab
use "$int\steps1", clear
merge 1:1 QR using "$int\steps_lab"
export excel QR  using "$doc\Code_QR.xlsx" if _merge==2 , sheet("QRStepsLab-no-QRSteps1", replace)  firstrow(variables)


* Check the name of QR STEPS 3 that wasn't found in STEPS 1.
*keep if I8=="SEB0" | I8=="HARIROU" | I8=="M'PO" | I8=="KOUAGOU" | I8=="KOBA"

* Merge steps 1-2 and 3
use "$int\steps1", clear
merge 1:1 QR using "$int\steps3"
tab _merge

* Delete the 5 code QR of Steps 3 that wasn't found in Steps 1
drop if _merge==2
drop _merge
save "$int\steps1-2-3", replace
* * Merge steps 1-2; 3 and lab
use "$int\steps1-2-3", clear
merge 1:1 QR using "$int\steps_lab"
* Delete the 10 code QR of Steps Lab that wasn't found in Steps 1
drop if _merge==2
drop _merge

order geopoint _geopoint_latitude _geopoint_longitude _geopoint_altitude _geopoint_precision, after( X9)

* Drop the identification variables
drop I8 I8_3 I9 I9_3

save "$final/STEPS_BENIN2023", replace

* Create urban/rural variables
import excel using "$iden\milieu.xlsx", firstrow clear
rename QR1 QR
drop if QR==""
duplicates report QR
save "$int\milieu", replace 

split ZD, gen(parts) parse(" ")
gen milieu = "Rural" if parts5 =="(R)"
replace milieu = "Urban" if parts5 =="(U)"
replace milieu = "Urban" if parts6 =="(U)"
replace milieu = "Urban" if parts7 =="(U)"
replace milieu = "Rural" if parts6 =="(R)"
replace milieu = "Rural" if parts7 =="(R)"
drop parts1 parts2 parts3 parts4 parts5 parts6 parts7 ZD
save "$int\milieu", replace 

use "$final/STEPS_BENIN2023", clear
merge 1:1 QR using "$int\milieu"
drop _merge
order milieu, after(I2b)

save "$final/STEPS_BENIN2023", replace

export excel using "$final\STEPS_BENIN2023.xlsx" , sheet("STEPS_BENIN2023", replace) firstrow(variables)







