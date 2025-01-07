BEGIN {pktdrp = 0;}
{
event = $1;
if(event == "d"){
pktdrp++;
}
}
END {
printf("The number of packets dropped is %d\n" , pktdrp);
}
