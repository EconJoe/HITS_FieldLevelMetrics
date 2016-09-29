

*************************************************************************************
*************************************************************************************
* TOP CONCEPT BIRTHS

* Obtain just the top 0.01 percent of concepts
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\NGrams\Top
use ngrams_top, clear
keep if top_0001==1
keep ngramid
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\NGrams\Top
merge 1:m ngramid using ngrams_top_pmids_001
drop if _merge==2
drop _merge

* Keep only articles that are published in the concept's vintage year.
* These are the "originators" of the concept
keep if pubyear==vintage

* Restrict concepts to those born between 1983 and 2012
drop if vintage<1983 | vintage>2012

keep ngramid filenum pmid version vintage
order vintage ngram filenum pmid version
sort vintage ngram pmid version

* Attach the 4-digit MeSH terms and their weights to each article
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\MeSHAgg
joinby pmid version using medline14_mesh_4digit, unmatched(master)

order vintage ngram filenum pmid version meshid4 weight
sort vintage ngram meshid4 filenum pmid version

* Transform the concept vintages into 5-year period year bins
gen yearbin=""
replace yearbin="1983-1987" if vintage>=1983 & vintage<=1987
replace yearbin="1988-1992" if vintage>=1988 & vintage<=1992
replace yearbin="1993-1997" if vintage>=1993 & vintage<=1997
replace yearbin="1998-2002" if vintage>=1998 & vintage<=2002
replace yearbin="2003-2007" if vintage>=2003 & vintage<=2007
replace yearbin="2008-2012" if vintage>=2008 & vintage<=2012

* Compute the number of fractionalized articles that belong each ngram-yearbin-meshid cell.
collapse (sum) weight, by(ngram yearbin meshid)
order ngramid yearbin meshid4
sort ngramid yearbin meshid4

* Compute the total number of articles that originate each ngram
by ngramid, sort: egen articlecount=total(weight)

* Normalize the number of fractionalized articles that belong to each ngram-yearbin-meshid cell by the total number
*  of articles that originate each ngram. This will ensure that the sum of top concpet births across yearbins and meshids
*  equal the total number of top concepts (10,128 in our case).
gen topconceptbirths=weight/articlecount

* Compute the normalized number of top concepts for each yearbin-meshid
collapse (sum) topconceptbirths, by(yearbin meshid4)

sort meshid yearbin
compress
cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
save topconceptbirths, replace

*************************************************************************************
*************************************************************************************
* TOP CONCEPT MENTIONS
set more off

* Obtain just the top 0.01 percent of concepts
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\NGrams\Top
use ngrams_top, clear
keep if top_0001==1
keep ngramid
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\NGrams\Top
merge 1:m ngramid using ngrams_top_pmids_001
drop if _merge==2
drop _merge

* Restrict concepts to those born between 1973 and 2012.
* We want to go back further than 1983 because articles published in 1983 will have
*   no opportunity to mention top concepts that are 3, 5, or 10 years old.
drop if vintage<1973 | vintage>2012

* Allow any article after 2012 becuase concepts born in 2012 won't be able to be mentioned.
drop if pubyear<1983

keep ngramid filenum pmid version vintage pubyear
order vintage ngram filenum pmid version pubyear
sort vintage ngram pubyear pmid version

* Attach the 4-digit MeSH terms and their weights to each article
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\MeSHAgg
joinby pmid version using medline14_mesh_4digit, unmatched(master)

*compress 
*cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
*save test1, replace

use test1, clear

* Transform the article publication years into 5-year period year bins
gen yearbin=""
replace yearbin="1983-1987" if pubyear>=1983 & pubyear<=1987
replace yearbin="1988-1992" if pubyear>=1988 & pubyear<=1992
replace yearbin="1993-1997" if pubyear>=1993 & pubyear<=1997
replace yearbin="1998-2002" if pubyear>=1998 & pubyear<=2002
replace yearbin="2003-2007" if pubyear>=2003 & pubyear<=2007
replace yearbin="2008-2012" if pubyear>=2008 & pubyear<=2012

* Identify articles that use a top concept within `i' years of the concept's vintage.
local vals 0 3 5 10
foreach i in `vals' {
	gen mentions_total_`i'=0
	replace mentions_total_`i'=weight if pubyear<=vintage+`i'
}
gen mentions_total_all_=weight

