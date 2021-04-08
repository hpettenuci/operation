#!/bin/ash

# Defaults
OSRM_DATA_PATH=${OSRM_DATA_PATH:="/osrm-data"}
OSRM_DATA_LABEL=${OSRM_DATA_LABEL:="data"}
OSRM_GRAPH_PROFILE=${OSRM_GRAPH_PROFILE:="car"}
OSRM_GRAPH_PROFILE_URL=${OSRM_GRAPH_PROFILE_URL:=""}
OSRM_PBF_URL=${OSRM_PBF_URL:="http://download.geofabrik.de/south-america/brazil-latest.osm.pbf"}
OSRM_MAX_TABLE_SIZE=${OSRM_MAX_TABLE_SIZE:="8000"}
OSRM_THREADS=${OSRM_THREADS:="4"}
OSRM_REFRESH_MAP=${OSRM_REFRESH_MAP=false}

_sig() {
  kill -TERM $child 2>/dev/null
}
trap _sig SIGKILL SIGTERM SIGHUP SIGINT EXIT

if ([ ! -f "$OSRM_DATA_PATH/$OSRM_DATA_LABEL.osrm" ]) || ([ $OSRM_REFRESH_MAP = true ]); then
    # Retrieve the PBF file
    curl -L $OSRM_PBF_URL --create-dirs -o $OSRM_DATA_PATH/$OSRM_DATA_LABEL.osm.pbf

    # Set the graph profile path
    OSRM_GRAPH_PROFILE_PATH="/osrm-profiles/$OSRM_GRAPH_PROFILE.lua"
    # If the URL to a custom profile is provided override the default profile
    if [ ! -z "$OSRM_GRAPH_PROFILE_URL" ]; then
        # Set the custom graph profile path
        OSRM_GRAPH_PROFILE_PATH="/osrm-profiles/custom-profile.lua"
        # Retrieve the custom graph profile
        curl -L $OSRM_GRAPH_PROFILE_URL --create-dirs -o $OSRM_GRAPH_PROFILE_PATH
    fi

    # Build the graph
    osrm-extract $OSRM_DATA_PATH/$OSRM_DATA_LABEL.osm.pbf -p $OSRM_GRAPH_PROFILE_PATH
    osrm-contract $OSRM_DATA_PATH/$OSRM_DATA_LABEL.osrm
fi 
# Start serving requests
osrm-routed $OSRM_DATA_PATH/$OSRM_DATA_LABEL.osrm --max-table-size $OSRM_MAX_TABLE_SIZE --threads $OSRM_THREADS &
child=$!
wait "$child"