#!/bin/bash

# Running simulations to create congestion window files
ns ../Reno/tcp_variants.tcl
ns ../Tahoe/tcp_variants.tcl
ns ../NewReno/tcp_variants.tcl


# Move congestion window files to current working directory 
cp ../Reno/WinFile_Reno ./
cp ../NewReno/WinFile_NewReno ./
cp ../Tahoe/WinFile_Tahoe ./

# Running xgraph to draw graphs of congestion windows
xgraph -color green WinFile_NewReno -color red WinFile_Reno -color blue WinFile_Tahoe -x_range 0 20 -title_x "Time (s)" -title_y "Window Size" -title "Comparison Between TCP Variants Congestion Window" -pdf 
mv plot.pdf compare.pdf