* Drop year bins outside of the target range (1983-1987 to 2008-2012)
drop if yearbin==""

*compress 
*cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
*save test2, replace

use test2, clear

* For each meshid4 field and yearbin, compute the total number of (fractionalized) mentions of a top concept
* This can be thought of as being computed in two different, but equivalent ways:
*   1) For each ngramid, mesh4id, and yearbin, sum the fraction of all PMIDs
collapse (sum) mentions_*, by(yearbin meshid4 ngramid vintage)

sort meshid4 yearbin
compress
cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
save topconcepttotalmentions, replace

*11,634 top concepts
*3,492,556 articles published between 1983 and 2012 use some top concept with a vintage between 1983 and 2012. 
*  But the same article can use more than one top concept.
*  This can lead to more mentions in a field-period than the number of articles.
*******************************************************************************





*************************************************************************************
*************************************************************************************
* TOP CONCEPT AVERAGE MENTIONS
set more off

* Obtain just the top 0.01 percent of concepts
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\NGrams\Top
use ngrams_top, clear
keep if top_0001==1
keep ngramid
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\NGrams\Top
merge 1:m ngramid using ngrams_top_pmids_001
drop if _merge==2
drop _merge

* Restrict concepts to those born between 1970 and 2012.
* We want to go back further than 1983 because articles published in 1983 will have
*   no opportunity to mention top concepts that are 3, 5, or 10 years old. Restricting
*   to 1970 is fairly arbitrary. 
drop if vintage<1973 | vintage>2012

* Allow any article after 2012 becuase concepts born in 2012 won't be able to be mentioned.
drop if pubyear<1983

keep pmid version pubyear vintage ngram
order pmid version pubyear vintage ngram
sort pmid version pubyear vintage ngram

*compress 
*cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
save test2, replace
use test2, clear

* Identify articles that use a particular concept within `i' years of the concept's vintage
local vals 0 3 5 10
foreach i in `vals' {
	gen mentions_mean_`i'=0
	replace mentions_mean_`i'=1 if pubyear<=vintage+`i'
}
gen mentions_mean_all=1

* Compute the total number of ngrams that each article uses
collapse (sum) ngramcount_*, by(pmid pubyear)

* Attach the 4-digit MeSH terms and their weights to each article
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\MeSHAgg
joinby pmid version using medline14_mesh_4digit, unmatched(master)

* Transform the article publication years into 5-year period year bins
gen yearbin=""
replace yearbin="1983-1987" if pubyear>=1983 & pubyear<=1987
replace yearbin="1988-1992" if pubyear>=1988 & pubyear<=1992
replace yearbin="1993-1997" if pubyear>=1993 & pubyear<=1997
replace yearbin="1998-2002" if pubyear>=1998 & pubyear<=2002
replace yearbin="2003-2007" if pubyear>=2003 & pubyear<=2007
replace yearbin="2008-2012" if pubyear>=2008 & pubyear<=2012

keep pmid pubyear yearbin ngramcount_* weight meshid4
order meshid4 yearbin pmid pubyear weight

local vals 0 3 5 10
foreach i in `vals' {
	replace mentions_mean_`i'=weight*mentions_mean_`i'
}
replace mentions_mean_all=weight*mentions_mean_all

* Compute the weighted mean number of concepts used by the articles in each meshid4-yearbin.
collapse (mean) mentions_*, by(meshid4 yearbin)

collapse (mean) mentions_* [aweight=weight], by(meshid4 yearbin)


drop if yearbin==""
sort meshid4 yearbin
compress
cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
save topconceptaveragementions, replace

*11,634 top concepts
*3,492,556 articles published between 1983 and 2012 use some top concept with a vintage between 1983 and 2012. 
*  But the same article can use more than one top concept.
*  This can lead to more mentions in a field-period than the number of articles.
*******************************************************************************











































* NUMBER OF TOP CONCEPTS MENTIONED
*******************************************************************************
cd B:\Research\HITS\HITS2\Data\Metrics
use hold, clear

keep ngramid vintage pubyear meshid4
duplicates drop
save hold2, replace

