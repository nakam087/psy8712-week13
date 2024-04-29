# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(keyring)
library(RMariaDB)
library(tidyverse)

# Data Import and Cleaning
conn <- dbConnect(MariaDB(), #opening connection
                  user = "nakam087",
                  password=key_get("latis-mysql", "nakam087"),
                  host="mysql-prod5.oit.umn.edu",
                  port=3306,
                  ssl.ca='mysql_hotel_umn_20220728_interm.cer')

show_data<- dbGetQuery(conn, "SHOW DATABASES;") #what databases
cla<-dbExecute(conn, "USE cla_tntlab;")
get_tables<-dbGetQuery(conn, "SHOW TABLES") #what tables in cla tnt lab
#selecting specific tables we want
employee<-dbGetQuery(conn, "SELECT * FROM datascience_employees") 
office<-dbGetQuery(conn, "SELECT * FROM datascience_offices")
testscore<-dbGetQuery(conn, "SELECT * FROM datascience_testscores")
#creating tibbles
employees_tbl<-tibble(employee)
testscores_tbl<-tibble(testscore)
offices_tbl<-tibble(office)

#creating week13_tbl
week13_tbl<-left_join(testscores_tbl, employees_tbl, by=join_by(employee_id))%>% #left join keeps all scores in x
  left_join(offices_tbl, by=join_by(city==office)) #had to specify because columns were differently named

#creating csv files
#write_csv(employees_tbl,"employees.csv")
#write_csv(testscores_tbl,"testscores.csv")
#write_csv(offices_tbl,"offices.csv")
#write_csv(week13_tbl, "week13.csv")

# Analysis
#number of managers
q1<-week13_tbl%>% #total number including ones without test score?
  count()
q1
#number of unique managers
q2<-week13_tbl%>%
  n_distinct()
q2
#summary of number of managers split by location, not originally hired as managers
q3<-week13_tbl%>%
  group_by(city)%>%
  filter(manager_hire=="N")%>%
  count()
q3
#mean + sd of number of years of employment by performance level
q4<-week13_tbl%>%
  group_by(performance_group)%>%
  summarise(avg=mean(yrs_employed),
            sd=sd(yrs_employed))
q4
#each manager's location classification (urban vs. suburban), ID number, and test score, in alphabetical order by location type and then descending order of test score.
q5<- week13_tbl%>%
  arrange(type, desc(test_score))%>%
  select(type,employee_id,test_score)
q5  
