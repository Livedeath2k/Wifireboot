<#
.SYNOPSIS
  Performs a WiFi Network Adapter reconnect/reboot.

  .DESCRIPTION
  It searches through the long list of network adapters for a match and if found it reconnects/reboots the WiFi network adapter.

  .Author
  Lars Boos aka Livedeath2k
  Mady with Love, Coffee and a long list of Games in my Steam Library. ;-)
#>

# Set the Exec Policy temporarily to bypass
Set-Executionpolicy -ExecutionPolicy Bypass -Scope Process

# Get the ID and security principal of the current user account
 $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
 $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

 # Get the security principal for the Administrator role
 $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

 # Check to see if we are currently running "as Administrator"
 if ($myWindowsPrincipal.IsInRole($adminRole))
    {
    # We are running "as Administrator" - so change the title and background color to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    clear-host
    }
 else
    {
    # We are not running "as Administrator" - so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    # Exit from the current, unelevated, process
    exit
    }

# It searches through the network adapter list and it will have a match when the name is WLAN of Wireless LAN of a Network Adapter.
$device = Get-PnpDevice | Where-Object {($_.Class -eq "Net") -and ($_.FriendlyName -like "WLAN" -or $_.FriendlyName -like "Wireless LAN")}
# If it won't work it searches through the list with a list of Names.
if ($device -like ''){
$device = Get-PnpDevice | Where-Object {$_.Class -eq "Net" -and $_.FriendlyName -eq "FRITZ!WLAN USB Stick AC 860"}
$device = Get-PnpDevice | Where-Object {$_.Class -eq "Net" -and $_.FriendlyName -eq "Realtek 8812BU Wireless LAN 802.11ac USB NIC"}
}
# If found it will reboot the WiFi network adapter
if ($device)
{
Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
Start-Sleep -Seconds 5
Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
}
