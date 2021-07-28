// Project: Stata command to convert a REDCap logging CSV file to an easy-to-read Stata dataset
// Created by: James Hedley
// Date created: 28th July 2021
// Last updated: 28th July 2021


* Program
capture program drop redcap_logfile
program define redcap_logfile, rclass
	syntax anything(name=filename) [, clear MAXRows(numlist integer max=1) Showprogress]
	
	
	quietly {
		* Remove quotes from input filename
		local filename `filename'
		
		** Update progress
		noisily display "Opening the REDCap logging file..."
		
		* Import the logging file
		import delimited "`filename'", `clear' delimiter(",") varnames(1) bindquotes(strict)
		
	
		** Update progress
		noisily display "Cleaning logging data..."
		
		
		* Only keep records relating to changes to data
		keep if ustrregexm(action,"((Created|Deleted|Updated) Record|Sent Alert|Updated Response)")

		
		* Create a variable to preserve order of changes in logfile
		gen order=_n, before(timedate)
		
		
		* Create a separate variable for record ID
		gen recordid=ustrregexs(0) if ustrregexm(action,"[\S]+$"), after(order)

		
		* Create separate variables for time and date-time
		gen double datetime=clock(timedate,"YMDhm"), after(timedate)
		format datetime %tc
		
		gen date=dofc(datetime), after(datetime)
		format date %td
		
		drop timedate
		
		* Create a separate variable for the method used to perform each action
		gen method="", after(action)
		replace method="API" if strpos(action,"(API)")!=0
		replace method="Import" if strpos(action,"(import)")!=0
		replace method="Data quality" if strpos(action,"(Data Quality)")!=0
		replace method="Participant" if strpos(action,"Updated Response")!=0
		replace method="User" if method==""
		
		
		* Clean action variable
		replace action="Uploaded Document" if strpos(action,"Uploaded Document")!=0
		replace action="Deleted Document" if strpos(action,"Deleted Document")!=0
		replace action="Updated Record" if strpos(action,"Updated Response")!=0
		replace action=subinstr(action,recordid,"",.)
		replace action=subinstr(action,"(API)","",.)
		replace action=subinstr(action,"(import)","",.)
		replace action=subinstr(action,"(Auto calculation)","",.)
		replace action=subinstr(action,"(Data Quality)","",.)
		replace action=strtrim(action)

		
		* Clean variable of changes made
		rename listofdatachangesorfieldsexporte changes
		replace changes="" if action=="Deleted Record"
		
		
		
		* Split the data into smaller datasets
		if "`maxrows'"=="" {
			count
			local maxrows=(sqrt(`r(N)')*2) // Default setting for maxrows is the square root of total observations x 2
		}
		gen dataset=1 if _n==1
		replace dataset=dataset[_n-1] if inrange(_n,2,`maxrows')
		replace dataset=dataset[_n-`maxrows']+1 if _n>`maxrows'
		
		summ dataset
		local datasetcount=`r(max)'
		
		
		forvalues dataset=1/`datasetcount' {
			
			** Update progress
			if "`showprogress'"=="" noisily display "Preparing sub-datasets"		
			if "`showprogress'"!="" noisily display "Preparing sub-dataset `dataset' of `datasetcount'"		
			
			
			preserve
				
				* Only keep the rows that correspond to the current sub-dataset
				keep if dataset==`dataset'
					
				* Create a separate variable for each variable that was changed
				split changes, parse(",") gen(change)
				drop changes
				
				
				* Clean change variables
				ds change*
				local varcount: word count `r(varlist)'
				
				if `varcount'>=2 {
					** Combine 'change' variables that have ben mistakenly split (e.g. because they contained a comma)
					forvalues i=2/`varcount' {
						local j=`i'-1
						replace change`i'=change`j'+change`i' if !ustrregexm(change`i',"^ [[:graph:]]* \= ") & change`i'!=""
						replace change`j'="" if substr(change`i',1,strlen(change`j'))==change`j'
					}
					
					** Move all changes to the leftmost 'change' variable, and leave the other 'change' variables blank
					forvalues i=2/`varcount' {
						local j=`i'-1
						replace change`j'=change`i' if change`j'==""
						replace change`i'="" if change`j'==change`i'
					}
					
					** Remove change variables with no data (e.g. because the data has been moved left)
					forvalues i=1/`varcount' {
						count if change`i'!=""
						if `r(N)'==0 drop change`i'
					}
				}
				

				* Reshape to long format (one row per log record per change)
				** Using expand is mch faster than reshape 
				egen changecount=rownonmiss(change*), strok
				expand changecount
				egen changeseq=seq(), by(order)
				
				summ changecount
				local maxchangecount=`r(max)'
				
				gen change=""
				forvalues i=1/`maxchangecount' {
					capture confirm variable change`i'
					if !_rc {
						replace change=change`i' if changeseq==`i'
					}
				}
			
				keep order recordid datetime date username action method dataset change changeseq
			
				** Save sub-dataset
				tempfile dataset`dataset'
				save "`dataset`dataset''", replace
				
			restore
			
		} // Close loop over datasets
			
			
		** Update progress
		noisily display "Combine all sub-datasets together..."	
		
		
		* Combine sub-datasets together
		clear
		forvalues dataset=1/`datasetcount' {
			append using "`dataset`dataset''"
		}
		
		
		** Update progress
		noisily display "Final clean of the data..."	
		
	
		* Create separate variables for variable changed, and new value
		split change, parse(" = ") gen(change)
		gen variable=change1
		gen value=change2
		
		* Sort data
		sort datetime order changeseq
		keep recordid date datetime username action method variable value
		order recordid date datetime username action method variable value
		
		
		** Compress data
		compress
		
		** Label variables
		label variable recordid "REDCap Record ID that was changed"
		label variable date "Date the change was made"
		label variable datetime "Date-time the change was made"
		label variable username "Who made the change"
		label variable action "Change made"
		label variable method "How was the change made"
		label variable variable "Variable changed"
		label variable value "New value"
		
		
		** Update progress
		noisily display "Done!"	
	
	}

end
