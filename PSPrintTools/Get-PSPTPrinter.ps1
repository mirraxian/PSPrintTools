function Get-PSPTPrinter {
	<#
	.SYNOPSIS
	A recreation of the Get-Printer Cmdlet without the MSFT class
	.EXAMPLE
	Get-PSPTPrinter -ComputerName ExampleComputer,LocalHost
	.PARAMETER ComputerName
	The computer name or array of computers to query, defaults to localhost
	.OUTPUTS
	Microsoft.Management.Infrastructure.CimInstance#ROOT/StandardCimv2/MSFT_Printer without RenderingMode, JobCount, DisableBranchOfficeLogging, or BranchOfficeOfflineLogSizeMB
	.LINK
	https://github.com/BenHimsel/PSPrintTools
	.NOTES
	Author: Ben Himsel
	Website: http://himsel.io
	#>

	[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
	param (
		[Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 0)]
		[string[]]$ComputerName = "LocalHost"
	)

	begin {
	write-verbose "Beginning Something"

	}

	process {
		write-verbose "Starting Procesing loop"
		foreach ($computer in $ComputerName) {
			Write-Verbose "Processing $computer"
			if ($pscmdlet.ShouldProcess($computer)) {
                $sddlconverter = New-Object System.Management.ManagementClass Win32_SecurityDescriptorHelper
				$selectarray = @(
					"Name"
					@{
						Name="ComputerName"
						Expression={$_.SystemName}
					}
					"ShareName"
					"PortName"
					"DriverName"
					"Location"
					"Comment"
					@{
						Name="SeparatorPageFile"
						Expression={$_.SeparatorFile}
					}
					"PrintProcessor"
					@{
						Name="Datatype"
						Expression={$_.PrintJobDataType}
					}
					"Shared"
					"Published"
					@{
						Name="PermissionSDDL"
						Expression={$sddlconverter.Win32SDToSDDL($_.getsecuritydescriptor().Descriptor).SDDL}
					}
					"KeepPrintedJobs"
					"Priority"
					@{
						Name="DefaultJobPriority"
						Expression={$_.DefaultPriority}
					}
					"StartTime"
					"UntilTime"
					@{	Name="PrinterStatus"
						Expression={
							switch ($_.PrinterStatus) {
								1 {"Other"}
								2 {"Unknown"}
								3 {"Idle"}
								4 {"Printing"}
								5 {"Warming up"}
								6 {"Stopped Printing"}
								7 {"Offline"}
								default {"Unknown"}
							}
						}
					}

				)
				$wmiprinter = Get-WmiObject -ComputerName $computer Win32_Printer | select $selectarray
                if ($wmiprinter.local -eq "True") {
                    $Type = "Local"
                } elseif ($wmiprinter.Network -eq "True") {
                    $Type = "Connection"
                } else {
                    $Type = "Unknown"
                }
                $wmiprinter

			}
		}
	}
	end {
			write-verbose "Ending Something"
	}
}
<#
RenderingMode
JobCount
DisableBranchOfficeLogging
BranchOfficeOfflineLogSizeMB
#>