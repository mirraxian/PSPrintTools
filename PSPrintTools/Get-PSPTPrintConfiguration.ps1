function Get-PSPTPrintConfiguration {
	<#
	.SYNOPSIS
	A recreation of the Get-PrintConfiguration Cmdlet without the MSFT class
	.EXAMPLE
	Get-PSPTPrinter -ComputerName ExampleComputer,LocalHost
	.PARAMETER ComputerName
	The computer name or array of computers to query, defaults to localhost
	.PARAMETER PrinterName
	The name or array of names of printers to filter against, defaults to unfiltered
	.OUTPUTS
	Microsoft.Management.Infrastructure.CimInstance#ROOT/StandardCimv2/MSFT_Printer without RenderingMode, JobCount, DisableBranchOfficeLogging, or BranchOfficeOfflineLogSizeMB
	.LINK
    https://himsel.io
    .LINK
	https://github.com/BenHimsel/PSPrintTools
	.NOTES
    Where applicable, set free under the unlicense: http://unlicense.org/ 
	Author: Ben Himsel
    .LINK
    https://github.com/BenHimsel/PSPrintTools
    .LINK
    https://himsel.io
    .NOTES
    Where applicable, set free under the terms of the Unlicense. http://unlicense.org/
    Author: Ben Himsel
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
	
	}

	process {
		write-verbose "Checking ComputerName"
		if ($ComputerName) {
			write-verbose "Starting Processing loop"
			foreach ($computer in $ComputerName) {
				Write-Verbose "Processing $computer"
				if ($pscmdlet.ShouldProcess($computer)) {
					#add filter if there's a printername
					if ($PrinterName) {
						#$CIMPrinter = Get-CimInstance -ComputerName $computer -ClassName Win32_Printer -Filter "Name like '$PrinterName'" | Select-Object $selectarray
					} else {
						#$CIMPrinter = Get-CimInstance -ComputerName $computer -ClassName Win32_Printer | Select-Object $selectarray
					}
				} 
			}
		} else {
			#add filter if there's a printername
			write-verbose "No ComputerName, skip Processing loop"
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
			$CIMPrinter
		}
	}
	end {
			write-verbose "Ending Something1"
	}
}