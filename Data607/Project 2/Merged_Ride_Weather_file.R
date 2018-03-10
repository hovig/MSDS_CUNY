merged_ride_data_1 <- read.csv("merged_ride_weather_data_part_1.csv")
merged_ride_data_2 <- read.csv("merged_ride_weather_data_part_2.csv")

merged_ride_data <- merged_ride_data_1
merged_ride_data <- rbind(merged_ride_data,merged_ride_data_2)

library(dplyr)

merged_ride_data_lat_long <- merged_ride_data %>%
                              group_by(end_location_lat,end_location_long) %>%
                              summarize(count = n())
                              
merged_ride_data_lat_long_ord <- merged_ride_data_lat_long[with(merged_ride_data_lat_long,
                                                                order(-count)),]

merged_ride_data_lat_long_ord_sub <- merged_ride_data_lat_long_ord[1:20,]

merged_ride_data_by_rider <-  merged_ride_data %>%
                              group_by(rider_id) %>%
                              summarize(count = n())



merged_ride_data_by_rider$is_local <- ifelse(merged_ride_data_by_rider$count >5,1,0)

merged_ride_data_by_rider_sub <- merged_ride_data_by_rider[,c('rider_id',
                                                              'is_local')]
merged_ride_data_by_rider_is_local <- merge(merged_ride_data,
                                            merged_ride_data_by_rider_sub,
                                            by = 'rider_id',
                                            all.x = TRUE)
# Revenue from local riders
percent_revenue_from_local_riders <- 
  (sum(merged_ride_data_by_rider_is_local[merged_ride_data_by_rider_is_local$is_local == 1,'total_fare'],na.rm = TRUE)/
         sum(merged_ride_data_by_rider_is_local$total_fare,na.rm = TRUE))*100
  

# Visualizing the number of rides
library(ggplot2)

# merged_ride_data_by_rider$number_of_ride_brackets <- 
#   ifelse(merged_ride_data_by_rider$count == 1,"1",
#          ifelse(merged_ride_data_by_rider$count >=2 && merged_ride_data_by_rider$count <= 5,
#                 "2-5",
#                 ifelse(merged_ride_data_by_rider$count >=6 && merged_ride_data_by_rider$count <= 20,"6-20","20+")))

merged_ride_data_by_rider$number_of_ride_brackets <-
  ifelse(merged_ride_data_by_rider$count == 1,"1",
         ifelse(merged_ride_data_by_rider$count <= 5,"2-5",
                ifelse(merged_ride_data_by_rider$count <= 20,"6-20","20+")))

merged_ride_data_by_rider$number_of_ride_brackets <- as.factor(merged_ride_data_by_rider$number_of_ride_brackets)

merged_ride_data_by_rider$number_of_ride_brackets <- factor(merged_ride_data_by_rider$number_of_ride_brackets,
                                                               levels = c("1","2-5","6-20","20+"))

merged_ride_data_by_rider$local_or_not <- 
  ifelse(merged_ride_data_by_rider$count <= 5,"Not Local","Local")

g <- ggplot(data = merged_ride_data_by_rider, aes(local_or_not))

g + geom_bar() + labs(x="Number of rides",y="Number of riders",
                      title = "Rider distribution by number of rides")
