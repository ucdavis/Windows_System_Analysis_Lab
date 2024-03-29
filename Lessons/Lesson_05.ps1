<#
    Script: Lesson_05.ps1
    Last Modified: 2023-06-08
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
Get-WmiObject win32_userprofile | Select-Object LocalPath,SID

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

#View Processes by Highest CPU Usage
Get-Process | Sort-Object CPU -Descending | more

#View Processes by Highest Memory Usage
Get-Process | Sort-Object WorkingSet -Descending | more

#Show File Information for One of the Zoom Processes
Get-Process -ProcessName 'Zoom' -FileVersionInfo | Format-List

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
Get-Service | Where-Object { $_.Status -eq "Running" } | Select-Object Name,DisplayName,Status,CanStop | Sort-Object DisplayName

#Get All Services and the Account which they are running under
Get-WmiObject -Class Win32_Service -Computer localhost | Select-Object Name,State,StartName | Sort-Object -Property @{Expression="StartName";Descending=$false},@{Expression="Name";Descending=$false}


#######################################
# Event Logs
#######################################

#Get All Event Log Names
Get-WinEvent -ListLog * -ErrorAction SilentlyContinue;

#Get the Latest 100 Items in the System Log
Get-WinEvent -LogName 'System' -MaxEvents 100;

<#
  Log Entry Types:
  0 = LogAlways
  1 = Critical
  2 = Error
  3 = Warning
  4 = Informational
  5 = Verbose

  Keywords:
  4503599627370496 = AuditFailure
  9007199254740992 = AuditSuccess
#>

#Get the Latest 5 Errors in the System Log
Get-WinEvent -FilterHashtable @{ LogName='System'; Level=2; } -MaxEvents 5;

#Get Application Log Entries Between Specific Times
Get-WinEvent -FilterHashtable @{ LogName='Application'; StartTime=(Get-Date).AddDays(-5); EndTime=(Get-Date).AddDays(-1); };

#Get Failed Logins Over the Last 24 Hours (Requires Elevated Session)
Get-WinEvent -FilterHashtable @{ LogName='Security'; StartTime=(Get-Date).AddDays(-1); Id='4625'; } | Format-List | more

#Get Successful Logins Over the Last 24 Hours (Requires Elevated Session)
Get-WinEvent -FilterHashtable @{ LogName='Security'; StartTime=(Get-Date).AddDays(-1); Id='4624'; };

#Get All Audit Failures in the Past Week
Get-WinEvent -FilterHashtable @{ LogName=@('Security'); Keywords=@(4503599627370496); StartTime=(Get-Date).AddDays(-7); } | Format-List | more

#Get Provider Names for Application, System, and Security Logs (Requires Elevated Session)
Get-WinEvent -ListLog @('Application','System','Security') | Select-Object LogName, @{Name="Providers"; Expression={$_.ProviderNames | Sort-Object }} | Foreach-Object { Write-Output("`r`n---- " + $_.LogName + " ----`r`n"); $_.Providers }; 

#Get Group Policy Related Entries in System Log in the Last 24 Hours
Get-WinEvent -FilterHashtable @{ LogName='System'; ProviderName='Microsoft-Windows-GroupPolicy'; StartTime=(Get-Date).AddDays(-1); } | Format-List | more;

#Get All Sophos and Security Center Events in the Last 72 Hours (Requires Elevated Session)
Get-WinEvent -FilterHashtable @{ LogName=@('Application','System','Security'); ProviderName=@('HitmanPro.Alert','SAVOnAccess','SAVOnAccessControl','SAVOnAccessFilter','SecurityCenter'); StartTime=(Get-Date).AddDays(-3); } -ErrorAction SilentlyContinue | Format-List | more

#Get All Critial or Error Entries from Application, System, and Security Logs in Last 24 Hours (Requires Elevated Session)
Get-WinEvent -FilterHashtable @{ LogName=@('Application','System','Security'); Level=@(1,2); StartTime=(Get-Date).AddDays(-1); };

##Get All Event Log Names on a System (PSVersion <= 4)
#Get-EventLog -List

##Get the Latest 100 Items in the System Log (PSVersion <= 4)
#Get-EventLog -LogName System -Newest 100 | Select-Object Message

##Get the Latest 5 Errors in the System Log (PSVersion <= 4)
#Get-EventLog -LogName System -EntryType Error -Newest 5
#EntryTypes Information, Warning, Error, FailureAudit, SuccessAudit

##Get Application Log Entries Between Specific Times (PSVersion <= 4)
#Get-EventLog -LogName Application -Before (get-date).AddDays(-1) -After (get-date).AddDays(-3)

##Get Failed Logins Over the Last 24 Hours (Requires Elevated Session and PSVersion <= 4)
#Get-EventLog -LogName Security -After (get-date).AddDays(-1) | Where-Object { $_.instanceID -eq 4625 }

##Get Successful Logins Over the Last 24 Hours (Requires Elevated Session and PSVersion <= 4)
#Get-EventLog -LogName Security -InstanceId 4624 -After (get-date).AddDays(-1)


######################################
# Scheduled Tasks
######################################

#Show Scheduled Tasks
Get-ScheduledTask | Format-List

#Get Scheduled Task By Name
Get-ScheduledTask -TaskName Adobe*

#Show Schedule Informatio for Task
Get-ScheduledTask -TaskName Adobe* | Get-ScheduledTaskInfo

#Show Execute Actions for All Scheduled Tasks
Get-ScheduledTask | Sort-Object -Property TaskName | Foreach-Object { Write-Output("`n" + $_.TaskName + ":"); Foreach ($ta in $_.Actions){$ta.execute}}