# Filter GTFS for bounding box

# libraries
library(tidyverse)
library(gtfsr)


# load gtfs
oepnv <- import_gtfs("PATH TO FILE.gtfs.zip", local = TRUE)

# Split txt files into separate dataframes

  #mandatory
agency <- oepnv$agency_df
routes <- oepnv$routes_df
trips <- oepnv$trips_df
stop_times <- oepnv$stop_times_df
stops <- oepnv$stops_df

  #optional 
if (is.data.frame(oepnv$calendar_dates_df)) {calendar_dates <- oepnv$calendar_dates_df}
if (is.data.frame(oepnv$calendar_df)) {calendar <- oepnv$calendar_df}
if (is.data.frame(oepnv$feed_info_df)) {feed_info <- oepnv$feed_info_df}
if (is.data.frame(oepnv$shapes_df)) {shapes <- oepnv$shapes_df}


# define bounding box (e.g. at http://bboxfinder.com/#11.243957,47.966225,11.980041,48.292362)
# EMM+50km: 9.8053665,47.0885227,13.417136,49.3811241 

bbox = c(9.8053665,47.0885227,13.417136,49.3811241)


# filter step by step through the data, starting with stops that are within the bbox

stops %>% filter(between(stop_lon, bbox[1], bbox[3]) & between(stop_lat, bbox[2], bbox[4]) ) -> stops

stop_times %>% filter(stop_id %in% stops$stop_id) -> stop_times

trips %>% filter(trip_id %in% stop_times$trip_id) -> trips

routes %>% filter(route_id %in% trips$route_id) -> routes

if (is.data.frame(oepnv$calendar_dates_df)) {
calendar_dates %>% filter(service_id %in% trips$service_id) -> calendar_dates }

if (is.data.frame(oepnv$calendar_df)) {
calendar %>% filter(service_id %in% trips$service_id) -> calendar }

if (is.data.frame(oepnv$shapes_df)) {
  shapes %>% filter(between(shape_pt_lon, bbox[1], bbox[3]) & between(shape_pt_lat, bbox[2], bbox[4]) ) -> shapes }  


# change calendar dates to make the analysis work for a longer timeframe (loosing some accuracy here!)
calendar %>% mutate(start_date = "20200101") %>%  mutate(end_date = "20251231") -> calendar


#export as txt

write.table(agency, "PATH-TO-FOLDER/agency.txt", sep=",", row.names = FALSE, quote = FALSE, fileEncoding = "UTF-8")
write.table(routes, "PATH-TO-FOLDER/routes.txt", sep=",", row.names = FALSE, quote = FALSE, fileEncoding = "UTF-8")
write.table(trips, "PATH-TO-FOLDER/trips.txt", sep=",", row.names = FALSE, quote = FALSE, fileEncoding = "UTF-8")
write.table(stop_times, "PATH-TO-FOLDER/stop_times.txt", sep=",", row.names = FALSE, quote = FALSE,fileEncoding = "UTF-8")
write.table(stops, "PATH-TO-FOLDER/stops.txt", sep=",", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")
#write.table(transfers, "PATH-TO-FOLDER/transfers.txt", sep=",", row.names = FALSE, quote = FALSE, fileEncoding = "UTF-8")

if (is.data.frame(oepnv$calendar_dates_df)) {
  write.table(calendar_dates, "PATH-TO-FOLDER/calendar_dates.txt", sep=",", row.names = FALSE, quote = FALSE, fileEncoding = "UTF-8") }
if (is.data.frame(oepnv$calendar_df)) {
  write.table(calendar, "PATH-TO-FOLDER/calendar.txt", sep=",", row.names = FALSE, quote = FALSE, fileEncoding = "UTF-8") }
if (is.data.frame(oepnv$feed_info_df)) {
  write.table(feed_info, "PATH-TO-FOLDER/feed_info.txt", sep=",", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8") }
if (is.data.frame(oepnv$shapes_df)) {
  write.table(shapes, "PATH-TO-FOLDER/shapes.txt", sep=",", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8") }
    

######### then: create ZIP manually ######### 








