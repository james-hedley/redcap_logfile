{smcl}
{cmd:help redcap_logfile}
{hline}

{title:Title}

{p2col :{hi:redcap_logfile} {hline 2}}Reads in a REDCap logging CSV file, and cleans it and converts it to long format (one row per record ID per variable changed){p_end}


{title:Syntax}

{phang}{cmd:redcap_logfile} {it:filename} [, {opt clear} {opt MAXR:ows(positive integer)} {opt S:howprogress}]


{title:Description}

{phang}{cmd:redcap_logfile} Reads in a REDCap logging CSV file, and cleans it and converts it to long format (one row per record ID per variable changed)


{title:Options}

{phang}{it:filename} is the name of the REDCap logging CSV file to be cleaned

{phang}{opt clear} clear current dataset in memory

{phang}{opt maxrows(positive integer)} After loading the REDCap logging file to memory, the data will be split into sub-datasets with the specified number of rows. Logging files can be very large, and it is faster to split the data before cleaning and reshaping, and then put the data together again at the end. By default, maxrows will be set to sqrt(obs)*2.

{phang}{opt showprogress} clear current dataset in memory


{title:Author}

{pstd}James Hedley{p_end}
{pstd}Murdoch Children's Research Institute{p_end}
{pstd}Melbourne, VIC, Australia{p_end}
{pstd}{browse "mailto:james.hedley@mcri.edu.au":james.hedley@mcri.edu.au}
