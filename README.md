# redcap_logfile
Reads in a REDCap logging CSV file, and cleans it and converts it to long format (one row per record ID per variable changed)

There are two ways to use this package:
  1. Download the .ado and .sthlp files, and save them in your personal ADO folder. You can find where your personal ADO folder is located by typing sysdir in Stata
  2. Installing the command within Stata
  
    To install the command type:
    do "https://raw.githubusercontent.com/james-hedley/extract_notes/main/redcap_logfile.do"
    
    To view the help type:
    type "https://raw.githubusercontent.com/james-hedley/extract_notes/main/redcap_logfile.sthlp"
