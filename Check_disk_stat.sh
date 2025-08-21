#!/usr/bin/env bash


DISK="/dev/sdb"

if [ ! -b "$DISK" ]; then
	echo "Error: $DISK not found!"
	echo "Do NOT try to parition your main working disk!!☠️"
	exit 1
fi

# -b print in bytes
# -d only list the main devices not they're partitions 
# -n do not print the header
#

DISK_SIZE=$(lsblk -b -d -n -o SIZE "$DISK")
DISK_SIZE_GB=$((DISK_SIZE / 1024 / 1024 / 1024))

echo "Detected disk $DISK with size ${DISK_SIZE_GB}GB"

MIN_SIZE_GB=60
if [ "$DISK_SIZE_GB" -lt "$MIN_SIZE_GB" ]; then
	echo "Warning: Disk too small to install a full linux distro with a gui and  tools."
	echo "Recommended minimum: ${MIN_SIZE_GB}GB"
fi

# Print recommended partition sizes
echo ""
echo "Recommended partition sizes for $DISK:"
echo "----------------------------------------"
echo "/boot : 1 GB"
echo "/root : 40–50 GB"
echo "swap  : 2–8 GB (depending on RAM)"
echo "/home : Remaining space (optional, for user data)"
echo "----------------------------------------"
echo "Total recommended disk size: 60–80 GB for comfort"
