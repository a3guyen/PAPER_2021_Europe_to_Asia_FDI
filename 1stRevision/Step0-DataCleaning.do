/*
Data needed:
1. FDI flows
2. FDI stocks
3. GDP nominal
4. GDP per capita (PPP)
5. Skill ratio
6. Investment freedom index
7. Trade Freedom Index
8. Common language
9. Distance
10. Colonial relationship
11. Other pair variable
*/

clear
global mainpath "A:\AnhDropbox\01 PHD 2016\Data-main"
cd "C:\Users\ngoca\Dropbox\Pubs_since_2018\2019-Europe-Asia-FDI\1stRevision"

use "$mainpath\STATA-FDI-2017\OECD\OECD-FDI-all-panel2.dta", clear
// *Not merge with OECD dta
// egen idp = group(source host)
// keep source host time oeos oeis idp
// gen stock = oeis
// replace stock = oeos if missing(oeis) 
// bysort idp: gen y = 1 if stock !=0 & !missing(stock)
// bysort idp: egen z = total(y)
// drop if z ==0
// drop y z



*Merging with data from UNCTAD

*********** Mergin UNCTAD with OECD data
merge 1:1 host source time using "$mainpath\STATA-FDI-2017\STEP5-AllFDI-panel-UNTACD2"
drop _merge



browse
sum
keep if time >=1995

* Counting observations in each series - USE stock only for regression
egen idp = group(source host)
keep source host time oeos oeis unis unos idp
local varlist  oeis oeos unis unos
foreach va in `varlist' {
replace `va'=0 if `va' <0 & !missing(`va')
bysort idp: gen y=1 if `va' !=0 & !missing(`va')
bysort idp: egen z = total(y)
replace `va' = . if z==0
drop y z
gen y =1 if !missing(`va')
bysort idp: egen count`va' = total(y)
drop y

}
// gen stock = oeis
// replace stock = oeos if count(oeos) > count(oe
// replace stock = unis if missing(stock)
// replace stock = unos if missing(stock)
// label var stock "Stock data from OECD, 1995-2013"
// gen stock1 = unis
// replace stock1 = unos if missing(stock1)
// label var stock1 "Stock data from UNCTAD, 2001-2012
//
// drop oe* count*
// bysort idp: gen y = 1 if stock !=0 & !missing(stock)
// bysort idp: egen z = total(y)
// replace stock =. if z ==0
// drop y z
// bysort idp: gen y = 1 if stock1 !=0 & !missing(stock1)
// bysort idp: egen z = total(y)
// replace stock1 =. if z ==0
// drop y z

gen stock = oeis
gen countstock = countoeis
replace stock = oeos if countoeos >countoeis
replace countstock = countoeos if  countoeos >countoeis

replace stock = unis if countunis > countstock
replace countstock = countunis if countunis > countstock
replace stock = unos if countunos > countstock


* Merge with region-income information
merge m:1 host using "$mainpath\STATA-region-income-2017\income_region.dta", keepusing(income subcontinent CountryName continent)

drop if _merge !=3
drop _merge
rename (income subcontinent CountryName continent) (income_h subcontinent_h CountryName_h continent_h)
merge m:1 source using "$mainpath\STATA-region-income-2017\income_region.dta", keepusing(income subcontinent CountryName continent)
drop if _merge !=3
drop _merge
rename (income subcontinent CountryName continent) (income_s subcontinent_s CountryName_s continent_s)
// keep source host time Country* *tinent* stock
// export delimited using "Global-FDI", replace
// export excel using "$mainpath\Prof-Cieslik\Data\Global-FDI.xlsx", sheetreplace firstrow(variables)


keep if continent_h == "Asia"
keep if continent_s == "Europe"
keep if time > 1994
unique source
unique host

*drop pairs with only 0 and missing over the whole period:
bysort idp: gen y = 1 if stock !=0 & !missing(stock)
bysort idp: egen z = total(y)
drop if z ==0
drop y z



* Merge with Pair-specific variables
*merge distance data
merge m:1 source host using "$mainpath\STATA-All-variables-2017\dist_cepii.dta" // Timor-Leste and middle east should be excluded
vallist CountryName_h if _merge ==1
drop if _merge !=3
drop _merge
*merge BITs data
merge 1:1 host source time using "$mainpath\STATA-Python-Bilateral-Treaties-2017\STEP2-Ever-Inforce-BITs-final.dta", keepusing(bit)
vallist CountryName_s if _merge ==1

drop if _merge ==2
drop _merge
replace bit=0 if missing(bit) // should I do this?
// *merge common religion index data
// merge m:1 source host using "$mainpath\STATA-Python-Religion-2017\05-Religion-FINAL", keepusing(religion)
// browse CountryName* if _merge ==1
// drop if _merge ==2
// drop _merge
*exchange rate data
*Merging with exchange rate data
merge 1:1 time source host using "$mainpath\Topic 3\Data\RealExchange.dta", keepusing(rexchange sdrex mrex crex rexchange_h rexchange_s)
drop if _merge ==2
drop _merge
label var crex "real exchange rate volatility, crex = sdrex/mrex- coefficient"

*===================================Country-specific Series
merge m:1 time host using "$mainpath\Topic 3\Data\CountryData-Topic3.dta", keepusing(cpi inflation linterest rinterest capital electric fixcap gdp_g gdpdf gdppc_g ngdppc ngdpus rgdppc rgdpus saving trade *ipo df10 price *efi taxp tax patentre priceus sdgdppcg sdgdpg mgdppcg mgdpg  cgdppcg cgdpg product2010 sbusiscore)
drop if _merge==2
drop _merge
local valist cpi inflation linterest rinterest capital electric fixcap gdp_g gdpdf gdppc_g ngdppc ngdpus rgdppc rgdpus saving trade *ipo df10 price *efi taxp tax patentre priceus  sdgdppcg sdgdpg mgdppcg mgdpg  cgdppcg cgdpg product2010 sbusiscore
foreach va in `valist'{
rename `va' `va'_h
}

