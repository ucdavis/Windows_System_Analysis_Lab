<#
    Script: Lesson_04.ps1
    Last Modified: 2023-06-08
#>

#Stopping an Accidental Run
exit

########################################
# System Information 
########################################

#Get BIOS Information
Get-WmiObject -Class Win32_BIOS -Computer localhost

#Get Basic System Info
Get-WmiObject -Class Win32_ComputerSystem -Computer localhost

#Get Operating System Info
Get-WmiObject -Class Win32_OperatingSystem -Computer localhost

#Get Consolidated Object of System and Operating System Properties
Get-ComputerInfo

########################################
# Disk Information 
########################################

#Get Disk Information
Get-Disk | Format-List

#Show Physical Disk Information
Get-PhysicalDisk

#Get Disk Information (Model and Size)
Get-WmiObject -Class Win32_DiskDrive | ForEach-Object { Write-Output ($_.Model.ToString() + " Size:" + ($_.Size/1GB) + "GB") }

#Get Logical Disk Info
Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType='3'" -Computer localhost

#Show Disk Partitions
Get-Partition

#Get Disk Volume Information
Get-Volume | Format-Table

#Get Fixed Volumes
Get-Volume | Where-Object DriveType -eq "Fixed"

#Get Volume Info (Windows 7)
Get-WmiObject -Class Win32_Volume -Filter "DriveType='3'" | Select-Object Name

#Get Share Info
Get-SmbShare | Format-List

#Get Share Info
Get-WmiObject -Class Win32_Share -Computer localhost

########################################
# Processor and Memory 
########################################

#Get Processor Information
Get-WmiObject -Class Win32_Processor | Select-Object Name,Description,NumberOfCores | Sort-Object Name

#Get Number of Memory Slots
(Get-WmiObject -Class Win32_PhysicalMemoryArray).MemoryDevices

#Retrieve Memory Slot Allocations
Get-WMIObject -Class Win32_PhysicalMemory | ForEach-Object { Write-Output ($_.DeviceLocator.ToString() + " " + ($_.Capacity/1GB) + "GB") };

########################################
# Printer Information 
########################################

#Show Printers
Get-Printer 

#Show Local Printers
Get-Printer | Where-Object { $_.Type -eq "Local" } | Format-Table -AutoSize

#Show Printer Ports
Get-PrinterPort





