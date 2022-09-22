# install dependencies 
require(dplyr)
require(ggplot2)
require(readr)
require(formattable)
require(gt)

full_reformatted_data_path <- "./OutputData/FULL_redcap_data_reformatted.csv"
full_data <- read_csv(full_reformatted_data_path)

# make table including deltas for continuous variables 

## personal 
### height, weight, BMI

## Metabolic Markers 
### HDL, LDL, adiponectin, leptin, glucose, insulin, and tryglycerides 

## Inflmmatory markers 
### IL-6 


# tables of markers by week
## went from 273 obs to 244 obs 

full_data$Cohort

### get means by group 
summary_week <- full_data %>% 
  select(RecordID, SampleID, Cohort, Week, BMI..inclusion..between.21.and.29.kg.m2., HDL, LDL, Adiponectin, Glucose, 
         Insulin, Triglycerides)%>% 
  na.omit()%>% 
  group_by(Week, Cohort)%>% 
  summarise(across(BMI..inclusion..between.21.and.29.kg.m2.:Triglycerides, mean))

summary_week$Week[summary_week$Week == 1] <- "Week 1"
summary_week$Week[summary_week$Week == 2] <- "Week 2"
summary_week$Week[summary_week$Week == 3] <- "Week 3"

### transpose dataframe 
summary_week_colnames <- as.data.frame(colnames(summary_week))
colnames(summary_week_colnames) <- "Variable"
t_summary_week <- t(summary_week)
t_summary_week <- cbind(summary_week_colnames, t_summary_week)
rownames(t_summary_week) <- NULL
colnames(t_summary_week) <- c("Variable", "CohortA_1", "CohortB_1", "CohortC_1", 
                              "CohortA_2", "CohortB_2", "CohortC_2", 
                              "CohortA_3", "CohortB_3", "CohortC_3")
t_summary_week <- t_summary_week[-c(1,2),]

t_summary_week[2:10] <- lapply(t_summary_week[2:10], 
                               FUN = function(y){as.numeric(y)})
t_summary_week[2:10] <- lapply(t_summary_week[2:10], 
                               FUN = function(y){round(y, digits = 2)})




### get deltas 
t_summary_week$Week1_Week2 <- t_summary_week$Week2 - t_summary_week$Week1
t_summary_week$Week2_Week3 <- t_summary_week$Week3 - t_summary_week$Week2
t_summary_week$Week1_Week3 <- t_summary_week$Week3 - t_summary_week$Week1

### making it pretty 
improvement_formatter <- formatter("span", 
            style = x ~ style(
              font.weight = "bold", 
              color = ifelse(x > 0, "green", ifelse(x < 0, "red", "black"))))

formattable(t_summary_week, 
            align = c("l", "c", "c", "c", "c", "c"), 
            list(Variable = formatter("span", style = ~ style(color = "grey",font.weight = "bold")),
                 Week1_Week2 = improvement_formatter, 
                 Week2_Week3 = improvement_formatter, 
                 Week1_Week3 = improvement_formatter
                 ))

# making table with week and cohort 
summary_week %>% 
  gt(rowname_col = "Cohort", groupname_col = "Week") %>% 
  tab_header(
    title = md("Means of Metabolic Markers by Week and Cohort")
    )
  
t_summary_week %>% 
  gt(rowname_col = "Variable") %>% 
  tab_spanner(label = "Week 1", columns = c("CohortA_1","CohortB_1",'CohortC_1'))%>%
  tab_spanner(label = "Week 2", columns = c("CohortA_2","CohortB_2","CohortC_2"))%>%
  tab_spanner(label = "Week 3", columns = c("CohortA_3","CohortB_3","CohortC_3"))%>%
  tab_header(title = md("Means of Metabolic Markers by Week and Cohort")) %>%
  tab_source_note(md("Cohort A: HIV-positive individuals, Cohort B: HIV-negative high-risk individuals,
                     Cohort C: HIV-negative low-risk individuals"))


delta_summary <- t_summary_week%>% 
  mutate(A_2_1  = CohortA_2 - CohortA_1,
         A_3_2 = CohortA_3 - CohortA_2, 
         A_3_1 = CohortA_3 - CohortA_1, 
         B_2_1  = CohortB_2 - CohortB_1,
         B_3_2 = CohortB_3 - CohortB_2, 
         B_3_1 = CohortB_3 - CohortB_1,
         C_2_1  = CohortC_2 - CohortC_1,
         C_3_2 = CohortC_3 - CohortC_2, 
         C_3_1 = CohortC_3 - CohortC_1)%>%
  select(Variable,
         A_2_1, A_3_2, A_3_1,
         B_2_1, B_3_2, B_3_1,
         C_2_1, C_3_2, C_3_1)

rownames(delta_summary) <- NULL

delta_summary %>%
  gt(rowname_col = "Variable")%>%
  tab_spanner(label = "Cohort A", columns = c(A_2_1, A_3_2, A_3_1))%>%
  tab_spanner(label = "Cohort B", columns = c(B_2_1, B_3_2, B_3_1))%>%
  tab_spanner(label = "Cohort C", columns = c(C_2_1, C_3_2, C_3_1))%>%
  data_color(columns = vars(A_2_1:C_3_1), 
             colors = scales::col_bin(
               bins = c(-Inf, 0, Inf),
               palette = c("tomato", "yellowgreen")
             ))%>%
  tab_header(title = md("Deltas Between Time Points by Cohort"))%>%
  tab_source_note(md("*Key: A_2_1 = Week 2 mean - Week 1 mean "))
  
  
  
  
  
  
  
  


