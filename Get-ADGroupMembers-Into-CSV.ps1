# ==========================================================================================================
#
# PS script to extract list of AD Group members into a csv file
# -----------------------------------------------------------------------------------
#
# ==========================================================================================================

$ErrorActionPreference = "Stop"

$temp_date = Get-Date -Format "yyyy-mm-dd"
$csv_file = "group_members_" + $temp_date + ".csv"

# Define an empty list to store members
$members = @()
$group_members = ""

$roles_list = (
    "Administrators",
    "Developers",
    "Operators"
)

$ad_domains_list = (
    "dev-domain.myenterprise.com",
    "test-domain.myenterprise.com",
    "prod-domain.myenterprise.net"
)

Write-Host ""
foreach ($role in $roles_list) {

    foreach ($folder in $ad_domains_list) {

        $result_object = Get-ADGroupMember -Identity $role -server $folder
        # Write-Host $result_object

        if ($result_object) {
            Write-Host "Active users found for the role [$role] in [$folder] domain."

            # Add group member details to a list
            $group_members = Get-ADGroupMember $role -server $folder | Select-Object Name, SamAccountName, DistinguishedName
            $group_members | Add-Member -MemberType NoteProperty -Name Role-Name -Value $role
            $group_members | Add-Member -MemberType NoteProperty -Name AD-Domain -Value $folder
            $members += $group_members
        } else {
            Write-Host "No active users found for the role [$role] in [$folder] domain."
            
            # Optional. You can add "no user found" as a row when no active users are found
            $object1 = New-Object PSObject
            $object1 | Add-Member -MemberType NoteProperty -Name Name -Value "No Active User(s) Found"
            $object1 | Add-Member -MemberType NoteProperty -Name SamAccountName -Value "No Active User(s) Found"
            $object1 | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value "Not Available"
            $object1 | Add-Member -MemberType NoteProperty -Name Role-Name -Value $role
            $object1 | Add-Member -MemberType NoteProperty -Name AD-Domain -Value $folder
            $members += $object1
        }
    }

    # Export members list to a CSV file
    $members | Export-Csv -Path $csv_file -NoTypeInformation -Force
}

Write-Host "`nCSV file generated with name [$csv_file]`n"
