#Rename home folder function
function RenameFolder {
    $FirstName = Read-Host "`nFirst name:   "
    $LastName = Read-Host "`nLast name:   "
    #Get username for home folder
    $SAMName = Get-ADUser -Filter 'cn -eq '$FirstName' and sn -eq '$LastName'' -Properties -SamAccountName
    Write-Output "Renaming user profile folder $SAMName"
    $RenameProc = Rename-Item -Path "C:\Users\$SAMName" -NewName "$SAMName.old" 2> $RPError
    if ($RenameProc) {
        $Mesg = "Success"
    }
    else {
        $Mesg = "Failed`n$RPError"
    }
    Write-Output $Mesg
}
#Function to delete two registry keys for profile
function DelRegKeys {
    function DelProfileList {
        #Get SID value
        $GetSID = Get-ADUser -Identity $SAMName | Select-Object SID
        Write-Output "Removing ProfileList Registry Key for SID $GetSID..."
        $ProfileListPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\ProfileList\$GetSID"
        if (Test-Path -Path $ProfileListPath) {
            try {
                Remove-Item -Path $ProfileListPath -Confirm
                Write-Output "Registry Key $GetSID under ProfileList successfully."
            }
            catch {
                Write-Error $_
            }
        }
        else {
            Write-Output "Registry key path $ProfileListPath does not exist."
        }
    }
    function DelProfileGuid {
        #Get SID value
        $GetSID = Get-ADUser -Identity $SAMName | Select-Object SID
        Write-Output "Removing ProfileGuid Registry Key for SID $GetSID..."
        $ProfileGuidPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\Current Version\ProfileGuid\$GetSID"
        if (Test-Path -Path $ProfileGuidPath) {
            try {
                Remove-Item -Path $ProfileGuidPath -Confirm
                Write-Output "Registry Key $GetSID under ProfileGuid removed successfully."
            }
            catch {
                Write-Error $_
            }
        }
        else {
            Write-Output "Registry key path $ProfileGuidPath does not exist."
        }
    }
    DelProfileList
    DelProfileGuid
}
RenameFolder
DelRegKeys