**************************************
use hold2, clear
gen yearbin=""
replace yearbin="1983-1987" if pubyear>=1983 & pubyear<=1987
replace yearbin="1988-1992" if pubyear>=1988 & pubyear<=1992
replace yearbin="1993-1997" if pubyear>=1993 & pubyear<=1997
replace yearbin="1998-2002" if pubyear>=1998 & pubyear<=2002
replace yearbin="2003-2007" if pubyear>=2003 & pubyear<=2007
replace yearbin="2008-2012" if pubyear>=2008 & pubyear<=2012

keep ngramid vintage yearbin meshid4
duplicates drop

order meshid4 yearbin ngramid vintage
sort meshid4 yearbin ngramid

gen conceptsused_all=1
collapse (sum) conceptsused, by(yearbin meshid4)
sort meshid4 yearbin

save hold3_all, replace
**************************************

**************************************
use hold2, clear
keep if pubyear==vintage
gen yearbin=""
replace yearbin="1983-1987" if pubyear>=1983 & pubyear<=1987
replace yearbin="1988-1992" if pubyear>=1988 & pubyear<=1992
replace yearbin="1993-1997" if pubyear>=1993 & pubyear<=1997
replace yearbin="1998-2002" if pubyear>=1998 & pubyear<=2002
replace yearbin="2003-2007" if pubyear>=2003 & pubyear<=2007
replace yearbin="2008-2012" if pubyear>=2008 & pubyear<=2012

keep ngramid vintage yearbin meshid4
duplicates drop

order meshid4 yearbin ngramid vintage
sort meshid4 yearbin ngramid

gen conceptsused_0=1
collapse (sum) conceptsused, by(yearbin meshid4)
sort meshid4 yearbin

save hold3_0, replace
**************************************


**************************************
use hold2, clear
keep if pubyear<=vintage+3
gen yearbin=""
replace yearbin="1983-1987" if pubyear>=1983 & pubyear<=1987
replace yearbin="1988-1992" if pubyear>=1988 & pubyear<=1992
replace yearbin="1993-1997" if pubyear>=1993 & pubyear<=1997
replace yearbin="1998-2002" if pubyear>=1998 & pubyear<=2002
replace yearbin="2003-2007" if pubyear>=2003 & pubyear<=2007
replace yearbin="2008-2012" if pubyear>=2008 & pubyear<=2012

keep ngramid vintage yearbin meshid4
duplicates drop

order meshid4 yearbin ngramid vintage
sort meshid4 yearbin ngramid

gen conceptsused_3=1
collapse (sum) conceptsused, by(yearbin meshid4)
sort meshid4 yearbin

save hold3_3, replace
**************************************

**************************************
use hold2, clear
keep if pubyear<=vintage+5
gen yearbin=""
replace yearbin="1983-1987" if pubyear>=1983 & pubyear<=1987
replace yearbin="1988-1992" if pubyear>=1988 & pubyear<=1992
replace yearbin="1993-1997" if pubyear>=1993 & pubyear<=1997
replace yearbin="1998-2002" if pubyear>=1998 & pubyear<=2002
replace yearbin="2003-2007" if pubyear>=2003 & pubyear<=2007
replace yearbin="2008-2012" if pubyear>=2008 & pubyear<=2012

keep ngramid vintage yearbin meshid4
duplicates drop

order meshid4 yearbin ngramid vintage
sort meshid4 yearbin ngramid

gen conceptsused_5=1
collapse (sum) conceptsused, by(yearbin meshid4)
sort meshid4 yearbin

save hold3_5, replace
**************************************


**************************************
use hold2, clear
keep if pubyear<=vintage+10
gen yearbin=""
replace yearbin="1983-1987" if pubyear>=1983 & pubyear<=1987
replace yearbin="1988-1992" if pubyear>=1988 & pubyear<=1992
replace yearbin="1993-1997" if pubyear>=1993 & pubyear<=1997
replace yearbin="1998-2002" if pubyear>=1998 & pubyear<=2002
replace yearbin="2003-2007" if pubyear>=2003 & pubyear<=2007
replace yearbin="2008-2012" if pubyear>=2008 & pubyear<=2012

keep ngramid vintage yearbin meshid4
duplicates drop