merge m:1 time source using "$mainpath\Topic 3\Data\CountryData-Topic3.dta", keepusing(cpi inflation linterest rinterest capital electric fixcap gdp_g gdpdf gdppc_g ngdppc ngdpus rgdppc rgdpus saving trade *ipo df10 price *efi taxp tax patentre priceus  sdgdppcg sdgdpg mgdppcg mgdpg cgdppcg cgdpg product2010)
drop if _merge==2
drop _merge
local valist cpi inflation linterest rinterest capital electric fixcap gdp_g gdpdf gdppc_g ngdppc ngdpus rgdppc rgdpus saving trade *ipo df10 price *efi taxp tax patentre priceus  sdgdppcg sdgdpg  mgdppcg mgdpg  cgdppcg cgdpg product2010
foreach va in `valist'{
rename `va' `va'_s
}







*Getting the US GDP deflator 

merge m:1 time  using "$mainpath\STATA-World-Bank-2017\STEP1-USdeflator10.dta", keepusing(dfus)
drop if _merge ==2
drop _merge
sum dfus

gen rstock = stock*100/dfus
label var rstock "Real stock, mil$, rstock = stock*100/dfus"

label data "Europe to Asia FDI data, 1995-2013"


* Skill variable
merge m:1 time host using "$mainpath\STATA-SKILL-ILO_2017\skilldata2017.dta", keepusing(skratio_ipo )
drop if _merge==2
drop _merge
rename skratio_ipo sk_h

merge m:1 time source using "$mainpath\STATA-SKILL-ILO_2017\skilldata2017.dta", keepusing(skratio_ipo )
drop if _merge==2
drop _merge
rename skratio_ipo sk_s

*tertiary education
merge m:1 time host using "$mainpath\STATA-World-Bank-2017\STEP2-Final-data-WB-PWT-IMF.dta", keepusing(tertiary_ipo)
drop if _merge==2
drop _merge
rename tertiary_ipo tertiary_h

merge m:1 time source using "$mainpath\STATA-World-Bank-2017\STEP2-Final-data-WB-PWT-IMF.dta", keepusing(tertiary_ipo)
drop if _merge==2
drop _merge
rename tertiary_ipo tertiary_s



save Data-Europe-Asia-all, replace


