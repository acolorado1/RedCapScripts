# Making RedCap files computer readable 
This set of scripts was used to make a longitudinal study done in RedCap more easy for programs to interpret.


## Workflow 

1. **DataReadInAndSummary.R** -> takes original data and I performed a sanity check 
2. **SeparateIndividualRecords.R** -> separates original file using the *Complete?* columns, here can individually export the files as CSV 
3. **CreateFullData.R** -> takes individual surveys and compiles them into one computer readable file 
4. **QueryData.R** -> make plots and tables of the data 