order meshid4 yearbin ngramid vintage
sort meshid4 yearbin ngramid

gen conceptsused_10=1
collapse (sum) conceptsused, by(yearbin meshid4)
sort meshid4 yearbin

save hold3_10, replace
**************************************

use hold3_all, clear
merge 1:1 meshid4 yearbin using hold3_0
replace conceptsused_0=0 if _merge==1
drop _merge
merge 1:1 meshid4 yearbin using hold3_3
replace conceptsused_3=0 if _merge==1
drop _merge
merge 1:1 meshid4 yearbin using hold3_5
replace conceptsused_5=0 if _merge==1
drop _merge
merge 1:1 meshid4 yearbin using hold3_10
replace conceptsused_10=0 if _merge==1
drop _merge

sort meshid yearbin
compress
cd B:\Research\HITS\HITS2\Data\Metrics
save topconceptsused, replace
*******************************************************************************


* NUMBER OF ARTICLES THAT USE TOP CONCEPT
*******************************************************************************
cd B:\Research\HITS\HITS2\Data\Metrics
use hold, clear
keep pmid version pubyear vintage meshid4



* CONCEPT BIRTHS
*******************************************************************************
* Determine the proportion of each n-gram that each field produced.
cd B:\Research\HITS\HITS2\Data\Metrics
use hold, clear
*keep if ngramid==11985
keep if pubyear==vintage
gen yearbin=""
replace yearbin="1983-1987" if vintage>=1983 & vintage<=1987
replace yearbin="1988-1992" if vintage>=1988 & vintage<=1992
replace yearbin="1993-1997" if vintage>=1993 & vintage<=1997
replace yearbin="1998-2002" if vintage>=1998 & vintage<=2002
replace yearbin="2003-2007" if vintage>=2003 & vintage<=2007
replace yearbin="2008-2012" if vintage>=2008 & vintage<=2012

collapse (sum) weight, by(ngram yearbin meshid)
by ngramid, sort: egen total=total(weight)
gen conceptbirths=weight/total

collapse (sum) conceptbirths, by(yearbin meshid4)

*10,128

sort meshid yearbin
compress
cd B:\Research\HITS\HITS2\Data\Metrics
save topconceptbirths, replace
*******************************************************************************



* HERFINDAHL (Forward-looking)
*******************************************************************************
* Determine the proportion of each n-gram that each field produced.
cd B:\Research\HITS\HITS2\Data\Metrics
use hold, clear
keep if pubyear==vintage
gen yearbin=""
replace yearbin="1983-1987" if vintage>=1983 & vintage<=1987
replace yearbin="1988-1992" if vintage>=1988 & vintage<=1992
replace yearbin="1993-1997" if vintage>=1993 & vintage<=1997
replace yearbin="1998-2002" if vintage>=1998 & vintage<=2002
replace yearbin="2003-2007" if vintage>=2003 & vintage<=2007
replace yearbin="2008-2012" if vintage>=2008 & vintage<=2012

collapse (sum) weight, by(ngram yearbin meshid)
by ngramid, sort: egen total=total(weight)
gen weight_vintage=weight/total

drop weight total
rename meshid4 meshid4_vintage
order meshid4_vintage yearbin weight_vintage ngramid
sort meshid4_vintage yearbin ngramid
compress
cd B:\Research\RAWDATA\MEDLINE\2014\Metrics
save test3, replace

use hold, clear
keep ngramid weight meshid4
collapse (sum) weight, by(ngramid meshid4)
rename weight mentions

joinby ngramid using test3, unmatched(both)
drop _merge

order meshid4_vintage weight_vintage ngramid
sort meshid4_vintage ngramid meshid4

gen test=mentions*weight_vintage
by meshid4_vintage yearbin, sort: egen total=total(test)

gen prop=test/total
gen herfindahl=prop^2

save test4, replace

collapse (sum) herfindahl, by(meshid4_vintage yearbin)
rename meshid4_vintage meshid4

compress
cd B:\Research\HITS\HITS2\Data\Metrics
save topconceptsherfindahl, replace




