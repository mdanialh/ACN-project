# Create a simulator instance
set ns [new Simulator]


# Color
$ns color 0 Blue
$ns color 1 Red
$ns color 2 Green
$ns color 3 Orange
$ns color 4 Pink






# Open trace and NAM files
set tracefile [open tcp_analysis.tr w]
$ns trace-all $tracefile
set namfile [open tcp_analysis.nam w]
$ns namtrace-all $namfile
#ns trace-queue-all $tracefile
set winfile0 [open WinFile_Tahoe w]

# Create nodes
set n0 [$ns node]    ;# Source 1
set n1 [$ns node]    ;# Source 2
set n2 [$ns node]    ;# Source 3
set n3 [$ns node]    ;# Source 4
set n4 [$ns node]    ;# Source 5
set rA [$ns node]    ;# Router A
set rB [$ns node]    ;# Router B
set d0 [$ns node]    ;# Destination 1
set d1 [$ns node]    ;# Destination 2
set d2 [$ns node]    ;# Destination 3

# Create links with explicit queue configurations
$ns duplex-link $n0 $rA 10Mb 10ms DropTail  ;# Queue size will be defined below
$ns duplex-link $n1 $rA 10Mb 10ms DropTail
$ns duplex-link $n2 $rA 10Mb 10ms DropTail
$ns duplex-link $n3 $rA 10Mb 10ms DropTail
$ns duplex-link $n4 $rA 10Mb 10ms DropTail
$ns duplex-link $rA $rB 1Mb  20ms DropTail  ;# Bottleneck link
$ns duplex-link $rB $d0 10Mb 10ms DropTail
$ns duplex-link $rB $d1 10Mb 10ms DropTail
$ns duplex-link $rB $d2 10Mb 10ms DropTail

# labels
$ns at 0.0 "$n0 label source1"
$ns at 0.0 "$n1 label source2"
$ns at 0.0 "$n2 label source3"
$ns at 0.0 "$n3 label source4"
$ns at 0.0 "$n4 label source5"
$ns at 0.0 "$rA label A"
$ns at 0.0 "$rB label B"
$ns at 0.0 "$d0 label dest1"
$ns at 0.0 "$d1 label dest2"
$ns at 0.0 "$d2 label dest3"


$ns queue-limit $rA $rB 10


# Monitor the queue for the link between node A and node B
$ns duplex-link-op $rA $rB queuePos 0.5

# setting some parameters 
Agent/TCP set window_ 65000
Agent/TCP set overhead_ 0

# Create TCP agents and sinks for Flow 1
set tcp0 [new Agent/TCP ]
$tcp0 set class_ TCP/Tahoe 
$tcp0 set fid_ 0       ;
$tcp0 set packetSize_ 960
$ns attach-agent $n0 $tcp0


set sink0 [new Agent/TCPSink]
$ns attach-agent $d0 $sink0
$ns connect $tcp0 $sink0

# Create TCP agents and sinks for Flow 2
set tcp1 [new Agent/TCP ]
$tcp1 set class_ TCP/Tahoe 
$tcp1 set fid_ 1        ;
$tcp1 set packetSize_ 960
$ns attach-agent $n1 $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $d1 $sink1
$ns connect $tcp1 $sink1

# Create TCP agents and sinks for Flow 3
set tcp2 [new Agent/TCP ]
$tcp2 set class_ TCP/Tahoe 
$tcp2 set fid_ 2        ;
$tcp2 set packetSize_ 960
$ns attach-agent $n2 $tcp2

set sink2 [new Agent/TCPSink]
$ns attach-agent $d1 $sink2
$ns connect $tcp2 $sink2

# Create TCP agents and sinks for Flow 3
set tcp3 [new Agent/TCP ]
$tcp3 set class_ TCP/Tahoe 
$tcp3 set fid_ 3      ;
$tcp3 set packetSize_ 960
$ns attach-agent $n3 $tcp3


set sink3 [new Agent/TCPSink]
$ns attach-agent $d0 $sink3
$ns connect $tcp3 $sink3

# Create TCP agents and sinks for Flow 3
set tcp4 [new Agent/TCP  ]
$tcp4 set class_ TCP/Tahoe 
$tcp4 set fid_ 4        ;
$tcp4 set packetSize_ 960
$ns attach-agent $n4 $tcp4


set sink4 [new Agent/TCPSink]
$ns attach-agent $d2 $sink4
$ns connect $tcp4 $sink4

# some traces
$tcp0 attach $tracefile
$tcp0 tracevar cwnd_
$tcp0 tracevar ssthresh_
$tcp0 tracevar ack_
$tcp0 tracevar maxseq_

$tcp1 attach $tracefile
$tcp1 tracevar cwnd_
$tcp1 tracevar ssthresh_
$tcp1 tracevar ack_
$tcp1 tracevar maxseq_

$tcp2 attach $tracefile
$tcp2 tracevar cwnd_
$tcp2 tracevar ssthresh_
$tcp2 tracevar ack_
$tcp2 tracevar maxseq_

$tcp3 attach $tracefile
$tcp3 tracevar cwnd_
$tcp3 tracevar ssthresh_
$tcp3 tracevar ack_
$tcp3 tracevar maxseq_

$tcp4 attach $tracefile
$tcp4 tracevar cwnd_
$tcp4 tracevar ssthresh_
$tcp4 tracevar ack_
$tcp4 tracevar maxseq_


# Attach FTP applications to TCP agents for concurrent flows
set ftp0 [new Application/FTP]
$ftp0 set interval_ 0
$ftp0 attach-agent $tcp0


set ftp1 [new Application/FTP]
$ftp1 set interval_ 0
$ftp1 attach-agent $tcp1

set ftp2 [new Application/FTP]
$ftp2 set interval_ 0
$ftp2 attach-agent $tcp2

set ftp3 [new Application/FTP]
$ftp3 set interval_ 0
$ftp3 attach-agent $tcp3

set ftp4 [new Application/FTP]
$ftp4 set interval_ 0
$ftp4 attach-agent $tcp4

# Start FTP traffic at overlapping times for competition
$ns at 0 "$ftp0 start"
$ns at 0 "$ftp1 start"
$ns at 0 "$ftp2 start"
$ns at 0 "$ftp3 start"
$ns at 0 "$ftp4 start"

# Stop FTP traffic
$ns at 300 "$ftp0 stop"
$ns at 300 "$ftp1 stop"
$ns at 300 "$ftp2 stop"
$ns at 300 "$ftp3 stop"
$ns at 300 "$ftp4 stop"

# Define finish procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam tcp_analysis.nam 
    exec xgraph WinFile_Tahoe -x_range 0 20  -pdf -title_x "Time (s)" -title_y "Window Size" -title "Tahoe Congestion Window"
    exec mv plot.pdf cwnd_graph.pdf
    exec awk -f drop.awk tcp_analysis.tr > dropped.out 
    exec awk -f avgStats.awk src=0 dst=7 flow=0 pkt=1000 tcp_analysis.tr > avgTCP.out &
    exit 0
}


proc plotWindow { tcpSource file } {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
set wnd [$tcpSource set window_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 0 "plotWindow $tcp0 $winfile0" 



# End the simulation after 10 seconds
$ns at 300 "finish"

# Run the simulation
$ns run
