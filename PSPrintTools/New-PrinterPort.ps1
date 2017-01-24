function New-PrinterPort {
	<#
	.SYNOPSIS
	Creates a new TCPIP printer port using New-CIMInstance on Win32_TCPIPPrinterPort
	.EXAMPLE
	New-PrinterPort -Name Test -HostAddress 192.168.1.5

	.PARAMETER ComputerName
	The computer name or array of computers to query
	.PARAMETER Name
    Uniquely identifies the service access point and provides an indication of the functionality that is managed
    .PARAMETER HostAddress
    Address of the device or print server.
    .PARAMETER Caption
    A short textual description of the object.
    .PARAMETER Description
    A textual description of the object.
    .PARAMETER PortNumber
    Number of the TCP port used by the port monitor to communicate with the device
    .PARAMETER Protocol
    Printing protocol used RAW or LPR
    .PARAMETER Queue
    Name of the print queue on the server when used with the LPR protocol.
    .PARAMETER SNMPEnabled
    If TRUE, this printer supports RFC 1759 (Simple Network Management Protocol) and can provide rich status information from the device.
    .PARAMETER SNMPCommunity
    Security level value for the device.
    .PARAMETER SNMPDevIndex
    SNMP index number of this device for the SNMP agent.
	.OUTPUTS
	Win32_TCPIPPrinterPort
	.LINK
    https://himsel.io
    .LINK
	https://github.com/BenHimsel/PSPrintTools
	.NOTES
    Where applicable, set free under the unlicense: http://unlicense.org/ 
	Author: Ben Himsel
	#>
	
	[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
	param (
		[Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 0)]
		[string]$ComputerName,

        [Parameter(Mandatory=$True,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 1)]
		[string]$Name,

        [Parameter(Mandatory=$True,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 2)]
		[string]$HostAddress,

        [Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 3)]
		[string]$Caption,

        [Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 4)]
        [string]$Description,

        [Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 5)]
		[uint32]$PortNumber = 9100,

        [Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 6)]
        [ValidateSet("RAW","LPR")]
		[string]$Protocol = "RAW",

        [Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 7)]
		[string]$Queue,

        [Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 8)]
		[bool]$SNMPEnabled = $True,

        [Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 9)]
		[string]$SNMPCommunity = "Public",

        [Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 10)]
		[string]$SNMPDevIndex
	)

	write-verbose "Building command string"
    
    $props = @{}
    #ComputerName
    if (($ComputerName) -and ($ComputerName -ne "LocalHost") -and ($ComputerName -ne ".") -and ($ComputerName -ne $ENV:COMPUTERNAME)) {
        $props['ComputerName']=$ComputerName
    }

    #Name String Mandatory
    $props['Name']=$Name

    #HostAddress String Mandatory
    $props['HostAddress']=$HostAddress

    #Caption
    if ($Caption) {
        $props['Caption']=$Caption
    }

    #Description
    if ($Description) {
        $props['Description']=$Description
    }

    #PortNumber has default value
    $props['PortNumber']=[uint32]$PortNumber

    #Protocol to int
    if ($Protocol -eq "RAW") {
        $props['Protocol']=[uint32]1
    }

    #Queue mandatory if using LPR
    if (($Protocol -eq "LPR" ) -and ($null -eq $Queue)) { throw "Queue required with LPR" }
    if ($Queue) {
        $props['Queue']=$Queue
    }

    #SNMPEnabled
    $props['SNMPEnabled']=$SNMPEnabled

    #SNMPCommunity has default value
    $props['SNMPCommunity']=$SNMPCommunity

    #SNMPDevIndex
    if ($SNMPDevIndexString) {
         $props['SNMPDevIndex']=$SNMPDevIndex
    }


	if ($pscmdlet.ShouldProcess($Name)) {
        Write-Verbose "Invoking built command"
        New-CimInstance -ClassName Win32_TCPIPPrinterPort -Property @props
 }

}