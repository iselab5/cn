# AWK File
# BEGIN{
# count=0;
# }
# {
# if($1=="c")
# count++;
# }
# END{
# printf("\n The total Packet Collision %d\n",count);
# }

# Initialization, Create a ns simulator
set ns [new Simulator]

# Open the NS trace file & NAM trace file 
set tf [open p4.tr w]
$ns trace-all $tf
set nf [open p4.nam w]
$ns namtrace-all $nf

# The below code is used to create the nodes.
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# Create LAN
# Change the values below for the table
$ns make-lan -trace on "$n0 $n1 $n2 $n3 $n4" 100Mb 10ms LL Queue/DropTail Mac/802_3

# The below code is used to give color the nodes. 
$ns color 1 "red"
$ns color 2 "blue"
$ns color 3 "green"

# Agent & Application Definition of TCP Connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
set sink2 [new Agent/TCPSink]
$ns attach-agent $n2 $sink2
# Connecting the agents
$ns connect $tcp0 $sink2
# Agent & Application Definition of UDP Connection
set udp2 [new Agent/UDP]
$ns attach-agent $n2 $udp2
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
set null1 [new Agent/Null]
$ns attach-agent $n1 $null1
# Connecting the agents
$ns connect $udp2 $null1

# To set color to packets 
$udp2 set class_ 1
$tcp0 set class_ 2

# Agent & Application Definition of TCP Connection
set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
set sink3 [new Agent/TCPSink]
$ns attach-agent $n3 $sink3
# Connecting the agents
$ns connect $tcp1 $sink3

# To set color to packets 
$tcp1 set class_ 3

# The below code is used to set the interval size of packets
$ftp0 set interval_ 0.001
$cbr2 set interval_ 0.001
$ftp1 set interval_ 0.01

# Termination defining a ‘finish’ procedure
proc finish {} {
global ns nf tf
$ns flush-trace
exec nam p4.nam &
close $tf
close $nf
exit 0
}

$ns at 0.1 "$cbr2 start"
$ns at 1.2 "$ftp1 start"
$ns at 1.3 "$ftp0 start"
$ns at 9.5 "$cbr2 stop"
$ns at 9.5 "$ftp1 stop"
$ns at 10.0 "finish"
$ns run