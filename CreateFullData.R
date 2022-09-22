# install dependencies 
require(dplyr)


# address the Week survey differences 
## First: rename Date of visit columns to something that is uniform
colnames(Week0)[2] <- "DateOfVisit"
colnames(Week2)[2] <- "DateOfVisit"
colnames(Week4)[2] <- "DateOfVisit"

### had to change this for consistency 
colnames(Week0)[29] <- "Date.blood.collected.for.chronic.immune.activation..HLADR.CD38...mm.dd.yyyy."

## Second: Find colnames intersect and rbind this data frame 
W0_colnames <- colnames(Week0)
W2_colnames <- colnames(Week2)
W4_colnames <- colnames(Week4)

colnames_intersect <- intersect(W4_colnames, W2_colnames)
colnames_intersect <- intersect(colnames_intersect, W0_colnames)

W0_sub_int <- Week0[, colnames_intersect]
W2_sub_int <- Week2[, colnames_intersect]
W4_sub_int <- Week4[, colnames_intersect]

sub_int_total  <- rbind(W0_sub_int, W2_sub_int, W4_sub_int)

## Third: get the columns that did not intersect 
colnames_outersect  <- colnames_intersect[2:length(colnames_intersect)] # removes recordID 
W0_sub_out <- Week0[, -which(names(Week0) %in% colnames_outersect)]
W2_sub_out <- Week2[, -which(names(Week2) %in% colnames_outersect)]
W4_sub_out <- Week4[, -which(names(Week4) %in% colnames_outersect)]

# discovered this set of columns that should have been the same 
'W0_sub_out$Date.blood.was.collected.for.chronic.immune.activation..HLADR.CD38...mm.dd.yyyy.
W2_sub_out$Date.blood.collected.for.chronic.immune.activation..HLADR.CD38...mm.dd.yyyy.
W4_sub_out$Date.blood.collected.for.chronic.immune.activation..HLADR.CD38...mm.dd.yyyy.'


# merge all data 
full_merge <- GISymptomsAllTimes %>% 
  full_join(Screen, by = "RecordID")%>% 
  full_join(LifestyleQs, by = "RecordID")%>% 
  full_join(W0_sub_out, by = "RecordID") %>% 
  full_join(W4_sub_out, by = "RecordID") %>% 
  full_join(sub_int_total, by = "SampleID")    # different join by 

cols_full <- colnames(full_merge)
View(as.data.frame(cols_full))

# remove repeated columns that occurred because of the different joins:
# RecordID and Week (.x and .y) 
# rename .x and remove .y 

full_merge <- subset(full_merge, select = -c(RecordID.y, Week.y))
colnames(full_merge)[1] <- "RecordID"
colnames(full_merge)[25] <- "Week"


# export as CVS file 
write.csv(full_merge,"./OutputData/FULL_redcap_data_reformatted.csv", 
          row.names = F)




