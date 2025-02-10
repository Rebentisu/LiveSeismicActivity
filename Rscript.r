# =========================================================
# LiveSeismicActivity - Real-Time Earthquake Visualization
# Fetch, process, and visualize seismic events in Amorgos & Santorini
# =========================================================

# 📦 Load Required Libraries
library(ggplot2)        # For data visualization
library(dplyr)          # For data manipulation
library(sf)             # For handling spatial data
library(readr)          # For reading structured text data
library(httr)           # For making HTTP requests
library(rnaturalearth)  # For fetching world map data
library(rnaturalearthdata) # Additional world map data
library(ggspatial)      # For spatial visualization enhancements
library(lubridate)      # For ymd_hms() function

# 🌍 Define Earthquake Data Source (Live API)
url <- "http://www.geophysics.geol.uoa.gr/stations/gmaps3/event_output2j.php?type=cat"

# 📥 Fetch Earthquake Data from the API
response <- GET(url)  # Send an HTTP GET request to retrieve data
eq_data_text <- content(response, "text", encoding = "UTF-8") # Extract response as text

# 📊 Read the data into a DataFrame
eq_data <- read.table(text = eq_data_text, header = TRUE, fill = TRUE)

# 🏷️ Rename columns for clarity
colnames(eq_data) <- c("Year", "Month", "Day", "Hour", "Minute", "Second", 
                       "Latitude", "Longitude", "Depth", "Magnitude", "RMS", 
                       "dx", "dy", "dz", "Np", "Na", "Gap")

# 🔢 Convert relevant columns to numeric values for proper calculations
eq_data <- eq_data %>%
  mutate(across(c(Year, Month, Day, Latitude, Longitude, Depth, Magnitude), as.numeric))

# 🕒 Filter for recent earthquakes (From February 1, 2025, onwards)
eq_data <- eq_data %>% filter(Year == 2025 & Month >= 2)

# 🗺️ Filter earthquakes **inside the black square region** (Amorgos & Santorini)
eq_data_filtered <- eq_data %>%
  filter(Latitude >= 35.5 & Latitude <= 37.2 & Longitude >= 24.8 & Longitude <= 26.5)

# 🎨 Define a more visually distinct color scale for Magnitude categories
magnitude_colors <- c(
  "Micro (1.0–1.9)" = "#ADD8E6",  # Light Blue
  "Minor (2.0–2.9)" = "#00CED1",  # Cyan
  "Slight (3.0–3.9)" = "#FFD700",  # Yellow
  "Light (4.0–4.9)" = "#FF8C00",  # Orange
  "Moderate (5.0–5.9)" = "#B22222"  # Dark Red
)

# 🏷️ **Assign Categories Based on Magnitude for Color Coding**
eq_data_filtered <- eq_data_filtered %>%
  mutate(
    Magnitude_Category = case_when(
      Magnitude >= 1.0 & Magnitude < 2.0 ~ "Micro (1.0–1.9)",
      Magnitude >= 2.0 & Magnitude < 3.0 ~ "Minor (2.0–2.9)",
      Magnitude >= 3.0 & Magnitude < 4.0 ~ "Slight (3.0–3.9)",
      Magnitude >= 4.0 & Magnitude < 5.0 ~ "Light (4.0–4.9)",
      Magnitude >= 5.0 & Magnitude < 6.0 ~ "Moderate (5.0–5.9)"
    )
  )

# Convert Magnitude_Category to a factor for **consistent ordering**
eq_data_filtered$Magnitude_Category <- factor(eq_data_filtered$Magnitude_Category, 
                                              levels = names(magnitude_colors))

# ✅ Convert the dataset into a spatial object (sf) AFTER adding `Magnitude_Category`
eq_data_sf <- st_as_sf(eq_data_filtered, coords = c("Longitude", "Latitude"), crs = 4326)

# 🌋 Identify the **strongest earthquake** (highest magnitude) so it appears on top
strongest_eq <- eq_data_filtered %>% filter(Magnitude == max(Magnitude))

# 🗺️ Load a **base world map** for reference
world <- ne_countries(scale = "medium", returnclass = "sf")

# 📍 **Plot Earthquake Locations with Magnitude-Based Coloring**
ggplot() +
  geom_sf(data = world, fill = "lightgray", color = "white") +  # Base map
  geom_sf(data = eq_data_sf %>% filter(!Magnitude == max(Magnitude)),  # Plot all earthquakes **except** the strongest first
          aes(size = Magnitude, fill = Magnitude_Category), alpha = 0.8, shape = 21, color = "black") +  
  geom_sf(data = st_as_sf(strongest_eq, coords = c("Longitude", "Latitude"), crs = 4326),  # Plot strongest earthquake **last**
          aes(size = Magnitude, fill = Magnitude_Category), alpha = 1, shape = 21, color = "black") +  
  scale_size_continuous(name = "Magnitude", range = c(3, 12), breaks = c(2, 3, 4, 5), labels = c("2.0", "3.0", "4.0", "5.0")) +  
  scale_fill_manual(name = "Magnitude Category", values = magnitude_colors) +  
  coord_sf(xlim = c(24.8, 26.5), ylim = c(35.5, 37.2), expand = FALSE) +  
  ggtitle("Earthquake activity (From Feb 1, 2025)") +
  theme_minimal() +
  guides(
    size = guide_legend(override.aes = list(shape = 21, fill = "white", color = "black", size = c(5, 7, 9, 11))),  
    fill = guide_legend(override.aes = list(size = 15))  # Bigger legend circles for color clarity
  )

# =====================
# TIMELINE PLOT
# =====================

# 🕒 Convert Date-Time Format for Time Series Plot
eq_data_filtered <- eq_data_filtered %>%
  mutate(
    Year = as.integer(Year),
    Month = as.integer(Month),
    Day = as.integer(Day),
    Hour = as.integer(Hour),
    Minute = as.integer(Minute),
    Second = as.integer(Second),
    DateTime = ymd_hms(sprintf("%04d-%02d-%02d %02d:%02d:%02d", Year, Month, Day, Hour, Minute, Second))
  )

# 📊 **Plot the Earthquake Timeline with Color-Coded Magnitude Categories** 
ggplot(eq_data_filtered, aes(x = DateTime, y = Magnitude, color = Magnitude_Category)) +
  geom_point(size = 2, alpha = 0.8) +  # Larger points for readability
  geom_smooth(aes(y = Magnitude), method = "loess", color = "black", size = 1, linetype = "solid", se = TRUE) +  # SE added
  scale_color_manual(name = "Magnitude Category", values = magnitude_colors) +  # Custom colors for categories
  labs(
    title = "Earthquake Timeline (From Feb 1, 2025)",
    subtitle = "",
    x = "Date & Time",
    y = "Magnitude"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Rotate x-axis labels for readability
    axis.text.y = element_text(size = 12),
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    legend.position = "none"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Rotate x-axis labels for readability
    axis.text.y = element_text(size = 12),
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    legend.position = "none"
  ) 

