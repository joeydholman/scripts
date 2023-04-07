#Check/Import Modules
Get-Module -Name ActiveDirectory | Out-Null
Import-Module -Name ActiveDirectory | Out-Null

Write-Host "  _   _                 _    _                  _____           _       _   "
Write-Host " | \ | |               | |  | |                / ____|         (_)     | |  "
Write-Host " |  \| | _____      __ | |  | |___  ___ _ __  | (___   ___ _ __ _ _ __ | |_ "
Write-Host " | . ` |/ _ \ \ /\ / / | |  | / __|/ _ \ '__|  \___ \ / __| '__| | '_ \| __|"
Write-Host " | |\  |  __/\ V  V /  | |__| \__ \  __/ |     ____) | (__| |  | | |_) | |_ "
Write-Host " |_| \_|\___| \_/\_/    \____/|___/\___|_|    |_____/ \___|_|  |_| .__/ \__|"
Write-Host "                                                                 | |        "
Write-Host "                                                                 |_|        "

$global:phonenumb | Out-Null
$siteadd | Out-Null

function Get-PhoneNum {
    $phonenumyn = Read-Host "Does the user have a phone number (y/n)?"
    if ($phonenumyn -eq "n") {
        $global:phonenum = "312-846-2305"
    }
    elseif ($phonenumyn -eq "y") {
        $global:phonenum = Read-Host "Enter user's phone number (XXX-XXX-XXXX)"
        while ($phonenum -notmatch '[0-9]{3}\-[0-9]{3}\-[0-9]{4}') {
            $global:phonenum = Read-Host "Enter user's phone number (XXX-XXX-XXXX)"
        }
    }
    else {
        $phonenumyn = Read-Host "Invalid response. Please enter 'y' or 'n'"
    }
}


while ($correct -ne "y") {
    $firstname = Read-Host "First name"
    $lastname = Read-Host "Last name"
    $firstletter = $firstname[0]
    $lastletter = $lastname[0]
    $site = Read-Host "Which site is the user at (hit ? for options)?"
    $address

    while ($site -eq "?") {
        $listsites = Get-ADOrganizationalUnit -Filter * -Properties CanonicalName | Select-Object -Property CanonicalName -Skip 1 | foreach { $_.CanonicalName}
        $resultstring = Out-String -InputObject $listsites
        $oudel = "/"
        $position = $resultstring.IndexOf($oudel)
        foreach ($letter in $listsites) {
            $selectou = Write-Host $letter.Substring($position+1)
        }
        
        $site = Read-Host "Which site is the user at (hit ? for options)?"
    }

    while ($site -eq $selectou) {
        Write-Host "Invalid response, please select one of the sites"
        $site = Read-Host "Which site is the user at (hit ? for options)?"
    } 
    Write-Host "Selected site: " $site -ForegroundColor Green
    Get-PhoneNum
    $jobtitle = Read-Host "Job Title"

    if ($site -eq "Chicago") {
        $address = "110 W. Fake Street"
        $city = "Chicago"
        $state = "IL"
        $zip = "60605"
    }
    elseif ($site -eq "Denver") {
        $address = "9125 E Fake Avenue"
        $city = "Denver"
        $state = "CO"
        $zip = "80214"
    }
    elseif ($site -eq "Raleigh") {
        $address = "705 Fake Road"
        $city = "Raleigh"
        $state = "NC"
        $zip = "27616"
    }

    Write-Host "`nFirst name:   " $firstname
    Write-Host "Last name:    " $lastname
    $firststr = Out-String -InputObject $firstletter
    $laststr = Out-String -InputObject $lastname
    $lastletterstr = Out-String -InputObject $lastletter
    $lastlower = $laststr.ToLower()
    $lastletterlower = $lastletterstr.ToLower()
    $firstlower = $firststr.ToLower()
    $lastlower = $laststr.ToLower()
    $fullname = [string]::Concat($firstname," ",$lastname)
    $username =  [string]::Concat($firstlower,$lastlower) -replace "`n|`r"
    Write-Host "Display Name: " $fullname
    Write-Host "Username:     " $username
    Write-Host "Job Title:    " $jobtitle
    Write-Host "Site:         " $site
    Write-Host "Phone number: " $phonenum
    Write-Host "Address:      " $address
    Write-Host "City:         " $city
    Write-Host "State:        " $state
    Write-Host "ZIP Code      " $zip
    Write-Host "--------------------"

    $correct = Read-Host "Does this look correct (y/n)"
}
try {
    Write-Host "Creating account..."
    $cleartextpwd = $combopwd = [string]::Concat($firststr,$lastletterlower,$(Get-Date -Format MM),$(Get-Date -Format dd),$(Get-Date -Format yy)) -replace "`n|`r"
    $combopwd = [string]::Concat($firststr,$lastletterlower,$(Get-Date -Format MM),$(Get-Date -Format dd),$(Get-Date -Format yy)) -replace "`n|`r" | ConvertTo-SecureString -AsPlainText -Force
    New-ADUser -Name ($fullname) -SamAccountName $username -GivenName $firstname -Surname $lastname -Accountpassword $combopwd -Path "OU=$site,dc=holman,dc=local" -DisplayName $fullname  -ChangePasswordAtLogon $True -Enabled $True -StreetAddress $address -City $city -State $state -UserPrincipalName $username -PostalCode $zip -Title $jobtitle -OfficePhone $phonenum -Description $jobtitle | Out-Null
    Write-Host "Completed" -ForegroundColor Green
    $newusername = Get-ADUser -Identity $username -Properties UserPrincipalName | Select-Object UserPrincipalName | foreach { $_.UserPrincipalName}
    Write-Host "Username: " $newusername
    Write-Host "Password: " $cleartextpwd
}
catch {
    Write-Host "ERROR:" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
}