* HERFINDAHL (Backward Looking)
*******************************************************************************
cd B:\Research\HITS\HITS2\Data\Metrics
use hold, clear
gen mentions_all=weight
gen mentions0=0
replace mentions0=mentions_all if pubyear==vintage
gen mentions3=0
replace mentions3=mentions_all if pubyear<=vintage+3
gen mentions5=0
replace mentions5=mentions_all if pubyear<=vintage+5
gen mentions10=0
replace mentions10=mentions_all if pubyear<=vintage+10

gen yearbin=""
replace yearbin="1983-1987" if pubyear>=1983 & pubyear<=1987
replace yearbin="1988-1992" if pubyear>=1988 & pubyear<=1992
replace yearbin="1993-1997" if pubyear>=1993 & pubyear<=1997
replace yearbin="1998-2002" if pubyear>=1998 & pubyear<=2002
replace yearbin="2003-2007" if pubyear>=2003 & pubyear<=2007
replace yearbin="2008-2012" if pubyear>=2008 & pubyear<=2012

collapse (sum) mentions*, by(ngram vintage meshid4 yearbin)

order meshid4 yearbin ngram
sort meshid4 yearbin ngram
by meshid4 yearbin, sort: egen total_all=total(mentions_all)
by meshid4 yearbin, sort: egen total0=total(mentions0)
by meshid4 yearbin, sort: egen total3=total(mentions3)
by meshid4 yearbin, sort: egen total5=total(mentions5)
by meshid4 yearbin, sort: egen total10=total(mentions10)

gen prop_all=mentions_all/total_all
gen prop0=mentions0/total0
gen prop3=mentions3/total3
gen prop5=mentions5/total5
gen prop10=mentions10/total10

gen herfindahl_all=prop_all^2
gen herfindahl0=prop0^2
gen herfindahl3=prop3^2
gen herfindahl5=prop5^2
gen herfindahl10=prop10^2

collapse (sum) herfindahl*, by(meshid4 yearbin)

sort meshid yearbin
compress
cd B:\Research\HITS\HITS2\Data\Metrics
save topconceptintensity, replace
*******************************************************************************

* TURNOVER
*******************************************************************************
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\NGrams\Top
use ngrams_top, clear
keep if top_0001==1
keep ngramid

*11,634
*3,492,556 articles published between 1983 and 2012 use some top concept with a vintage between 1983 and 2012. 
*  But the same article can use more than one top concept.
*  This can lead to more mentions in a field-period than the number of articles.

cd B:\Research\RAWDATA\MEDLINE\2014\Processed\NGrams\Top
merge 1:m ngramid using ngrams_top_pmids_001
drop if _merge==2
drop _merge

drop if vintage<1978 | vintage>2012
drop if pubyear<1978 | pubyear>2012

keep ngramid filenum pmid version pubyear vintage

compress
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\MeSHAgg
joinby pmid version using medline14_mesh_4digit, unmatched(master)


gen mentions_all=weight

gen yearbin=""
replace yearbin="1978-1982" if pubyear>=1978 & pubyear<=1982
replace yearbin="1983-1987" if pubyear>=1983 & pubyear<=1987
replace yearbin="1988-1992" if pubyear>=1988 & pubyear<=1992
replace yearbin="1993-1997" if pubyear>=1993 & pubyear<=1997
replace yearbin="1998-2002" if pubyear>=1998 & pubyear<=2002
replace yearbin="2003-2007" if pubyear>=2003 & pubyear<=2007
replace yearbin="2008-2012" if pubyear>=2008 & pubyear<=2012

collapse (sum) mentions_all, by(meshid4 yearbin ngram)
order meshid4 year ngram
gsort meshid4 year -mentions_all

encode yearbin, gen(yearbin_)
drop yearbin
reshape wide mentions_all, i(meshid4 ngram) j(yearbin_)

gen used2=0
replace used2=1 if mentions_all2!=. & mentions_all1!=.
gen used3=0
replace used3=1 if mentions_all3!=. & mentions_all2!=.
gen used4=0
replace used4=1 if mentions_all4!=. & mentions_all3!=.
gen used5=0
replace used5=1 if mentions_all5!=. & mentions_all4!=.
gen used6=0
replace used6=1 if mentions_all6!=. & mentions_all5!=.
gen used7=0
replace used7=1 if mentions_all7!=. & mentions_all6!=.


