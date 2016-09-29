

*******************************************************************
*******************************************************************
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
* These are the "originators" of the concept.
keep if pubyear==vintage

* Restrict concepts to those born between 1983 and 2012.
*  This is just the time period we are interested in examining.
drop if vintage<1983 | vintage>2012

keep ngramid pmid meshid4 pubyear vintage weight
order ngramid pmid meshid4
sort ngramid pmid meshid4

* Attach the 4-digit MeSH terms and their weights to each article
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\MeSHAgg
joinby pmid version using medline14_mesh_4digit, unmatched(master)

* Compute the total number of articles that originate each ngram
* Recall that the meshid4_weights sum to 1 within each article.
by ngramid, sort: egen articlecount=total(weight)

* Normalize the number of fractionalized articles that belong to each ngram-yearbin-meshid cell by the total number
*  of articles that originate each ngram.
* This ensures that the total weight sums to 1 for each ngram.
* This will ensure that the sum of top concept births across yearbins and meshids
*  equal the total number of top concepts (10,128 in our case).
gen topconceptbirths=weight/articlecount

* Transform the concept vintages into 5-year period year bins
gen yearbin=""
replace yearbin="1983-1987" if vintage>=1983 & vintage<=1987
replace yearbin="1988-1992" if vintage>=1988 & vintage<=1992
replace yearbin="1993-1997" if vintage>=1993 & vintage<=1997
replace yearbin="1998-2002" if vintage>=1998 & vintage<=2002
replace yearbin="2003-2007" if vintage>=2003 & vintage<=2007
replace yearbin="2008-2012" if vintage>=2008 & vintage<=2012

* Compute the number of fractionalized articles that belong each ngram-yearbin-meshid cell.
collapse (sum) topconceptbirths, by(yearbin meshid)
rename topconceptbirths topconceptbirths2

sort meshid yearbin
compress
cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
save topconceptbirths3, replace
*******************************************************************



*******************************************************************
*******************************************************************
* TOP CONCEPT TOTAL MENTIONS

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

* The "target" that we are interested in examining is articles published between 1983 and 2012
drop if pubyear<1983 | pubyear>2012

keep ngramid pmid meshid4 pubyear vintage weight
order ngramid pmid meshid4
sort ngramid pmid meshid4

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

* Identify articles that use a top concept within `i' years of the concept's vintage.
local vals 0 3 5 10
foreach i in `vals' {
	gen mentions_total_`i'=0
	replace mentions_total_`i'=weight if pubyear<=vintage+`i'
}
gen mentions_total_all_=weight

* Drop year bins outside of the target range (1983-1987 to 2008-2012)
drop if yearbin==""

* For each meshid4 field and yearbin, compute the total number of (fractionalized) mentions of a top concept
* This can be thought of as being computed in two different, but equivalent ways:
*   1) A) Fix a ngram. Determine the number of PMIDs belonging to each meshid4-yearbin that mention the ngram. 
*         collapse (sum) mentions_*, by(yearbin meshid4 ngramid vintage)
*      B) Sum the number of fractionalized mentions over all ngrams 
*         collapse (sum) mentions_*, by(yearbin meshid4)
*
*   2) A) Fix a PMID. Determine the number of ngrams it uses in each mesh4id and yearbin. 
*         collapse (sum) mentions_*, by(yearbin meshid4 pmid pubyear)
*      B) Sum the number of fractionalized mentions over all PMIDs 
*         collapse (sum) mentions_*, by(yearbin meshid4)
* Obviously this can all be combined into a single equivalent step: collapse (sum) mentions_*, by(yearbin meshid4)

collapse (sum) mentions_*, by(yearbin meshid4)

sort meshid4 yearbin
compress
cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
save topconcepttotalmentions3, replace

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

* The "target" that we are interested in examining is articles published between 1983 and 2012
drop if pubyear<1983 | pubyear>2012

keep pmid version pubyear vintage ngramid
order pmid version pubyear vintage ngramid
sort pmid version pubyear vintage ngramid

* Identify articles that use a particular concept within `i' years of the concept's vintage
local vals 0 3 5 10
foreach i in `vals' {
	gen mentions_mean_`i'=0
	replace mentions_mean_`i'=1 if pubyear<=vintage+`i'
}
gen mentions_mean_all=1

* Compute the total number of top concepts that each article uses within `i' years of concept's vintage
collapse (sum) mentions_mean_*, by(pmid version pubyear)

* Attach the 4-digit MeSH terms and their weights to each article
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\MeSHAgg
joinby pmid version using medline14_mesh_4digit, unmatched(master)

keep pmid pubyear meshid4 weight mentions_*
order pmid meshid4 weight pubyear
sort pmid meshid4

* Transform the article publication years into 5-year period year bins
gen yearbin=""
replace yearbin="1983-1987" if pubyear>=1983 & pubyear<=1987
replace yearbin="1988-1992" if pubyear>=1988 & pubyear<=1992
replace yearbin="1993-1997" if pubyear>=1993 & pubyear<=1997
replace yearbin="1998-2002" if pubyear>=1998 & pubyear<=2002
replace yearbin="2003-2007" if pubyear>=2003 & pubyear<=2007
replace yearbin="2008-2012" if pubyear>=2008 & pubyear<=2012

* Weight the mentions. If 0.5 of an article belongs to a particular mesh4id, then 0.5 of its mentions also belong to that
*   mesh4id.
local vals 0 3 5 10
foreach i in `vals' {
	replace mentions_mean_`i'=weight*mentions_mean_`i'
}
replace mentions_mean_all=weight*mentions_mean_all

