$processler = Get-Process | Select-Object Id, Name;
$portlarAlinacak = netstat -ano;
$part1 = $portlarAlinacak[4..$portlarAlinacak.count] | ConvertFrom-String | Select-Object p3,p4,p5,p6 | Where-object{$_.p5 -eq "LISTENING" -or $_.p5 -eq "CLOSE_WAIT" -or $_.p5 -eq "ESTABLISHED" -or $_.p5 -eq "TIME_WAIT"};
#idler p6'da
$part2 = $portlarAlinacak[4..$portlarAlinacak.count] | ConvertFrom-String | Select-Object p3,p4,p5,p6 | Where-object{$_.p5 -ne "LISTENING" -and $_.p5 -ne "CLOSE_WAIT" -and $_.p5 -ne "ESTABLISHED" -and $_.p5 -ne "TIME_WAIT"};
#idler p5'te

function portlariIzoleEt {
    Param($p)
    foreach ($i in $p){
        $arr = $i.p3.split(":");
        $count = $arr.count;
        $i.p3 = $arr[$count-1];

        $arr = $i.p4.split(":");
        $count = $arr.count;
        $i.p4 = $arr[$count-1];
     }
}

portlariIzoleEt($part1);
portlariIzoleEt($part2);

foreach($i in $part1){
    $i.p5 = $i.p6;
}

$portlar = $part1 + $part2;

foreach ($i in $processler){
    foreach ($j in $portlar){
        if ($i.Id -eq $j.p5){
            $j.p6 = $i.Name;
        }
    }
}

$str = "";
foreach($i in $portlar){
    $str += "LocalPort:" + $i.p3 + ", ForeignPort:" + $i.p4 + ", ProcessName:" + $i.p6 + "`n`n";
}
$str > C:\temp\PortVeProcess.txt                                                              