collapse (mean) used*, by(meshid4)
reshape long used, i(meshid4) j(yearbin_)
rename used turnover


gen yearbin=""
replace yearbin="1978-1982" if yearbin_==2
replace yearbin="1988-1992" if yearbin_==3
replace yearbin="1993-1997" if yearbin_==4
replace yearbin="1998-2002" if yearbin_==5
replace yearbin="2003-2007" if yearbin_==6
replace yearbin="2008-2012" if yearbin_==7
drop yearbin_

drop if yearbin==""
order meshid yearbin
sort meshid yearbin
compress
cd B:\Research\HITS\HITS2\Data\Metrics
save topconceptturnover, replace



* OBSOLESCENCE
*******************************************************************************
*use hold, clear


* ARTICLE COUNT
*******************************************************************************
cd B:\Research\HITS\HITS2\Data
use articlesample, clear
drop if pubyear<1983 | pubyear>2012
keep pmid pubyear

cd B:\Research\RAWDATA\MEDLINE\2014\Processed\MeSHAgg
joinby pmid using medline14_mesh_4digit, unmatched(both)
drop if _merge==2
drop _merge

gen yearbin=""
replace yearbin="1983-1987" if pubyear>=1983 & pubyear<=1987
replace yearbin="1988-1992" if pubyear>=1988 & pubyear<=1992
replace yearbin="1993-1997" if pubyear>=1993 & pubyear<=1997
replace yearbin="1998-2002" if pubyear>=1998 & pubyear<=2002
replace yearbin="2003-2007" if pubyear>=2003 & pubyear<=2007
replace yearbin="2008-2012" if pubyear>=2008 & pubyear<=2012

rename weight articles
collapse (sum) articles, by(meshid yearbin)

order meshid yearbin
sort meshid yearbin
compress
cd B:\Research\HITS\HITS2\Data\Metrics
save articlecount, replace


* COMBINE
*******************************************************************************
cd B:\Research\RAWDATA\MeSH\2014\Parsed
import delimited using "desc2014_meshtreenumbers.txt", clear delimiter(tab) varnames(1)
keep if regexm(treenumber, "^([A-Z][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9])$")
keep meshid
duplicates drop
tempfile hold
save `hold', replace

clear
set obs 6
gen yearbin_=_n
gen yearbin=""
replace yearbin="1983-1987" if yearbin_==1
replace yearbin="1988-1992" if yearbin_==2
replace yearbin="1993-1997" if yearbin_==3
replace yearbin="1998-2002" if yearbin_==4
replace yearbin="2003-2007" if yearbin_==5
replace yearbin="2008-2012" if yearbin_==6
drop yearbin_

cross using `hold'

sort meshid yearbin
keep yearbin meshid mesh
duplicates drop
rename meshid meshid4

cd B:\Research\HITS\HITS2\Data\Metrics
merge 1:1 yearbin meshid4 using topconceptmentions
replace mentions_all=0 if _merge==1
replace mentions0=0 if _merge==1
replace mentions3=0 if _merge==1
replace mentions5=0 if _merge==1
replace mentions10=0 if _merge==1
drop _merge
sort meshid4 yearbin

merge 1:1 yearbin meshid4 using topconceptbirths
replace conceptbirths=0 if _merge==1
drop _merge

merge 1:1 yearbin meshid4 using topconceptsherfindahl
drop _merge

merge 1:1 yearbin meshid4 using topconceptintensity
drop _merge

merge 1:1 yearbin meshid4 using topconceptturnover
drop _merge

merge 1:1 yearbin meshid4 using articlecount
replace articles=0 if _merge==1
drop _merge
save `hold', replace

cd B:\Research\RAWDATA\MeSH\2014\Parsed
import delimited using "desc2014_meshtreenumbers.txt", clear delimiter(tab) varnames(1)
keep meshid mesh
rename meshid meshid4
rename mesh mesh4
duplicates drop
merge 1:m meshid4 using `hold'
drop if _merge==1
drop _merge

order meshid4 mesh4 yearbin
sort meshid4 yearbin
compress
cd B:\Research\HITS\HITS2\Data\Metrics
save textmetrics, replace
export delimited using "textmetrics", replace
*******************************************************************************

