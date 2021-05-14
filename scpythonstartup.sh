#!/bin/bash

#start up jack, startup sc server and synthdefs, run python code for sensor triggers

qjackctl --start &
sclang scpythontests.scd &
python3 scpython.py &
