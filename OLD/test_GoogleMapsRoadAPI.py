# Tests de l'API Google Maps Road

import requests

import googlemaps
from datetime import datetime

gmaps = googlemaps.Client(key='AIzaSyA0vGksajoG6TLrCJ5_CDcjZP7fy1AemzI')

# Geocoding an address
##geocode_result = gmaps.geocode('1600 Amphitheatre Parkway, Mountain View, CA')

# Look up an address with reverse geocoding
reverse_geocode_result = gmaps.reverse_geocode((45.483123, -73.538225))

print(reverse_geocode_result)

# Request directions via public transit
##now = datetime.now()
##directions_result = gmaps.directions("Sydney Town Hall",
##                                     "Parramatta, NSW",
##                                     mode="transit",
##                                     departure_time=now)
