
$package_path = "D:\wsusoffline\client\w100-x64\glb"
$index = 3
$work_dir = "d:\update_iso"
$iso = "d:\isos\de_windows_10_multi-edition_vl_version_1709_updated_sept_2017_x64_dvd_100090752.iso"
$oscd_path = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"


$offline_path = "$($work_dir)\offline"
$iso_dest = "$($work_dir)\iso"
$wim_path = "$($iso_dest)\sources\install.wim"
$iso_output = "$($work_dir)\output.iso"



New-Item -ItemType directory -Path $work_dir
New-Item -ItemType directory -Path $offline_path
New-Item -ItemType directory -Path $iso_dest




$mount_volume = Mount-DiskImage -ImagePath $iso -PassThru | Get-Volume
Write-Host "$($mount_volume.DriveLetter):\"
Copy-Item "$($mount_volume.DriveLetter):\*" -Destination $iso_dest -Recurse -Force
Get-Item $wim_path | Set-ItemProperty -name isreadonly -Value $false -Force
Dismount-DiskImage $iso

Get-WindowsImage -ImagePath $wim_path

Write-Host $wim_path
Mount-WindowsImage -path $offline_path -ImagePath $wim_path  -Index $index
Add-WindowsPackage –Path $offline_path –PackagePath $package_path
Dismount-WindowsImage -path $offline_path -Save -CheckIntegrity

$BootData='2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$iso_dest\boot\etfsboot.com","$iso_dest\efi\Microsoft\boot\efisys.bin"
  
$Proc = Start-Process -FilePath $oscd_path -ArgumentList @("-bootdata:$BootData",'-u2','-udfver102',"$iso_dest","$iso_output") -PassThru -Wait -NoNewWindow
if($Proc.ExitCode -ne 0)
{
    Throw "Failed to generate ISO with exitcode: $($Proc.ExitCode)"
}


Remove-Item -Recurse -Force $iso_dest
