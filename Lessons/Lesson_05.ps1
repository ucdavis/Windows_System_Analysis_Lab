<#
    Script: Lesson_05.ps1
    Last Modified: 2021-06-06
#>

#Stopping an Accidental Run
exit

########################################
# Local Users and Groups
########################################

#Show Local Users
Get-LocalUser

#Show Local Groups
Get-LocalGroup

#Show Local Group Membership
Get-LocalGroupMember -Group Administrators

#Show Local Group Membership using Pipe
Get-LocalGroup -Name 'Remote Desktop Users' | Get-LocalGroupMember

#Show Local Profiles and Their SIDs
Get-WmiObject win32_userprofile | Select LocalPath,SID

##Get Local Accounts and Groups on a System (Windows 7 and Below)
#Get-WmiObject -Class Win32_Account | Select-Object Name,SID | Sort-Object Name

##Get Just Local Accounts on a System (Windows 7 and Below)
#Get-WmiObject -Class Win32_Account | Where-Object { $_.AccountType -eq "512" } 

##Get Local Admin Accounts (Windows 7 and Below)
#Get-WmiObject -Class Win32_GroupUser | Where-Object { $_.GroupComponent -match 'administrators'} | Foreach-Object {[WMI]$_.PartComponent}


########################################
# Process and Services
########################################

#Get Process By Partial Name
Get-Process -Name Chrom*

#Get Path to Process's Executable
Get-Process -FileVersionInfo -ErrorAction "SilentlyContinue" | Select-Object OriginalFilename,FileVersionRaw,FileName | Sort-Object OriginalFilename
#OR
#Get Path to Process's Executable 
Get-WmiObject -Class Win32_Process -Computer localhost | Select-Object Name,Path | Sort-Object Name

#Get Owner of the Process
Get-WmiObject -Class Win32_Process -Computer localhost | Select-Object Name, @{Name="Owner"; Expression={$_.GetOwner().User}} | Sort-Object Name

#Get Service By Partial Name
Get-Service -Name Spoo*

#Get Running Services
Get-Service | Where { $_.Status -eq "Running" } | Select-Object Name,DisplayName,Status,CanStop | Sort-Object DisplayName

#Get All Services and the Account which they are running under
Get-WmiObject -Class Win32_Service -Computer localhost | Select-Object Name,State,StartName | Sort-Object -Property @{Expression="StartName";Descending=$false},@{Expression="Name";Descending=$false}


#######################################
# Event Logs
#######################################

#Get All Event Log Names on a System
Get-EventLog -List

#Get the Latest 100 Items in the System Log
Get-EventLog -LogName System -Newest 100 | Select-Object Message

#Get the Lastest 5 Errors in the System Log
Get-EventLog -LogName System -EntryType Error -Newest 5
#EntryTypes Information, Warning, Error, FailureAudit, SuccessAudit

#Get Application Log Entries Between Specific Times
Get-EventLog -LogName Application -Before (get-date).AddDays(-1) -After (get-date).AddDays(-3)

#Get Failed Logins Over the Last 24 Hours (Requires Elevated Session)
Get-EventLog -LogName Security -After (get-date).AddDays(-1) | Where-Object { $_.instanceID -eq 4625 }

#Get Successful Logins Over the Last 24 Hours (Requires Elevated Session)
Get-EventLog -LogName Security -InstanceId 4624 -After (get-date).AddDays(-1)


######################################
# Scheduled Tasks
######################################

#Show Scheduled Tasks
Get-ScheduledTask | FL

#Get Scheduled Task By Name
Get-ScheduledTask -TaskName Adobe*

#Show Schedule Informatio for Task
Get-ScheduledTask -TaskName Adobe* | ScheduledTaskInfo

#Show Execute Actions for All Scheduled Tasks
Get-ScheduledTask | Sort-Object -Property TaskName | Foreach-Object { Write-Output("`n" + $_.TaskName + ":"); Foreach ($ta in $_.Actions){$ta.execute}}