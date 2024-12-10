# AWK File
# BEGIN{
# count1=0
# count2=0
# pack1=0
# pack2=0
# time1=0
# time2=0
# }
# {
# if($1=="r" && $3=="_1_" && $4=="AGT")
# {
# count1++
# pack1=pack1+$8
# time1=$2
# }
# if($1=="r" && $3=="_3_" && $4=="AGT")
# {
# count2++
# pack2=pack2+$8
# time2=$2
# }
# }
# END{
# printf(" The Throughput  from n0 to n1: %fMbps\n",((count1*pack1*8)/(time1*1000000)))
# printf(" The Throughput  from n2 to n3: %fMbps\n",((count2*pack2*8)/(time2*1000000)))
# }

# Initialization, Create a ns simulator
set ns [new Simulator]

# Open the NS trace file 
set tf [open p5.tr w]
$ns trace-all $tf

# Setup topography object
set topo [new Topography]
$topo load_flatgrid 700 700

# Open the NAM trace file
set nf [open p5.nam w]
$ns namtrace-all-wireless $nf 700 700

# Mobile node parameter setup
$ns node-config -adhocRouting DSDV \
                -llType LL \
                -ifqType Queue/DropTail \
                -macType Mac/802_11 \
                -ifqLen 50 \
                -phyType Phy/WirelessPhy \
                -channelType Channel/WirelessChannel \
                -propType Propagation/TwoRayGround \
                -antType Antenna/OmniAntenna \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace ON

# Create God object to manage movement patterns of mobile nodes
create-god 4


# The below code is used to create the nodes.
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# The below code is used to label the nodes.
$n0 label "tcp0"
$n1 label "sink1"
$n2 label "tcp1"
$n3 label "sink2"

# Set initial node positions
$n0 set X_ 50
$n0 set Y_ 50
$n0 set Z_ 0
$n1 set X_ 200
$n1 set Y_ 200
$n1 set Z_ 0
$n2 set X_ 400
$n2 set Y_ 400
$n2 set Z_ 0
$n3 set X_ 600
$n3 set Y_ 600
$n3 set Z_ 0

# Set node destinations
$ns at 0.1 "$n0 setdest 50 50 15"
$ns at 0.1 "$n1 setdest 200 200 25"
$ns at 0.1 "$n2 setdest 400 400 25"
$ns at 0.1 "$n3 setdest 600 600 25"

# TCP connections
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1
# Connecting the agents
$ns connect $tcp0 $sink1

set tcp1 [new Agent/TCP]
$ns attach-agent $n2 $tcp1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
set sink2 [new Agent/TCPSink]
$ns attach-agent $n3 $sink2
# Connecting the agents
$ns connect $tcp1 $sink2

# Start FTP traffic
$ns at 5 "$ftp0 start"
$ns at 10 "$ftp1 start"

# Node movement
$ns at 100 "$n2 setdest 500 500 25"

# Finish procedure to close files and open NAM
proc finish {} {
    global nf ns tf
    $ns flush-trace
    close $tf
    close $nf
    exec nam p5.nam &
    exit 0
}

$ns at 250 "finish"
$ns run