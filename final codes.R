library(openxlsx)
library(tidyverse)
library(plm)
library(stargazer)
library(sandwich)
library(clubSandwich)
library(ggcorrplot)
library(kableExtra)
library(lmtest)
library(car)

researchdata <- read.xlsx("Project_data.xlsx")

########
##median indicator approach##
data1 <- researchdata %>% select(nuts_code, year, total_pat, gdp_pc, new_firms, ht_total, rd_exp, ht_share)

##gdp_pc median input
data1 <- data1 %>% mutate(gdp_pc=ifelse(is.na(gdp_pc),
                                        median(gdp_pc, na.rm=T),
                                        gdp_pc))

##new firms median input
data1 <- data1 %>% mutate(new_firms=ifelse(is.na(new_firms),
                                           median(new_firms, na.rm=T),
                                           new_firms))

##tech emp median input
data1 <- data1 %>% mutate(ht_total=ifelse(is.na(ht_total),
                                          median(ht_total, na.rm=T),
                                          ht_total))
####control variables##
##employment share in high tech median input
data1 <- data1 %>% mutate(ht_share=ifelse(is.na(ht_share),
                                          median(ht_share, na.rm=T),
                                          ht_share))
##rd expenditure
data1 <- data1 %>% mutate(rd_exp=ifelse(is.na(rd_exp),
                                        median(rd_exp, na.rm=T),
                                        rd_exp))
##creating log of variables that was used in the model for descriptives###
data1$log_gdp_pc <- log(data1$gdp_pc)

data1$sqrt_total_pat <- data1$total_pat + sqrt(data1$total_pat^2 + 1)
data1$log_total_pat <- log(data1$sqrt_total_pat)

data1$new_firms1 <- data1$new_firms + 1
data1$log_new_firms <- log(data1$new_firms1)

data1$log_ht_total <- log(data1$ht_total)


###################descriptives############################
data1 %>% select(log_gdp_pc, log_total_pat, log_new_firms, log_ht_total, rd_exp, ht_share) %>% 
  data.frame() %>% stargazer(type="html",out="descriptivetable.html")

###creating new dataset to change names of columns####
data2 <- data1 %>% select(log_gdp_pc, log_total_pat, log_new_firms, log_ht_total, rd_exp, ht_share)

##renaming columns for correlation##
names(data2)[names(data2) == "log_gdp_pc"] <- " Log GDP Per Capita"
names(data2)[names(data2) == "log_total_pat"] <- "Log Total Patents"
names(data2)[names(data2) == "log_new_firms"] <- "Log New Firms"
names(data2)[names(data2) == "log_ht_total"] <- "Log Total Employment in High Tech"
names(data2)[names(data2) == "rd_exp"] <- "R&D Expenditure in €"
names(data2)[names(data2) == "ht_share"] <- "Share of Employment in High Tech"

library(sjPlot)
tab_corr(data2, triangle="lower", file="Correlation Table.html")

####regression################
#####gdp per pc regression#########
control_gdp_median <- lm(log(gdp_pc)~ht_share + rd_exp, data=data1)
gdp_base_median <- lm(log(gdp_pc)~log(new_firms+1) + log(ht_total), data=data1)
gdp_median_pool <- lm(log(gdp_pc)~log(new_firms+1) + log(ht_total) + ht_share + rd_exp, data=data1)
gdp_median_yearfe <- lm(log(gdp_pc)~log(new_firms+1) + log(ht_total) + ht_share + rd_exp + factor(year), data=data1)
gdp_median_fe <- lm(log(gdp_pc)~log(new_firms+1) + log(ht_total) + ht_share + rd_exp + factor(nuts_code) + factor(year), data=data1)

stargazer(gdp_base_median, control_gdp_median, gdp_median_pool, gdp_median_yearfe, type = "html", out = "gdpmedian1.html")
stargazer(gdp_median_fe, type="html", out="gdpfullfe.html")

vif_1 <- vif(gdp_median_yearfe)
mean(vif_1)
stargazer(vif_1, type="html", out="gdpvifmedian2.html")

#########total pat regression############
control_pat_median <- lm(log(total_pat + sqrt(total_pat^2 + 1))~ht_share + rd_exp, data=data1)
pat_base_median <- lm(log(total_pat + sqrt(total_pat^2 + 1))~log(new_firms+1) + log(ht_total), data=data1)
pat_median_pool <- lm(log(total_pat + sqrt(total_pat^2 + 1))~log(new_firms+1) + log(ht_total) + ht_share + rd_exp, data=data1)
pat_median_yearfe <- lm(log(total_pat + sqrt(total_pat^2 + 1))~log(new_firms+1) + log(ht_total) + ht_share + rd_exp + factor(year), data=data1)
pat_median_fe <- lm(log(total_pat + sqrt(total_pat^2 + 1))~log(new_firms+1) + log(ht_total) + ht_share + rd_exp + factor(nuts_code) + factor(year), data=data1)

