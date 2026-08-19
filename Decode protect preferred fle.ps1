<#
.SYNOPSIS
    Get the GUID stored in the "preferred" file for the user which is the master DPAPI key

.NOTES
    Modification History:

    2026/08/19  @guyrleech  Script born
#>

[CmdletBinding()]

Param
(
    [string]$folder = "$env:APPDATA\Microsoft\Protect"
)

try
{
    $sid   = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $path  = "$folder\$sid\Preferred"
    $bytes = $null
    $bytes = [System.IO.File]::ReadAllBytes($path)

    $guid = New-Object System.Guid (,[byte[]]$bytes[0..15])
    $ft   = [System.BitConverter]::ToInt64($bytes, 16)
    $fileProperties = Get-ItemProperty -Path "$folder\$sid\$guid" -ErrorAction SilentlyContinue
    $allGuidFiles = @( Get-ChildItem -Path "$folder\$sid" -File -Force | Where-Object Name -Match '^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$' | Sort-Object -Descending -Property CreationTime )

    [pscustomobject]@{
        "Preferred Key" = $guid
        "Rotates"       = [datetime]::FromFileTime($ft)
        "Created"       = $fileProperties | Select-Object -ExpandProperty CreationTime
        "Previous"      = $allGuidFiles | Where-Object Name -ne $guid | Select-Object -First 1 -ExpandProperty CreationTime
        "File Count"    = $allGuidFiles.Count
    }
}
catch
{
    throw
}
