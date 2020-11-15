clear
global mainpath "A:\AnhDropbox\01 PHD 2016\Data-main"
cd "C:\Users\ngoca\Dropbox\Pubs_since_2018\2019-Europe-Asia-FDI\2ndRevision_Final"
capture log close
log using Regression-all, replace


*======================== Table 4: Variable summary ==========================================

use Data-Europe-Asia, clear 

global varlist lsumgdp similarity skill  linvestcost ltradecost_h ltradecost_s  bit  crex comlang colony ldist y*

qui xtreg lrstock $varlist , cluster(idp) 
sum $varlist if e(sample)==1 // Table 4
inspect stock if e(sample)==1 //641 zero, 2836 positive
 
// keep  if e(sample)==1 
// keep host CountryName_h *continent*
// duplicates drop

unique source if e(sample) ==1
unique host if e(sample)==1
vallist CountryName_s if e(sample) ==1
vallist CountryName_h if e(sample)==1


*======================== Table 5: Results for the whole sample =========================================
use Data-Europe-Asia, clear

global varlist lsumgdp similarity skill  linvestcost ltradecost_h ltradecost_s  bit  crex comlang colony ldist region2 region3 region4 y*
eststo clear

reg lrstock $varlist , cluster(idp)
eststo OLS
qui predict  fit,xb
qui gen fit2 = fit^2
reg lrstock $varlist  fit2, cluster(idp)
test fit2=0 //0.000
drop fit*


xtreg lrstock $varlist , cluster(idp) fe 
eststo FE
qui predict  fit,xb
qui gen fit2 = fit^2
xtreg lrstock $varlist fit2, cluster(idp) fe 
test fit2=0 //0.1789
drop fit*


xtreg lrstock $varlist , cluster(idp) 
eststo RE
qui predict  fit,xb
qui gen fit2 = fit^2
xtreg lrstock $varlist fit2, cluster(idp) 
test fit2=0 //0.0596
drop fit*


xttobit lrstock $varlist , ll() tobit
eststo RETobit
qui predict  fit,xb
qui gen fit2 = fit^2
xttobit lrstock $varlist fit2, ll() tobit
test fit2=0 //0.0002
drop fit*


ppml rstock $varlist , cluster(idp) 
eststo PPML
test region2 region3 region4
qui predict  fit,xb
qui gen fit2 = fit^2
qui ppml stock $varlist  fit2, cluster(idp) 
test fit2=0 //0.3837
drop fit*


esttab using Results.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars drop (y*) noomitted nogaps title(Table 5: Results for the whole sample) compress replace

use Data-Europe-Asia, clear

*======================== Table 6: PPML Results by Asian sub-regions =========================================


eststo clear
use Data-Europe-Asia, clear

keep if subcontinent_h == "ASEAN"
ppml rstock $varlist , cluster(idp) 
eststo reg1
qui predict  fit,xb
qui gen fit2 = fit^2
ppml stock $varlist fit2, cluster(idp) 
test fit2=0 //p-value =0/.7415

use Data-Europe-Asia, clear

keep if subcontinent_h == "East Asia "
ppml rstock $varlist , cluster(idp) 
eststo reg2
qui predict  fit,xb
qui gen fit2 = fit^2
ppml rstock $varlist  fit2, cluster(idp) 
test fit2=0 //p-value =0/.3290


use Data-Europe-Asia, clear
keep if subcontinent_h == "South Asia"
ppml rstock $varlist , cluster(idp) 
eststo reg3
qui predict  fit,xb
qui gen fit2 = fit^2
ppml rstock $varlist  fit2, cluster(idp) 
test fit2=0 //p-value =0/.4546


use Data-Europe-Asia, clear
keep if subcontinent_h == "Central Asia"
ppml rstock $varlist , cluster(idp) 
eststo reg4
qui predict  fit,xb
qui gen fit2 = fit^2
ppml rstock $varlist  fit2, cluster(idp) 
test fit2=0 //p-value =0/.5769

esttab using Results.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars drop (  y*) noomitted nogaps title(Table 6: Results by Asian sub-regions (PPML) ) compress append


*======================== Table 7: PPML Results by countries' characteristics  =========================================

use Data-Europe-Asia, clear

global varlist lsumgdp similarity skill  linvestcost ltradecost_h ltradecost_s  bit  crex comlang colony ldist y*
eststo clear
use Data-Europe-Asia, clear
keep if Floating_h==1
ppml rstock $varlist, cluster(idp) 
eststo Floating
use Data-Europe-Asia, clear
keep if Floating_h==0
ppml rstock $varlist, cluster(idp) 
eststo NotFloating
use Data-Europe-Asia, clear
keep if DominantParty_h==1
ppml rstock $varlist, cluster(idp) 
eststo Dominant
use Data-Europe-Asia, clear
keep if DominantParty_h==0
ppml rstock $varlist , cluster(idp) 
eststo NoDominant



use Data-Europe-Asia, clear
keep if euro==1
ppml rstock $varlist , cluster(idp) 
eststo Eurozone

use Data-Europe-Asia, clear
keep if euro==0
ppml rstock $varlist , cluster(idp) 
eststo NotEurzone

esttab using Results.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars drop (  y*) noomitted nogaps title(Table 7: Results by countries' characteristics (PPML)) compress append






* 1st Revision requirements
*1/ Adding interaction variables: 
use Data-Europe-Asia, clear

gen SimilarityTrade =similarity *ltradecost_h
gen SkillTrade = skill*ltradecost_h
global varlist lsumgdp similarity skill  linvestcost ltradecost_h ltradecost_s SimilarityTrade SkillTrade  bit  crex comlang colony ldist region2 region3 region4 y*

eststo clear

reg lrstock $varlist , cluster(idp)
eststo POLS
qui predict  fit,xb
qui gen fit2 = fit^2
reg lrstock $varlist fit2, cluster(idp)
test fit2=0 //0.000
drop fit*


xtreg lrstock $varlist , cluster(idp) fe 
eststo FE
qui predict  fit,xb
qui gen fit2 = fit^2
xtreg lrstock $varlist fit2, cluster(idp) fe 
test fit2=0 //0.1789
drop fit*




xtreg lrstock $varlist , cluster(idp) 
eststo RE
qui predict  fit,xb
qui gen fit2 = fit^2
xtreg lrstock $varlist  fit2, cluster(idp) 
test fit2=0 //0.0596
drop fit*


xttobit lrstock $varlist , ll() tobit
eststo RETobit
qui predict  fit,xb
qui gen fit2 = fit^2
xttobit lrstock $varlist fit2, ll() tobit
test fit2=0 //0.0002
drop fit*


ppml rstock $varlist , cluster(idp) 
eststo PPML
test region2 region3 region4
qui predict  fit,xb
qui gen fit2 = fit^2
qui ppml stock $varlist  fit2, cluster(idp) 
test fit2=0 //0.3837
drop fit*


esttab using RevisedResults.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (ll N) ///
se(3) b(3) nodepvars noomitted nogaps title(Table R1: All Asia  stock, added vars) compress replace



log close




