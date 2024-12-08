#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Wrong number of inputs"
	echo "Usage: $0 192.168.5.10 (Desired IP Address)"
	exit 1
fi

echo "New IP Address: $1"

vars_file="vars.xml"

sed -i "s/internal_rtp_ip=[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/internal_rtp_ip=$1/g" "$vars_file"
sed -i "s/external_rtp_ip=[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/external_rtp_ip=$1/g" "$vars_file"

sed -i "s/internal_sip_ip=[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/internal_sip_ip=$1/g" "$vars_file"
sed -i "s/external_sip_ip=[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/external_sip_ip=$1/g" "$vars_file"

sed -i "s/domain=[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/domain=$1/g" "$vars_file"

echo "Changed successfully"
exit 0
