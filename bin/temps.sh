#!/usr/bin/env bash

lscpu | grep "CPU MHz"
sensors | grep -e °C -e RPM
echo "/dev/nvme0n1:"
nvme smart-log /dev/nvme0n1 | grep ^Temp
echo "/dev/nvme1n1:"
nvme smart-log /dev/nvme1n1 | grep ^Temp
