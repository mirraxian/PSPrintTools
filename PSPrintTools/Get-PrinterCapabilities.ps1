function Get-PrinterCapabilities {
    <#
    .SYNOPSIS
    Get the capabilities of a print queue such vailable paper sizes, duplexing/color modes
    .EXAMPLE
    Get-PrinterCapabilities -PrinterName ExamplePrinter
    .PARAMETER PrinterName
    The printer name or array of printers to change settings on
    .LINK
    https://himsel.io
    .LINK
	https://github.com/BenHimsel/PSPrintTools
	.NOTES
    Where applicable, set free under the unlicense: http://unlicense.org/ 
	Author: Ben Himsel
    https://github.com/BenHimsel/PSPrintTools
    .LINK
    https://himsel.io
    .NOTES
    Where applicable, set free under the terms of the Unlicense. http://unlicense.org/
    Author: Ben Himsel
    #>

    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    param (
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 0)]
        [string[]]$PrinterName
    )

    begin {
        Add-Type -AssemblyName System.Printing
        write-verbose "Connecting to Print Server"
        #Set Perms to a variable to use when constructing instance of PrintServer
        $Permissions = [System.Printing.PrintSystemDesiredAccess]::AdministrateServer
        #Set Perms to a variable to use when retrieving Queues from PrintServer
        $QueuePerms = [System.Printing.PrintSystemDesiredAccess]::AdministratePrinter
        #Construct using PrintServer as using LocalPrintServer
        $PrintServer = New-Object System.Printing.LocalPrintServer -ArgumentList $Permissions
    }

    process {
        write-verbose "Starting Processing loop"
        foreach ($Printer in $PrinterName) {
            Write-Verbose "Processing $Printer"
            if ($pscmdlet.ShouldProcess($Printer)) {
                Try {
                    #Create New Queue object to assign properties to WITH permissions to change settings (getting queue from printserver won't have perms)
                    $NewQueue = New-Object System.Printing.PrintQueue -ArgumentList $PrintServer,$Printer,1,$QueuePerms
                    $NewQueue.GetPrintCapabilities()
                    #Clean up connection to print queue
                    $NewQueue.dispose()
                }
                catch {
                    if ($null -ne $NewQueue) {
                        $NewQueue.dispose()
                    }
                    Write-Warning "Error retrieving settings"
                }
            }
        }
    }
    end {
        write-verbose "Cleaning up connection to server"
        $PrintServer.dispose()
    }
}