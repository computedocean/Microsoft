﻿<#
.SYNOPSIS
    Get a URL in the argument and call different apps depending on what it is

.PARAMETER URL
    Colon delimited process to run and the arguments (if any) to pass

.EXAMPLE
     C:\Scripts\protocolhandler.ps1 guyrleech:msedge:https://guyrleech.wordpress.com

     Open https://guyrleech.wordpress.com in Microsoft Edge

.NOTES
    Setup the handler in the registry:

     1) Create key HKEY_CLASSES_ROOT\guyrleech\shell\open\command
     2) Set default value to powershell.exe -windowstyle hidden -noprofile -file c:\scripts\protocolhandler.ps1 %1   

    Use in Chrome/Edge via the Context Menu Search extension https://chrome.google.com/webstore/detail/context-menu-search/ocpcmghnefmdhljkoiapafejjohldoga

    Debug output can be viewed in SysInternals dbgview utility

    @guyrleech 2021/11/28
#>

[CmdletBinding()]

Param
(
    [string]$URL
)

[System.Diagnostics.Trace]::WriteLine( "Guys URL is $URL" )

[string[]]$components = @( $URL -split ':' , 3 )

if( $null -eq $components -or $components.Count -lt 2 )
{
    Add-Type -AssemblyName PresentationFramework
    [void][Windows.MessageBox]::Show( "Insufficient arguments in $URL" , 'Protocol Handler Error' , 'Ok' ,'Error' )
    exit 1
}

$launchError = $null
$process = $null

try
{
    $process = Start-Process -FilePath $components[1] -ArgumentList $components[2] -PassThru -ErrorVariable launchError
}
catch
{
    $launchError = $_
}

if( -Not $process )
{
    Add-Type -AssemblyName PresentationFramework
    [void][Windows.MessageBox]::Show( "Failed to start $($components[1]) arg $($components[2]) - error $launchError" , 'Protocol Handler Error' , 'Ok' ,'Error' )
    exit 2
}
