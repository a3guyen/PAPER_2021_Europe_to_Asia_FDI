clear
global mainpath "A:\AnhDropbox\01 PHD 2016\Data-main"
cd "C:\Users\ngoca\Dropbox\Pubs_since_2018\2019-Europe-Asia-FDI\1stRevision"
capture log close
log using Regression-all, replace


*================== Creat variables==================================
use Data-Europe-Asia-all, clear

*drop if subcontinent_h =="Central Asia"
drop if subcontinent_h =="Middle East & North Africa"
drop if CountryName_s == "Armenia"


* Deflate FDI
gen lrstock = ln(stock/dfus)
qui sum lrstock
scalar gamma = r(min)
display gamma
replace stock =. if stock <0 //174  changes
replace lrstock = gamma - 0.0000001 if stock ==0


* Log of the sum
gen lsumgdp = ln((rgdpus_s + rgdpus_h)*1000) 
sum *cost* // ok, no 0 value
gen linvestcost = ln(investcost)
gen ltradecost_s = ln(tradecost_s)
gen ltradecost_h = ln(tradecost_h)

gen ldist = ln(dist)
sum l*
gen similarity = ln(rgdpus_h*rgdpus_s/((rgdpus_s+rgdpus_h)^2))


save Data-Europe-Asia, replace

*======================== REgression==========================================

use Data-Europe-Asia, clear
 

global varlist lsumgdp similarity skill  linvestcost ltradecost_h ltradecost_s  bit  crex comlang colony ldist 


qui xtreg lrstock $varlist i.time, cluster(idp) 
sum $varlist if e(sample)==1
inspect stock if e(sample)==1 //641 zero, 2836 positive
 
// keep  if e(sample)==1 
// keep host CountryName_h *continent*
// duplicates drop

unique source if e(sample) ==1
unique host if e(sample)==1
vallist CountryName_s if e(sample) ==1
vallist CountryName_h if e(sample)==1
use Data-Europe-Asia, clear
global varlist lsumgdp similarity skill  linvestcost ltradecost_h ltradecost_s  bit  crex comlang colony ldist
sum $varlist

eststo clear
bysort subcontinent_h: eststo: xtreg lrstock $varlist i.time, cluster(idp) fe 

esttab using Results.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars drop (  *time*) noomitted nogaps title(Table: FE) compress replace

eststo clear

bysort subcontinent_h: eststo: reg lrstock $varlist i.time, cluster(idp)

esttab using Results.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars drop (  *time*) noomitted nogaps title(Table: Pooled OLS) compress append


eststo clear
bysort subcontinent_h: eststo: xtreg lrstock $varlist i.time, cluster(idp) 

esttab using Results.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars drop (  *time*) noomitted nogaps title(Table: RE) compress append



eststo clear
bysort subcontinent_h: eststo: xttobit lrstock $varlist i.time, ll() tobit 


esttab using Results.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars drop (  *time*) noomitted nogaps title(Table: RETobit) compress append


eststo clear
use Data-Europe-Asia, clear

keep if subcontinent_h == "ASEAN"
ppml rstock $varlist y*, cluster(idp) 
eststo reg1
qui predict  fit,xb
qui gen fit2 = fit^2
ppml stock $varlist y* fit2, cluster(idp) 
test fit2=0 //p-value =0/.7415

use Data-Europe-Asia, clear

keep if subcontinent_h == "East Asia "
ppml rstock $varlist y*, cluster(idp) 
eststo reg2
qui predict  fit,xb
qui gen fit2 = fit^2
ppml rstock $varlist y* fit2, cluster(idp) 
test fit2=0 //p-value =0/.3290


use Data-Europe-Asia, clear
keep if subcontinent_h == "South Asia"
ppml rstock $varlist y*, cluster(idp) 
eststo reg3
qui predict  fit,xb
qui gen fit2 = fit^2
ppml rstock $varlist y* fit2, cluster(idp) 
test fit2=0 //p-value =0/.4546


