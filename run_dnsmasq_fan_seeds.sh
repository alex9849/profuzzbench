#!/bin/bash

export PFBENCH=$(pwd)
export PATH=$PATH:$PFBENCH/scripts/execution:$PFBENCH/scripts/analysis

#profuzzbench_exec_common.sh lightftp 10 results-lightftp aflnet out-lightftp-aflnet "-m none -P FTP -D 10000 -q 3 -s 3 -E -K" 86400 5

profuzzbench_exec_common.sh dnsmasq-fan-seeds 6 dnsmasq-fan-seeds aflnet out-dnsmasq-aflnet "-m none -P DNS -D 10000 -K" 120 5
