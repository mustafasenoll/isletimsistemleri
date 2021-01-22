
New-Item -Path "C:\temp\" -Name "CPU_log.txt" -ItemType "file"


$tetik = New-JobTrigger -At "19/01/2021 00:14:50" -RepetitionInterval (New-TimeSpan -Minutes 1) -RepeatIndefinitely $true


Register-ScheduledJob -Name 'cpuLogJob' -Trigger $tetik -ScriptBlock {
  $cekirdek_sayisi = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors

  $tarih_saat = Get-Date -Format "MM/dd/yyyy HH:mm"
  $tarih_saat

  #Get-Counter '\Process(*)\% Processor Time'
  
  #-ErrorAction SilentlyContinue

  $kirktan_cok_processler = (Get-Counter '\Process(*)\% Processor Time' -ErrorAction SilentlyContinue).
  CounterSamples | Where-Object {
  ($_.InstanceName -ne '_total') -and
  ($_.InstanceName -ne 'idle') -and
  ((($_.CookedValue)/$cekirdek_sayisi) -gt 40)}
    
  $process_listesi = $kirktan_cok_processler.InstanceName
  foreach ($i in $process_listesi){
    $i = $tarih_saat + ' ' + $i
    $i | Add-Content C:\temp\CPU_log.txt
  }

  $dosya_satir_sayisi = (Get-Content C:\temp\CPU_log.txt | Measure-Object –Line).Lines
 
  if ($dosya_satir_sayisi -ge 5000){
    $satir_array = Get-Content C:\temp\CPU_log.txt
    $eski_yarisi_atilmis_log = $satir_array[-2500..-1]
    $eski_yarisi_atilmis_log > C:\temp\CPU_log.txt
  }
} 
