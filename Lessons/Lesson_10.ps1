<#
    Script: Lesson_10.ps1
    Last Modified: 2023-06-13
#>

#Stopping an Accidental Run
exit

#Write a Script to Report the File Permissions and Active Process Counts of all Program Files Folders and the Windows Directory 

#ProgramFiles                   C:\Program Files
#ProgramFiles(x86)              C:\Program Files (x86)
#windir                         C:\WINDOWS

#Array to Hold Current Processes
$arrCurrntProcesses = @();

#Load Array of Strings of Currently Running Process's Executable 
$arrCurrntProcesses = Get-Process -FileVersionInfo -ErrorAction "SilentlyContinue" | Select-Object FileName | Foreach-Object { $_.FileName.ToString().ToLower(); };

#Reporting Array for Locations to Check
$arrReportLTC = @();

#Reporting Array for Locations to Check Permissions
$arrReportLTCPerms = @();

#Array of Locations to Check
$arrLocsToCheck = @(${env:programfiles(x86)},${env:programfiles},${env:windir});

#Loop Through the Locations to Check
foreach($LocToCheck in $arrLocsToCheck)
{
    #Pull Directories Under the Locations to Check
    foreach($ltcFldr in (Get-ChildItem -Path $LocToCheck -Directory -Depth 0))
    {
        #Create Custom Location to Check Folder Object
        $cstLTCFlder = New-Object PSObject -Property (@{ Location=""; Running_Process_Count=0;});
        $cstLTCFlder.Location = $ltcFldr.FullName;

        #Var of LTC Folder to Lower with Extra "\"
        [string]$ltcFldrLoc = $ltcFldr.FullName.ToString().ToLower() + "\";

        foreach($crntPrcs in $arrCurrntProcesses)
        {
            if($crntPrcs.ToString().StartsWith($ltcFldrLoc) -eq $true)
            {
                $cstLTCFlder.Running_Process_Count++;
            }

        }

        #Add Custom Object to Reporting Array
        $arrReportLTC += $cstLTCFlder;
        
        #Pull File System ACLs for Folder
        foreach($fsACL in (Get-Acl -Path $ltcFldr.FullName).Access)
        {
            #Create Custom Shared Folder ACL Object
            $cstFsACL = new-object PSObject -Property (@{ Location=""; IdentityReference=""; FileSystemRights=""; AccessControlType=""; IsInherited=""; });
            $cstFsACL.Location = $ltcFldr.FullName;
            $cstFsACL.IdentityReference = $fsACL.IdentityReference;
            $cstFsACL.FileSystemRights = $fsACL.FileSystemRights;
            $cstFsACL.AccessControlType = $fsACL.AccessControlType;
            $cstFsACL.IsInherited = $fsACL.IsInherited;
            
            #Add Custom Object to Reporting Array
            $arrReportLTCPerms += $cstFsACL;
        }

    }#End of Get-ChildItem Foreach

}#End of $arrLocsToCheck Foreach

#Var for System Name
[string]$sysName= (hostname).ToString().ToUpper();

#Var for Report Date
[string]$rptDate = (Get-Date).ToString("yyyy-MM-dd");

#Var for LTC Process Counts Report Name
[string]$rptNameProcessCount = ".\LTC_Process_Counts_on_" + $sysName + "_" + $rptDate + ".csv";

#Var for LTC ACL Report Name
[string]$rptNameACLs = ".\LTC_ACLs_on_" + $sysName + "_" + $rptDate + ".csv";

#Export LTC Process Count Report to CSV
$arrReportLTC| Sort-Object -Property Location | Select-Object -Property Location,Running_Process_Count | Export-Csv -Path $rptNameProcessCount -NoTypeInformation;

#Export LTC ACLs Report to CSV
$arrReportLTCPerms | Sort-Object -Property Location | Select-Object -Property Location,IdentityReference,FileSystemRights,AccessControlType,IsInherited | Export-Csv -Path $rptNameACLs -NoTypeInformation;


