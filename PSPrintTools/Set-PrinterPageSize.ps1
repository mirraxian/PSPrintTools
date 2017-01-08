function Set-PrinterPageSize {
    <#
    .SYNOPSIS
    Sets the Page Size on a Printer
    .EXAMPLE
    Set-PrinterPageSize -PrinterName ExamplePrinter -PageSize NorthAmericaLetter
    .PARAMETER PrinterName
    The printer name or array of printers to change settings on
    .PARAMETER PageSize
    The paper size to set the PageSize to
    #>

    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    param (
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 0)]
        [string[]]$PrinterName,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 1)]
        [ValidateSet("NorthAmericaLegal","NorthAmerica11x17","NorthAmericaLetter","ISOA3","ISOA4","ISOA5","JISB4","JISB5","OtherMetricFolio","NorthAmericaNumber9Envelope","NorthAmericaNumber10Envelope","ISODLEnvelope","ISOC5Envelope","ISOC4Envelope","ISOC6Envelope","NorthAmericaMonarchEnvelope","NorthAmericaPersonalEnvelope","NorthAmericaTabloidExtra","ISOA6")]
        [String]$PageSize = "NorthAmericaLetter"
    )

    begin {
        Add-Type -AssemblyName System.Printing
        write-verbose "Connecting to Print Server"
        #Set Perms to a variable to use when constructing instance of PrintServer
        $Permissions = [System.Printing.PrintSystemDesiredAccess]::AdministrateServer
        #Set Perms to a variable to use when retrieving Queues from PrintServer
        $QueuePerms = [System.Printing.PrintSystemDesiredAccess]::AdministratePrinter
        #Construct using PrintServer as using LocalPrintServer
        $PrintServer = new-object System.Printing.LocalPrintServer -ArgumentList $Permissions
    }

    process {
        write-verbose "Starting Procesing loop"
        foreach ($Printer in $PrinterName) {
            Write-Verbose "Processing $Printer"
            if ($pscmdlet.ShouldProcess($Printer)) {
                Try {
                    #Create New Queue object to assign properties to WITH permissions to change settings (getting queue from printserver won't have perms)
                    $NewQueue = New-Object System.Printing.PrintQueue -ArgumentList $PrintServer,$Printer,1,$QueuePerms
                    #Check that Queue is capable of that page size, and set if so
                    $PageCaps = $NewQueue.GetPrintCapabilities().PageMediaSizeCapability
                    if ($null -ne $PageCaps) {
                        if ($PageCaps.PageMediaSizeName.Contains([System.Printing.PageMediaSizeName]::$PageSize)) {
                            #Set Page Size in default settings
                            $NewQueue.DefaultPrintTicket.PageMediaSize = [System.Printing.PageMediaSizeName]::$PageSize
                            #Win7 also requires setting userprint ticket
                            $NewQueue.UserPrintTicket.PageMediaSize = [System.Printing.PageMediaSizeName]::$PageSize
                        } else {
                            Write-Warning "$PageSize unavailable on $Printer"
                        }
                    }
                    #Save changes to queue and cleanup
                    $NewQueue.commit()
                    $NewQueue.dispose()
                }
                catch {
                    if ($null -ne $NewQueue) {
                        $NewQueue.dispose()
                    }
                    Write-Warning "Error setting Page size on $Printer"
                }
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