use Data-Europe-Asia-all, clear


* Descriptive
unique source //34
unique host //32
unique time // 29

* Creating variables for KK:

gen sumgdp = ngdpus_h + ngdpus_s
label var sumgdp "sumgdp = ngdpus_h + ngdpus_s, billion usd"

gen ssi = 1 - (ngdpus_h/(ngdpus_h + ngdpus_s))^2 - (ngdpus_s/(ngdpus_h + ngdpus_s))^2


gen skill = sk_s - sk_h
gen tertiary = tertiary_s - tertiary_h
gen investcost = 100-inves_efi_h
gen tradecost_s = 100-trade_efi_s
gen tradecost_h = 100-trade_efi_h

xtset idp time
drop if time <1995 | time >2013
tab time, gen(y)
rename comlang_ethno comlang


sort source host time
browse source host time stock 
*delete pairs with only zero and missing stock

bysort idp: egen xk = total(stock)
drop if xk ==0

drop xk




save Data-Europe-Asia-all, replace




// *Gross fixed capital formation
// import delimited "API_NE.GDI.FTOT.CD_DS2_en_csv_v2_53419.csv", varnames(1) clear
// browse
// replace indicatorcode = "fixedcapital"
// egen id = group(countrycode )
//
// reshape long y, i(id indicatorcode) j(time)
// reshape wide y, i(id time) j(indicatorcode, string)
// rename y* *
// label var fixedcapital "Gross fixed capital formation (current US$)"
// rename ïcountryname  CountryName
// format %16s CountryName
// drop id
// gen host = countrycode
// gen source = countrycode
// duplicates drop
//
// save fixedcapital, replace

use Data-Europe-Asia-all, clear
merge m:1 host time using fixedcapital.dta, keepusing(fixedcapital)
drop if _merge == 2
rename fixedcapital fixedcapital_h
drop _merge
merge m:1 source time using fixedcapital.dta, keepusing(fixedcapital)
drop if _merge == 2
rename fixedcapital fixedcapital_s
drop _merge

qui gen Ss = sk_s/(sk_h + sk_s)
qui gen Ks = fixedcapital_s/(fixedcapital_s + fixedcapital_h)


save Data-Europe-Asia-all, replace

*Create EU membership 
// use Data-Europe-Asia-all, clear
// keep source CountryName_s
// duplicates drop
// gen time1 =.
// gen time2 =.
// label var time1 "Year joined the EU"
// label var time2 "Year joined the Euro area"
// sort CountryName_s
// edit 
// manually add the years in
// gen EUdum = 1 if !missing(time1)
// gen EUROZdum = 1 if !missing(time2)
//  save EU-EurozoneSince1995, replace
// use EU-EurozoneSince1995, replace
// keep source CountryName_s
// gen time = _n + 1957
// manually add more years in time until 2013
//
// fillin source time
// drop if missing(time)
// drop if missing(source)
// drop _fillin
// rename time time1
// merge 1:1 source time1 using EU-EurozoneSince1995, keepusing(EUdum)
// drop if _merge ==2
// drop _merge
// rename time1 time
// sort source time
// bysort source : replace EUdum= EUdum[_n-1] if !missing(EUdum[_n-1])
// replace EUdum =0 if missing(EUdum)
// rename EUdum eu
// rename time time2
// merge 1:1 source time2 using EU-EurozoneSince1995, keepusing(EUROZdum)
// drop if _merge ==2
// drop _merge
// rename time2 time
// sort source time
// bysort source : replace EUROZdum= EUROZdum[_n-1] if !missing(EUROZdum[_n-1])
// replace EUROZdum =0 if missing(EUROZdum)
// rename EUROZdum euro
// label var eu "=1 if EU member"
// label var euro "=1 if Eurozone member"
// save EU-EurozoneSince1995-FINAL, replace

use Data-Europe-Asia-all, clear
merge m:1 source time using EU-EurozoneSince1995-FINAL, keepusing(eu euro)
drop if _merge !=3
drop _merge
drop if source == "GIB"
drop if CountryName_s == "Bosnia and Herzegovina"
drop y*
save Data-Europe-Asia-all, replace
