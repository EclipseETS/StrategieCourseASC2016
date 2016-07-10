##import overpass
##api = overpass.API
##api.debug = True
##response = api.Get('node["name"="Salt Lake City"]')
##print (feature['tags']['name'], feature['id'])
##

import overpy

api = overpy.Overpass()

# fetch all ways and nodes

##result = api.query("""
##    way(50.746,7.154,50.748,7.157) ["highway"];
##    (._;>;);
##    out body;
##    """)
##
##for way in result.ways:
##    print("Name: %s" % way.tags.get("name", "n/a"))
##    print("  Highway: %s" % way.tags.get("highway", "n/a"))
##    print("  Nodes:")
##    for node in way.nodes:
##        print("    Lat: %f, Lon: %f" % (node.lat, node.lon))


##result = api.query("node(45.480,-73.540,45.485,-73.535);out;")
##len(result.nodes)
##len(result.ways)
##len(result.relations)
##node = result.nodes[2]
##print(node.id)
##print(node.tags)

lat = 41.31858
lon = -81.58776
precision = 15 ** -2
max_lat = lat + 5 * precision
min_lat = lat - 5 * precision
max_lon = lon + 5 * precision
min_lon = lon - 5 * precision


print('GPS : %f; %f ' %(lat, lon))
api = overpy.Overpass()
queryNode = "[out:xml];node['maxspeed'](%s, %s, %s, %s);out;" % ( min_lat, min_lon, max_lat, max_lon )
queryWay = "[out:xml];way['maxspeed'](%s, %s, %s, %s);out;" % ( min_lat, min_lon, max_lat, max_lon )
queryRel = "[out:xml];relation['maxspeed'](%s, %s, %s, %s);out;" % ( min_lat, min_lon, max_lat, max_lon )

resultNode = api.query(queryNode)
print(queryNode)
print(resultNode)
print(len(resultNode.nodes))
print(len(resultNode.relations))
print(len(resultNode.ways))

resultWay = api.query(queryWay)
print(queryWay)
print(resultWay)
print(len(resultWay.nodes))
print(len(resultWay.relations))
print(len(resultWay.ways))

resultRel = api.query(queryRel)
print(queryRel)
print(resultRel)
print(len(resultRel.nodes))
print(len(resultRel.relations))
print(len(resultRel.ways))

for x in resultWay.ways:
    print('Item:')
    print(x.tags['maxspeed'])