* Compute the weighted mean number of concepts used by the articles in each meshid4-yearbin.
collapse (mean) mentions_*, by(meshid4 yearbin)

drop if yearbin==""
sort meshid4 yearbin
compress
cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
save topconceptaveragementions3, replace
*************************************************************************************


*************************************************************************************
*************************************************************************************
* HERFINDAHL (Forward-looking)

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
* These are the "originators" of the concept.
keep if pubyear==vintage

* Restrict concepts to those born between 1983 and 2012.
*  This is just the time period we are interested in examining.
drop if vintage<1983 | vintage>2012

* Attach the 4-digit MeSH terms and their weights to each article
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\MeSHAgg
joinby pmid version using medline14_mesh_4digit, unmatched(master)

keep ngramid pmid meshid4 pubyear vintage weight
order ngramid pmid meshid4
sort ngramid pmid meshid4

* Compute the total number of articles that originate each ngram
* Recall that the meshid4_weights sum to 1 within each article.
by ngramid, sort: egen articlecount=total(weight)

* Normalize the number of fractionalized articles that belong to each ngram-yearbin-meshid cell by the total number
*  of articles that originate each ngram.
* This ensures that the total weight sums to 1 for each ngram.
* This will ensure that the sum of top concept births across yearbins and meshids
*  equal the total number of top concepts (10,128 in our case).
gen weight_vintage=weight/articlecount

* Transform the concept vintages into 5-year period year bins
gen yearbin=""
replace yearbin="1983-1987" if vintage>=1983 & vintage<=1987
replace yearbin="1988-1992" if vintage>=1988 & vintage<=1992
replace yearbin="1993-1997" if vintage>=1993 & vintage<=1997
replace yearbin="1998-2002" if vintage>=1998 & vintage<=2002
replace yearbin="2003-2007" if vintage>=2003 & vintage<=2007
replace yearbin="2008-2012" if vintage>=2008 & vintage<=2012

* Compute the number of fractionalized articles that belong each ngram-yearbin-meshid cell.
collapse (sum) weight_vintage, by(ngramid yearbin meshid)

rename meshid4 meshid4_vintage
order meshid4_vintage yearbin weight_vintage ngramid
sort meshid4_vintage yearbin ngramid
compress
cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
save topconceptherfindahl_forward, replace


* Obtain just the top 0.01 percent of concepts
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\NGrams\Top
use ngrams_top, clear
keep if top_0001==1
keep ngramid
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\NGrams\Top
merge 1:m ngramid using ngrams_top_pmids_001
drop if _merge==2
drop _merge

* Restrict concepts to those born between 1983 and 2012.
*  This is just the time period we are interested in examining.
drop if vintage<1983 | vintage>2012

* Allow articles published after 2012. Otherwise, concepts born in 2012 can never be mentioned.
drop if pubyear<1983

* Attach the 4-digit MeSH terms and their weights to each article
cd B:\Research\RAWDATA\MEDLINE\2014\Processed\MeSHAgg
joinby pmid version using medline14_mesh_4digit, unmatched(master)

keep ngramid weight meshid4
collapse (sum) weight, by(ngramid meshid4)
rename weight mentions

cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
joinby ngramid using topconceptherfindahl_forward, unmatched(both)
drop _merge

order meshid4_vintage weight_vintage ngramid
sort meshid4_vintage ngramid meshid4

cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
save temp, replace

cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
use temp, clear

* meshid4_vintage is the "industry" and n-gram-meshid4 is the "firm"
by meshid4_vintage yearbin ngramid, sort: egen total=total(mentions)
gen prop=mentions/total
gen herfindahl=prop^2

collapse (sum) herfindahl, by(meshid4_vintage weight_vintage yearbin ngram)
order meshid4 yearbin ngramid
sort meshid yearbin ngramid

gen herfindhal_weighted=herfindahl*weight
collapse (mean) herfindahl herfindhal_weighted, by(meshid4_vintage yearbin)

gen test=mentions*weight_vintage
by meshid4_vintage yearbin, sort: egen total=total(test)

gen prop=test/total
gen herfindahl=prop^2

collapse (sum) herfindahl, by(meshid4_vintage yearbin)
rename meshid4_vintage meshid4

compress
cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
save topconceptherfindahl_forward, replace



*************************************************************************************
*************************************************************************************
* HERFINDAHL (Backward-looking)


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

* The "target" that we are interested in examining is articles published between 1983 and 2012
drop if pubyear<1983 | pubyear>2012

keep ngramid pmid meshid4 pubyear vintage weight
order ngramid pmid meshid4
sort ngramid pmid meshid4

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

* Identify articles that use a top concept within `i' years of the concept's vintage.
local vals 0 3 5 10
foreach i in `vals' {
	gen mentions_total_`i'=0
	replace mentions_total_`i'=weight if pubyear<=vintage+`i'
}
gen mentions_total_all_=weight

* Drop year bins outside of the target range (1983-1987 to 2008-2012)
drop if yearbin==""

collapse (sum) mentions_*, by(ngram vintage meshid4 yearbin)




