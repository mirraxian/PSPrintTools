function Set-PSPTPrintConfiguration {
    <#
    .SYNOPSIS
    Updates the configuration of an existing printer
    .EXAMPLE
    Set-PSPTPrinter -PrinterName ExamplePrinter -PageSize NorthAmericaLetter
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
        [String]$PaperSize,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 2)]
        [ValidateSet("Uncollated","Collated")]
        [String]$Collate,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 3)]
        [ValidateSet("Color","Greyscale","Monochrome")]
        [String]$Color,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 4)]
        [ValidateSet("OneSided","TwoSidedLongEdge","TwoSidedShortEdge")]
        [String]$DuplexingMode
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

                #Create New Queue object to assign properties to WITH permissions to change settings (getting queue from printserver won't have perms)
                $NewQueue = New-Object System.Printing.PrintQueue -ArgumentList $PrintServer,$Printer,1,$QueuePerms
                Try {
                    if ($PaperSize) {
                        #Check that Queue is capable of that page size, and set if so
                        $PageCaps = $NewQueue.GetPrintCapabilities().PageMediaSizeCapability
                        if ($null -ne $PageCaps) {
                            if ($PageCaps.PageMediaSizeName.Contains([System.Printing.PageMediaSizeName]::$PaperSize)) {
                                #Set Page Size in default settings
                                $NewQueue.DefaultPrintTicket.PageMediaSize = [System.Printing.PageMediaSizeName]::$PaperSize
                                #Win7 also requires setting userprint ticket
                                $NewQueue.UserPrintTicket.PageMediaSize = [System.Printing.PageMediaSizeName]::$PaperSize
                            } else {
                                Write-Warning "$PaperSize unavailable on $Printer"
                            }
                        }
                    }
                    if ($Collate) {
                            #Check that Queue is capable of that collation, and set if so
                            $CollateCaps = $NewQueue.GetPrintCapabilities().CollationCapability
                            if ($null -ne $CollateCaps) {
                                if ($CollateCaps.Contains([System.Printing.Collation]::$Collate)) {
                                    #Set collation in default settings
                                    $NewQueue.DefaultPrintTicket.Collation = [System.Printing.Collation]::$Collate
                                    #Win7 also requires setting userprint ticket
                                    $NewQueue.UserPrintTicket.Collation = [System.Printing.Collation]::$Collate
                                } else {
                                    Write-Warning "$Collate unavailable on $Printer"
                                }
                            }
                    }
                    if ($Color) {
                            #Check that Queue is capable of that output color, and set if so
                            $ColorCaps = $NewQueue.GetPrintCapabilities().OutputColorCapability
                            if ($null -ne $ColorCaps) {
                                if ($ColorCaps.Contains([System.Printing.OutputColor]::$Color)) {
                                    #Set color in default settings
                                    $NewQueue.DefaultPrintTicket.OutputColor = [System.Printing.OutputColor]::$Color
                                    #Win7 also requires setting userprint ticket
                                    $NewQueue.UserPrintTicket.OutputColor = [System.Printing.OutputColor]::$Color
                                } else {
                                    Write-Warning "$Color unavailable on $Printer"
                                }
                            }
                    }
                    if ($DuplexingMode) {
                        #Check that Queue is capable of that output color, and set if so
                        $DuplexCaps = $NewQueue.GetPrintCapabilities().DuplexingCapability
                        if ($null -ne $DuplexCaps) {
                            if ($DuplexCaps.Contains([System.Printing.Duplexing]::$DuplexingMode)) {
                                #Set color in default settings
                                $NewQueue.DefaultPrintTicket.Duplexing = [System.Printing.Duplexing]::$DuplexingMode
                                #Win7 also requires setting userprint ticket
                                $NewQueue.UserPrintTicket.Duplexing = [System.Printing.Duplexing]::$DuplexingMode
                            } else {
                                Write-Warning "$DuplexingMode unavailable on $Printer"
                            }
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
                    Write-Warning "Error configuring $Printer"
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