use Data-Europe-Asia, clear
keep if subcontinent_h == "Central Asia"
ppml rstock $varlist y*, cluster(idp) 
eststo reg4
qui predict  fit,xb
qui gen fit2 = fit^2
ppml rstock $varlist y* fit2, cluster(idp) 
test fit2=0 //p-value =0/.5769

esttab using Results.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars drop (  y*) noomitted nogaps title(Table: PPML) compress append





*======================== REgression= All ASIA =========================================
use Data-Europe-Asia, clear

tab subcontinent_h, gen(region)
global varlist lsumgdp similarity skill  linvestcost ltradecost_h ltradecost_s  bit  crex comlang colony ldist region2 region3 region4
eststo clear

reg lrstock $varlist i.time, cluster(idp)
eststo POLS
qui predict  fit,xb
qui gen fit2 = fit^2
reg lrstock $varlist i.time fit2, cluster(idp)
test fit2=0 //0.000
drop fit*


xtreg lrstock $varlist i.time, cluster(idp) fe 
eststo FE
qui predict  fit,xb
qui gen fit2 = fit^2
xtreg lrstock $varlist i.time fit2, cluster(idp) fe 
test fit2=0 //0.1789
drop fit*




xtreg lrstock $varlist i.time, cluster(idp) 
eststo RE
qui predict  fit,xb
qui gen fit2 = fit^2
xtreg lrstock $varlist i.time fit2, cluster(idp) 
test fit2=0 //0.0596
drop fit*


xttobit lrstock $varlist i.time, ll() tobit
eststo RETobit
qui predict  fit,xb
qui gen fit2 = fit^2
xttobit lrstock $varlist i.time fit2, ll() tobit
test fit2=0 //0.0002
drop fit*


ppml rstock $varlist y*, cluster(idp) 
eststo PPML
test region2 region3 region4
qui predict  fit,xb
qui gen fit2 = fit^2
qui ppml stock $varlist  y* fit2, cluster(idp) 
test fit2=0 //0.3837
drop fit*


esttab using Results.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars drop ( *time*  y*) noomitted nogaps title(Table: All Asia  stock) compress append



* 1st Revision requirements
*1/ Adding interaction variables: 
use Data-Europe-Asia, clear
tab subcontinent_h, gen(region)
global varlist lsumgdp similarity skill  linvestcost ltradecost_h ltradecost_s  bit  crex comlang colony ldist region2 region3 region4
eststo clear


gen SimilarityTrade =similarity *ltradecost_h
gen SkillTrade = skill*ltradecost_h
global varlist lsumgdp similarity skill  linvestcost ltradecost_h ltradecost_s SimilarityTrade SkillTrade  bit  crex comlang colony ldist region2 region3 region4

eststo clear

reg lrstock $varlist i.time, cluster(idp)
eststo POLS
qui predict  fit,xb
qui gen fit2 = fit^2
reg lrstock $varlist i.time fit2, cluster(idp)
test fit2=0 //0.000
drop fit*


xtreg lrstock $varlist i.time, cluster(idp) fe 
eststo FE
qui predict  fit,xb
qui gen fit2 = fit^2
xtreg lrstock $varlist i.time fit2, cluster(idp) fe 
test fit2=0 //0.1789
drop fit*




xtreg lrstock $varlist i.time, cluster(idp) 
eststo RE
qui predict  fit,xb
qui gen fit2 = fit^2
xtreg lrstock $varlist i.time fit2, cluster(idp) 
test fit2=0 //0.0596
drop fit*


xttobit lrstock $varlist i.time, ll() tobit
eststo RETobit
qui predict  fit,xb
qui gen fit2 = fit^2
xttobit lrstock $varlist i.time fit2, ll() tobit
test fit2=0 //0.0002
drop fit*


ppml rstock $varlist y*, cluster(idp) 
eststo PPML
test region2 region3 region4
qui predict  fit,xb
qui gen fit2 = fit^2
qui ppml stock $varlist  y* fit2, cluster(idp) 
test fit2=0 //0.3837
drop fit*


esttab using RevisedResults.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars noomitted nogaps title(Table: All Asia  stock, added vars) compress append