stargazer(pat_base_median, control_pat_median, pat_median_pool, pat_median_yearfe, type = "html", out = "patmedian1.html")
stargazer(pat_median_fe, type="html", out="patfullfe.html")

vif_2 <- vif(pat_median_fe)
mean(vif_2)
stargazer(vif_2, type="html", out="patvifmedian.html")

#######lag gdp regression#########
lag_control_gdp_median <- lm(log(gdp_pc)~lag(gdp_pc, 1) + ht_share + rd_exp, data=data1)
lag_gdp_base_median <- lm(log(gdp_pc)~lag(gdp_pc, 1) + log(new_firms+1) + log(ht_total), data=data1)
lag_gdp_median_pool <- lm(log(gdp_pc)~ lag(gdp_pc, 1) + log(new_firms+1) + log(ht_total) + ht_share + rd_exp, data=data1)
lag_gdp_median_yearfe <- lm(log(gdp_pc)~lag(gdp_pc, 1) + log(new_firms+1) + log(ht_total) + ht_share + rd_exp + factor(year), data=data1)
lag_gdp_median_fe <- lm(log(gdp_pc)~lag(gdp_pc, 1) + log(new_firms+1) + log(ht_total) + ht_share + rd_exp + factor(nuts_code) + factor(year), data=data1)

stargazer(lag_gdp_base_median, lag_control_gdp_median, lag_gdp_median_pool, type = "html", out = "laggdpmedian1.html")
stargazer(lag_gdp_median_yearfe, lag_gdp_median_fe, type="html", out="laggdpfullfe.html")

vif_3 <- vif(gdp_median_fe)
mean(vif_3)
stargazer(vif_3, type="html", out="laggdpvifmedian2.html")

########year groups regression#######
########groups years#############
data1 <- data1 %>%
  mutate(group=ifelse(year <= 1987, "1", 
                      ifelse (year > 1987 & year <= 1998, "2", 
                      ifelse(year > 1998 & year <= 2009, "3", "4"))))

yeargroup1 <- data1[data1$group == "1",]
yeargroup2 <- data1[data1$group == "2",]
yeargroup3 <- data1[data1$group == "3",]
yeargroup4 <- data1[data1$group == "4",]

year1_fe <- lm(log(gdp_pc)~log(new_firms+1) + log(ht_total) + ht_share + rd_exp + factor(nuts_code) + factor(year), data=yeargroup1)
year2_fe <- lm(log(gdp_pc)~log(new_firms+1) + log(ht_total) + ht_share + rd_exp + factor(nuts_code) + factor(year), data=yeargroup2)
year3_fe <- lm(log(gdp_pc)~log(new_firms+1) + log(ht_total) + ht_share + rd_exp + factor(nuts_code) + factor(year), data=yeargroup3)
year4_fe <- lm(log(gdp_pc)~log(new_firms+1) + log(ht_total) + ht_share + rd_exp + factor(nuts_code) + factor(year), data=yeargroup4)

stargazer(year3_fe, year4_fe, type = "html", out="10yearperiods.html")

########didn't work#################
vif_4 <- vif(year1_fe)
vif_5 <- vif(year2_fe)
vif_6 <- vif(year3_fe)
vif_7 <- vif(year4_fe)
mean(vif_4)
stargazer(vif_4, vif_5, vif_6, vif_7, type="html", out="yearperiodsvifmedian.html")
#################################

####region cluster standard regression#####
clus1 <- coeftest(gdp_median_pool, vcovCL, cluster=data1$nuts_code)
clus2 <- coeftest(gdp_median_yearfe, vcovCL, cluster=data1$nuts_code)
clus3 <- coeftest(gdp_median_fe, vcovCL, cluster=data1$nuts_code)
stargazer(clus1, clus2, clus3, type = "html", out="gdpcluster.html")

clus4 <- coeftest(pat_median_pool, vcovCL, cluster=data1$nuts_code)
clus5 <- coeftest(pat_median_yearfe, vcovCL, cluster=data1$nuts_code)
clus6 <- coeftest(pat_median_fe, vcovCL, cluster=data1$nuts_code)
stargazer(clus4, clus5, clus6, type = "html", out = "patcluster.html")

clus7 <- coeftest(year1_fe, vcovCL, cluster=yeargroup1$nuts_code)
clus8 <- coeftest(year2_fe, vcovCL, cluster=yeargroup2$nuts_code)
clus9 <- coeftest(year3_fe, vcovCL, cluster=yeargroup3$nuts_code)
clus10 <- coeftest(year4_fe, vcovCL, cluster=yeargroup4$nuts_code)
stargazer(clus7, clus8, clus9, clus10, type = "html", out = "yearperiodscluster.html")

