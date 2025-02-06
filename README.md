🌍 Overview
LiveSeismicActivity is an R-based script that fetches, processes, and visualizes real-time earthquake data from the Amorgos & Santorini region. It retrieves seismic activity from an online seismological network, categorizes earthquakes by magnitude, and generates easy-to-read visualizations.

This dataset includes earthquakes recorded between February 1, 2025, and February 6, 2025 (3:00 PM UTC).

📊 What It Does
✔️ Retrieves earthquake data from a live API
✔️ Filters events occurring within the Amorgos & Santorini region
✔️ Creates visualizations to analyze seismic activity
✔️ Saves plots for further examination

What It Produces
📍 Earthquake Map (earthquake_map.png)

Displays earthquake locations
Size of points represents magnitude
Color-coded categories based on magnitude
📊 Earthquake Timeline (earthquake_timeline.png)

Shows how earthquake magnitudes change over time
Includes a trendline to highlight seismic patterns
📑 Combined Grid Plot (earthquake_combined.png)

Side-by-side visualization of the map and timeline for better comparison
🏷️ Magnitude Categories & Colors
Magnitude Range	Category	Color
1.0 – 1.9	Micro	Light Blue (#ADD8E6)
2.0 – 2.9	Minor	Cyan (#00CED1)
3.0 – 3.9	Slight	Yellow (#FFD700)
4.0 – 4.9	Light	Orange (#FF8C00)
5.0 – 5.9	Moderate	Dark Red (#B22222)
📈 Data Source
Greek Seismological Network
🔗 http://www.geophysics.geol.uoa.gr/
Date Range Covered:
🗓 February 1, 2025 – February 6, 2025 (3:00 PM UTC)
🚀 This script provides a simple and clear way to track and analyze real-time seismic activity!

## 📊 Example Output

The image below shows an **example of earthquake activity recorded between February 1, 2025, and February 6, 2025 (3:00 PM UTC)**.
It includes a **map of earthquake locations** and a **timeline of magnitude trends**.

![Example Earthquake Data](https://raw.githubusercontent.com/Rebentisu/LiveSeismicActivity/main/earthquakedata_example.png)

