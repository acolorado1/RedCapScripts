# install dependencies 


# get ID column that will be used as key
IDcolumn <- redcap_file$`Record ID`


# grab column number where each complete should occur
complete_column_numbers <- c()
headers <- colnames(redcap_file)
for(i in 1:length(headers)){
  if(nchar(headers[i])>8){
    if("Complete?" == substr(headers[i],1,9)){
      complete_column_numbers <- c(complete_column_numbers, i)
    }
  }
}


# list of indexes 
column_indexes <- c()
for(i in 1:length(complete_column_numbers)){ 
  if(i == 1){ 
    index <- c(2,complete_column_numbers[i])
    column_indexes <- c(column_indexes, index)
  }else{
      index <- c(complete_column_numbers[i-1]+1,complete_column_numbers[i])
      column_indexes <- c(column_indexes, index)
  }
  
}

# create global data frames containing each separate file 
Screen <- redcap_file[,c(column_indexes[1]: column_indexes[2])]
LifestyleQs <- redcap_file[,c(column_indexes[3]: column_indexes[4])]
Week0 <- redcap_file[,c(column_indexes[5]: column_indexes[6])]
GISymptoms0 <- redcap_file[,c(column_indexes[7]: column_indexes[8])]
Week2 <- redcap_file[,c(column_indexes[9]: column_indexes[10])]
GISymptoms2 <- redcap_file[,c(column_indexes[11]: column_indexes[12])]
Week4 <- redcap_file[,c(column_indexes[13]: column_indexes[14])]
GISymptoms4 <- redcap_file[,c(column_indexes[15]: column_indexes[16])]


# add ID column, remove 'complete?' column, remove numbers from columns names
# add week column and the sample ID column 
filenames_list <- list(Screen,LifestyleQs,Week0,GISymptoms0,
                  Week2,GISymptoms2,
                  Week4,GISymptoms4)

filenames_list <- lapply(1:length(filenames_list), function(i){ 
  df <- filenames_list[[i]]
  df <- df[1:length(df)-1]
  df <- data.frame(RecordID = IDcolumn, df, check.names = FALSE)
  columnanmes <- colnames(df)
  columnanmes <- gsub("\\.\\.\\.[0−9]*$","",columnanmes)
  colnames(df) <- columnanmes
  
  if(i == 4 || i == 3 ){
    df$Week <- 1
    df$SampleID <- paste(df$RecordID,".1", sep = "")
  }
  if(i == 6 || i == 5){
    df$Week <- 2
    df$SampleID <- paste(df$RecordID,".2", sep = "")
  }
  if(i == 8 || i == 7){
    df$Week <- 3
    df$SampleID <- paste(df$RecordID,".3", sep = "")
  }
  
  return(df)
  })

# update file names 
Screen <- filenames_list[[1]]
LifestyleQs <- filenames_list[[2]]
Week0 <- filenames_list[[3]]
GISymptoms0 <- filenames_list[[4]]
Week2 <- filenames_list[[5]]
GISymptoms2 <- filenames_list[[6]]
Week4 <- filenames_list[[7]]
GISymptoms4 <- filenames_list[[8]]




# list of individual files & write them into separate excel files 
filenames <- c("Screen", "LifestyleQs", "Week0", 
               "GISymptoms0", "Week2", "GISymptoms2", 
               "Week4", "GISymptoms4")

# merge GI symptoms - different time points 
GISymptomsAllTimes <- rbind(filenames_list[[4]],
                            filenames_list[[6]],
                            filenames_list[[8]])

for (i in 1:length(filenames)){ 
  write.csv(filenames_list[[i]],paste0("./OutputData/",filenames[i],".csv"), 
                                    row.names = F)
}

write.csv(GISymptomsAllTimes,"./OutputData/GISymptomsAllTimes.csv", 
          row.names = F)



# understand why week0, 2, and 4 do not share the same columns 
# this does not need to be redone as it was specific to understanding this data 
W0_colnames <- colnames(Week0)
W2_colnames <- colnames(Week2)
W4_colnames <- colnames(Week4)

outersect <- function(x, y){ 
  sort(c(x[!x%in%y], 
       y[!y%in%x]))
}

O_2_4 <- outersect(W2_colnames, W4_colnames)
O_0_4 <- outersect(W0_colnames, W4_colnames)
O_0_2 <- outersect(W0_colnames, W2_colnames)

outersect(O_0_2, O_0_4)


