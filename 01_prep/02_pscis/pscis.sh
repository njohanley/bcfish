#!/bin/bash
set -euxo pipefail

# load the CWF generated PSCIS - stream - modelled crossing lookup table
# this matches all PSCIS crossings (as of July 2020) to streams/modelled crossings where possible
# null values indicate that the PSCIS crossing does not match to a FWA stream
psql -c "DROP TABLE IF EXISTS bcfishpass.pscis_modelledcrossings_streams_xref"
psql -c "CREATE TABLE bcfishpass.pscis_modelledcrossings_streams_xref
        (stream_crossing_id integer PRIMARY KEY,
         modelled_crossing_id integer,
         linear_feature_id integer,
         watershed_group_code text,
         reviewer text,
         notes text)"
psql -c "\copy bcfishpass.pscis_modelledcrossings_streams_xref FROM 'data/pscis_modelledcrossings_streams_xref.csv' delimiter ',' csv header"

# load the CWF generated PSCIS fixes table
# (noting OBS barriers, non-accessible streams etc)
psql -c "DROP TABLE IF EXISTS bcfishpass.pscis_barrier_result_fixes"
psql -c "CREATE TABLE bcfishpass.pscis_barrier_result_fixes (
         stream_crossing_id integer PRIMARY KEY,
         updated_barrier_result_code text,
         watershed_group_code text,
         reviewer text,
         notes text)"
psql -c "\copy bcfishpass.pscis_barrier_result_fixes FROM 'data/pscis_barrier_result_fixes.csv' delimiter ',' csv header"

psql -f sql/01_pscis_points_all.sql
psql -f sql/02_pscis_events_prelim1.sql
psql -f sql/03_pscis_events_prelim2.sql
psql -f sql/04_pscis_events.sql
psql -f sql/05_pscis_points_duplicates.sql
