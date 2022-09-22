# check dependencies 
require(readr)

# path to redcap file and readin 
filepath <- "./DietModificationStud_DATA_LABELS_2020-07-07_1722.csv"
redcap_file <- read_csv(filepath)

# sanity checks 
# this data set should have 8 complete columns 
# should have 3 HDL columns  
# NOTE: problem discovered, R has automatically added column number to
#       column name. e.g HDL...126 because of duplicate columns 

headers <- colnames(redcap_file)
headers_df <- as.data.frame(headers) # search through this dataframe in R 