* Divide host countries into multi party system vs 1dominant party system (since all source countries are multi party)
import excel "C:\Users\ngoca\Dropbox\Pubs_since_2018\2019-Europe-Asia-FDI\1stRevision\Country-Systems.xlsx", sheet("Sheet4") firstrow clear
label var DominantParty_h "=1 if the country is ruled by 1 dominant party"
save DominantParty, replace

* Floating exchange system or not
import excel "C:\Users\ngoca\Dropbox\Pubs_since_2018\2019-Europe-Asia-FDI\1stRevision\Country-Systems.xlsx", sheet("Sheet2") firstrow clear
rename Floating Floating_h
label var Floating_h "=1 if the host country has a floating exchange rate regime"
save FloatingOrNot, replace


// use Data-Europe-Asia, clear
// drop if _merge==1
// drop _merge
// merge m:1 host using "DominantParty.dta", keepusing(DominantParty_h)
// vallist CountryName_h if _merge == 1
// tab subcontinent_h, gen(region)
// 
// use Data-Europe-Asia, clear
// merge m:1 host using "FloatingOrNot.dta", keepusing(Floating_h)
// drop if _merge==2
// drop _merge
//
// tab subcontinent_h, gen(region)
// save Data-Europe-Asia, replace

* Check for structural breaks
// drop if _merge==1
// keep Country* host source time stock rstock lrstock
//  export excel using "C:\Users\ngoca\Dropbox\Pubs_since_2018\2019-Europe-Asia-FDI\1stRevision\FDIdataforGraphs.xls", firstrow(variables) replace


use Data-Europe-Asia, clear

global varlist lsumgdp similarity skill  linvestcost ltradecost_h ltradecost_s  bit  crex comlang colony ldist region2 region3 region4
eststo clear

keep if DominantParty_h==1
ppml rstock $varlist y*, cluster(idp) 
eststo Dominant
use Data-Europe-Asia, clear
keep if DominantParty_h==0
ppml rstock $varlist y*, cluster(idp) 
eststo NoDominant

use Data-Europe-Asia, clear
keep if Floating_h==1
ppml rstock $varlist y*, cluster(idp) 
eststo Floating
use Data-Europe-Asia, clear
keep if Floating_h==0
ppml rstock $varlist y*, cluster(idp) 
eststo NotFloating

use Data-Europe-Asia, clear
keep if euro==1
ppml rstock $varlist y*, cluster(idp) 
eststo Eurozone

use Data-Europe-Asia, clear
keep if euro==0
ppml rstock $varlist y*, cluster(idp) 
eststo NotEurzone

esttab using RevisedResults.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars noomitted nogaps title(Table: Dominat vs NoDominat PArty) compress append


* Divide the sample into 3 group: 1995-1997, 1998-2003, 2004-2008, 2009-2013
use Data-Europe-Asia, clear

global varlist lsumgdp similarity skill  linvestcost ltradecost_h ltradecost_s  bit  crex comlang colony ldist region2 region3 region4
eststo clear

keep if DominantParty_h==1
ppml rstock $varlist y*, cluster(idp) 
eststo Dominant
use Data-Europe-Asia, clear
keep if DominantParty_h==0
ppml rstock $varlist y*, cluster(idp) 
eststo NoDominant

use Data-Europe-Asia, clear
keep if Floating_h==1
ppml rstock $varlist y*, cluster(idp) 
eststo Floating


log close

// *=========== Descriptive======================
// use Data-Europe-Asia, clear
//
// keep if stock >0
// keep if subcontinent_h == "ASEAN"
// keep if subcontinent_h == "South Asia"
// keep if subcontinent_h == "East Asia "
// keep if time == 2012
// keep if stock >0
// graph bar lrstock, over(bit) ytitle("mean of stock (m$)")  graphregion(color(white))
//
// graph twoway (lfit lrstock lsumgdp) (scatter lrstock lsumgdp) , ytitle("ln(stock)") xtitle("ln(sumgdp)") legend(off) graphregion(color(white))  
// graph export lsumgdp.png, replace
// graph twoway (lfit lrstock skill) (scatter lrstock skill) , ytitle("ln(stock)") xtitle("skill difference") legend(off) graphregion(color(white)) 
// graph export skill.png, replace


