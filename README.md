# redcap_logfile
Reads in a REDCap logging CSV file, and cleans it and converts it to long format (one row per record ID per variable changed)


There are three ways to install this package:
  1. Install within Stata using -net install
  
    net install redcap_logfile, from("https://raw.githubusercontent.com/james-hedley/redcap_logfile/main/")
  
  2. Download the .ado and .sthlp files, and save them in your personal ADO folder. You can find where your personal ADO folder is located by typing -sysdir- in Stata
 
  3. Manually install within Stata (if -net install- fails). To install the command and then view the help file type:
    
    do "https://raw.githubusercontent.com/james-hedley/redcap_logfile/main/redcap_logfile.do"
    
    type "https://raw.githubusercontent.com/james-hedley/redcap_logfile/main/redcap_logfile.sthlp"
