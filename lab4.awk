BEGIN{
count=0;
}
{
if($1=="c")
count++;
}
END{
printf("\n The total Packet Collision %d\n",count);
}
