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

compress 
cd B:\Research\Projects\HITS\HITS3\Data\Final\FieldLevel
save test2, replace

gen ngramcount_all=1

gen ngramcount=0
replace ngramcount=1 if pubyear==vintage

gen ngramcount_3=0
replace ngramcount_3=1 if pubyear<=vintage+3

gen ngramcount_5=0
replace ngramcount_5=1 if pubyear<=vintage+5

gen ngramcount_10=0
replace ngramcount_10=1 if pubyear<=vintage+10

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

replace ngramcount_all=weight*ngramcount_all
replace ngramcount_0=weight*ngramcount_0
replace ngramcount_3=weight*ngramcount_3
replace ngramcount_5=weight*ngramcount_5
replace ngramcount_10=weight*ngramcount_10

collapse (mean) ngramcount_*, by(meshid4 yearbin)

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


use topconceptaveragementions, clear
merge 1:1 meshid4 yearbin using topconceptmentions











