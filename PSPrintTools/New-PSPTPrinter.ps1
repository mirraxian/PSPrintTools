function New-PSPTPrinter {
    <#
	.SYNOPSIS
	Creates a new printer
	.EXAMPLE
	Set-PSPTPrinter 
	.INPUTS
	Description of objects that can be piped to the script
	.OUTPUTS
	Description of objects that are output by the script
	.PARAMETER Name
	The name of the new queue.
	.PARAMETER Comment
	A comment about the queue.
	.PARAMETER DriverName
	The path and name of the printer driver.
	.PARAMETER KeepPrintedJobs
	The printer language file is not deleted after the file prints.
	.PARAMETER Location
	The description of the location of the new queue.
	.PARAMETER PortName
	The IDs of the port that the new queue uses.
	.PARAMETER PrintProcessor
	The name of the print processor.
	.PARAMETER Priority
	A value from 1 through 99 that specifies the priority of this print queue relative to other queues that are hosted by the print server.
	.PARAMETER Published
	The print queue is visible to other network users.
	.PARAMETER SeparatorPageFile
	The path of a file that is inserted at the beginning of each print job.
	.PARAMETER Shared
	Determines if the print queue is shared over the network.
	.PARAMETER ShareName
	The share name of the new queue.
	.PARAMETER DefaultJobPriority
	A value from 1 to 99 that specifies the default priority of print jobs that are sent to the queue.
	.PARAMETER PrintSpooledJobsFirst
	The queue prints a fully spooled job before it prints higher priority jobs that are still spooling.
	.PARAMETER EnableBidirectionalCom
	The printer's bidirectional communication is enabled.
	.PARAMETER RawOnly
	The print queue cannot use enhanced metafile (EMF) printing.
	.PARAMETER Direct
	The print queue sends print jobs immediately to the printer instead of spooling jobs first.
	.PARAMETER Hidden
	The print queue is not visible in the application UI.
	.PARAMETER EnableDevQuery
	The queue holds its jobs when the document and printer configurations do not match.
	.LINK
    https://himsel.io
    .LINK
	https://github.com/BenHimsel/PSPrintTools
	.NOTES
    Where applicable, set free under the unlicense: http://unlicense.org/ 
	Author: Ben Himsel
	#>
	
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0)]
        [Alias("PrinterName")]
        [string[]]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 1)]
        [string]$Comment = "",

        [Parameter(Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 2)]
        [string]$DriverName,

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 3)]
        [bool]$KeepPrintedJobs = $False,		
		
        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 4)]
        [string]$Location = "",

        <# Maybe Later...
		[Parameter(Mandatory=$True,
		ValueFromPipelineByPropertyName=$True,
		Position = 5)]
		[string]$PermissionSDDL,
#>
        [Parameter(Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 6)]
        [string]$PortName,

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 7)]
        [string]$PrintProcessor = "winprint",

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 8)]
        [Int]$Priority = 1,

        [Parameter(Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 9)]
        [bool]$Published = $False,

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 10)]
        [string]$SeparatorPageFile = "",

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 11,
            ParameterSetName = "IsShared")]
        [bool]$Shared = $False,

        [Parameter(Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 12,
            ParameterSetName = "IsShared")]
        [string]$ShareName,

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 13)]
        [Int]$DefaultJobPriority = 1,

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 14)]
        [Alias("ScheduleCompletedJobsFirst")]
        [Bool]$PrintSpooledJobsFirst = $False,

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 15)]
        [Alias("EnableBiDi")]
        [Bool]$EnableBidirectionalCom,

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 16)]
        [Bool]$RawOnly = $False,

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 16)]
        [Bool]$Direct = $False,

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 16)]
        [Bool]$Hidden = $False,

        [Parameter(ValueFromPipelineByPropertyName = $True,
            Position = 16)]
        [Bool]$EnableDevQuery = $False
		

    )

    begin {
        Add-Type -AssemblyName System.Printing
        write-verbose "Connecting to Print Server"
        #Set up Permission variables with appropriate access
        $Permissions = [System.Printing.PrintSystemDesiredAccess]::AdministrateServer
        #Connect to local computer with administrative rights to printers
        $PrintServer = new-object System.Printing.LocalPrintServer -ArgumentList $Permissions
    }

    process {
        foreach ($Printer in $Name) {
            if ($pscmdlet.ShouldProcess($Printer)) {
                #Create PrintQueueAttributes
                #https://msdn.microsoft.com/en-us/library/system.printing.printqueueattributes(v=vs.110).aspx
                $PrintQueueAttribInt = 0
                If ($Direct) { $PrintQueueAttribInt += 2 }
                If ($Shared) { $PrintQueueAttribInt += 8 }
                If ($Hidden) { $PrintQueueAttribInt += 32 }
                If ($EnableDevQuery) { $PrintQueueAttribInt += 128 }
                If ($KeepPrintedJobs) { $PrintQueueAttribInt += 256 }
                If ($PrintSpooledJobsFirst) { $PrintQueueAttribInt += 512 }
                If ($EnableBidirectionalCom) { $PrintQueueAttribInt += 2048 }
                If ($RawOnly) { $PrintQueueAttribInt += 4096 }				
                If ($Published) { $PrintQueueAttribInt += 8192 }
                $PrintQueueAttributes = [System.Printing.PrintQueueAttributes]$PrintQueueAttribInt

                $PrintServer.InstallPrintQueue($Printer, $DriverName, $PortName, $PrintProcessor, $PrintQueueAttributes, $ShareName, $Comment, $Location, $SeparatorPageFile, $Priority, $DefaultJobPriority)
				
            }
        }
    }
    end {
        write-verbose "Committing changes and cleaning up"
        #Save changes to Server and cleanup
        $PrintServer.commit()
        $PrintServer.dispose()
    }
}