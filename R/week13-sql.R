# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(keyring)
library(RMariaDB)

# Data Import and Cleaning
conn <- dbConnect(MariaDB(), #opening connection
                  user = "nakam087",
                  password=key_get("latis-mysql", "nakam087"),
                  host="mysql-prod5.oit.umn.edu",
                  port=3306,
                  ssl.ca='mysql_hotel_umn_20220728_interm.cer') #I put mine in the R folder so it would run 

show_data<- dbGetQuery(conn, "SHOW DATABASES;") #what databases
cla<-dbExecute(conn, "USE cla_tntlab;")

# Analysis
#number of managers
q1<-dbGetQuery(conn,
              "SELECT COUNT(*)
               FROM datascience_employees
               RIGHT JOIN datascience_testscores
               ON datascience_employees.employee_id=datascience_testscores.employee_id;")
q1
#number of unique managers
q2<-dbGetQuery(conn, 
               "SELECT COUNT(DISTINCT x.employee_id)
               FROM datascience_employees x
               RIGHT JOIN datascience_testscores y
               ON x.employee_id = y.employee_id;")
q2
#summary of number of managers split by location, not originally hired as managers
q3<-dbGetQuery(conn,
               "SELECT COUNT(*)
               FROM datascience_employees x
               RIGHT JOIN datascience_testscores y
               ON x.employee_id = y.employee_id
               WHERE x.manager_hire = 'N'
               GROUP BY x.city;")
q3
#mean + sd of number of years of employment by performance level
q4<-dbGetQuery(conn,
               "SELECT AVG(yrs_employed) AS mean_yrs, STDDEV(yrs_employed) AS sd_yrs
               FROM datascience_employees x
               RIGHT JOIN datascience_testscores y
               ON x.employee_id = y.employee_id
               GROUP BY performance_group;")
q4
#each manager's location classification (urban vs. suburban), ID number, and test score, in alphabetical order by location type and then descending order of test score.
q5<- dbGetQuery(conn,
             "SELECT type, x.employee_id, test_score
             FROM datascience_employees x
             RIGHT JOIN datascience_testscores y
             ON x.employee_id = y.employee_id
             LEFT JOIN datascience_offices z
             ON x.city = z.office
             ORDER BY type, test_score DESC;")
q5  
