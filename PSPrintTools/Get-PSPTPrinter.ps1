function Get-PSPTPrinter {
	<#
	.SYNOPSIS
	A recreation of the Get-Printer Cmdlet without the MSFT class
	.EXAMPLE
	Get-PSPTPrinter -ComputerName ExampleComputer,LocalHost
	.PARAMETER ComputerName
	The computer name or array of computers to query, defaults to localhost
	.PARAMETER PrinterName
	The name or array of names of printers to filter against, defaults to unfiltered
	.OUTPUTS
	Microsoft.Management.Infrastructure.CimInstance#ROOT/StandardCimv2/MSFT_Printer without RenderingMode, JobCount, DisableBranchOfficeLogging, or BranchOfficeOfflineLogSizeMB
<<<<<<< HEAD
	.LINK
    https://himsel.io
    .LINK
	https://github.com/BenHimsel/PSPrintTools
	.NOTES
    Where applicable, set free under the unlicense: http://unlicense.org/ 
	Author: Ben Himsel
=======
    .LINK
    https://github.com/BenHimsel/PSPrintTools
    .LINK
    https://himsel.io
    .NOTES
    Where applicable, set free under the terms of the Unlicense. http://unlicense.org/
    Author: Ben Himsel
>>>>>>> 0b434753061ad5cd92b6fb959e24a7a249cccbff
	#>

	[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
	param (
		[Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 0)]
		[string[]]$ComputerName,

		[Parameter(Mandatory=$False,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 1)]
		[string[]]$PrinterName
	)

	begin {
<<<<<<< HEAD
		write-verbose "Beginning Something"
		#Converter used to change ACL into SDDL
		$sddlconverter = New-Object System.Management.ManagementClass Win32_SecurityDescriptorHelper
		#Create an array for Select-Object to Change Win32_Printer output to be similar to MSFT_Printer
=======
		write-verbose "Initializing Helpers"
		$sddlconverter = New-Object System.Management.ManagementClass Win32_SecurityDescriptorHelper
>>>>>>> 0b434753061ad5cd92b6fb959e24a7a249cccbff
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
	}

	process {
		if ($ComputerName) {
			write-verbose "Starting Processing loop"
			foreach ($computer in $ComputerName) {
				Write-Verbose "Processing $computer"
				if ($pscmdlet.ShouldProcess($computer)) {
<<<<<<< HEAD
					#add filter if there's a printername
					if ($PrinterName) {
						$CIMPrinter = Get-CimInstance -ComputerName $computer -ClassName Win32_Printer -Filter "Name like '$PrinterName'" | Select-Object $selectarray
					} else {
						$CIMPrinter = Get-CimInstance -ComputerName $computer -ClassName Win32_Printer | Select-Object $selectarray
					}
					if ($CIMPrinter.local -eq "True") {
						$Type = "Local"
					} elseif ($CIMPrinter.Network -eq "True") {
						$Type = "Connection"
					} else {
						$Type = "Unknown"
					}
=======
					if ($PrinterName) {
						$CIMPrinter = Get-CimInstance -ComputerName $computer Win32_Printer -Filter "Name like '$PrinterName'" | Select-Object $selectarray
					} else {
						$CIMPrinter = Get-CimInstance  -ComputerName $computer Win32_Printer | Select-Object $selectarray
					}
					if ($CIMPrinter.local -eq "True") {
						$Type = "Local"
					} elseif ($CIMPrinter.Network -eq "True") {
						$Type = "Connection"
					} else {
						$Type = "Unknown"
					}
>>>>>>> 0b434753061ad5cd92b6fb959e24a7a249cccbff
					$CIMPrinter

				}
			}
		} else {
<<<<<<< HEAD
			#add filter if there's a printername
			if ($PrinterName) {
				$CIMPrinter = Get-CimInstance -ClassName Win32_Printer -Filter "Name like '$PrinterName'" | Select-Object $selectarray
			} else {
				$CIMPrinter = Get-CimInstance -ClassName Win32_Printer | Select-Object $selectarray
			}
			if ($CIMPrinter.local -eq "True") {
				$Type = "Local"
			} elseif ($CIMPrinter.Network -eq "True") {
				$Type = "Connection"
			} else {
				$Type = "Unknown"
			}
=======
			write-verbose "No ComputerName, skip Processing loop"
			if ($PrinterName) {
				$CIMPrinter = Get-CimInstance Win32_Printer -Filter "Name like '$PrinterName'" | Select-Object $selectarray
			} else {
				$CIMPrinter = Get-CimInstance Win32_Printer | Select-Object $selectarray
			}
			if ($CIMPrinter.local -eq "True") {
				$Type = "Local"
			} elseif ($CIMPrinter.Network -eq "True") {
				$Type = "Connection"
			} else {
				$Type = "Unknown"
			}
>>>>>>> 0b434753061ad5cd92b6fb959e24a7a249cccbff
			$CIMPrinter
		}
	}
	end {
			write-verbose "Ending Something"
	}
<<<<<<< HEAD
}
=======
}

>>>>>>> 0b434753061ad5cd92b6fb959e24a7a249cccbff
