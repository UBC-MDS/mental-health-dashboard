# reading and saving the raw datasets 

mental_health_data <- read.csv("https://raw.githubusercontent.com/owid/owid-datasets/refs/heads/master/datasets/Suicide%20rates%20by%20sex%20and%20age%20(IHME%2C%202019)/Suicide%20rates%20by%20sex%20and%20age%20(IHME%2C%202019).csv")
write.csv(mental_health_data, "./data/raw/mental_health_data.csv", row.names = FALSE)

country_coords <- read.csv("https://gist.githubusercontent.com/metal3d/5b925077e66194551df949de64e910f6/raw/c5f20a037409d96958553e2eb6b8251265c6fd63/country-coord.csv")
write.csv(country_coords, "./data/raw/country_coords.csv", row.names = FALSE)
