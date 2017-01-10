function Set-PSPTPrintConfiguration {
    <#
    .SYNOPSIS
    Updates the configuration of an existing printer
    .EXAMPLE
    Set-PSPTPrinter -PrinterName ExamplePrinter -PageSize NorthAmericaLetter
    .PARAMETER PrinterName
    The printer name or array of printers to change settings on
    .PARAMETER PageMediaSize
    Sets the page size for the paper (or other media) that a printer uses for a print job.
    .PARAMETER Collate
    Sets a value indicating whether the printer collates its output.
    .PARAMETER OutputColor
    Sets a value indicating how the printer handles content that has color or shades of gray.
    .PARAMETER Duplexing
    sets a value indicating what kind of two-sided printing, if any, the printer uses for the print job.
    .PARAMETER Stapling
    Sets a value indicating whether, and where, a printer staples multiple pages.
    .PARAMETER PagesPerSheet
    Sets the number of pages that print on each printed side of a sheet of paper.
    .PARAMETER PageOrientation
    Sets a value indicating how the page content is oriented for printing.
    .PARAMETER PageMediaType
    Sets a value indicating what sort of paper or media the printer uses for the print job.
    .PARAMETER InputBin
    Sets a value indicating what input bin (paper tray) to use.
    .PARAMETER OutputQuality
    Sets a value indicating the quality of output for the print job.
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
        [String]$PageMediaSize,

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
        [String]$OutputColor,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 4)]
        [ValidateSet("OneSided","TwoSidedLongEdge","TwoSidedShortEdge")]
        [String]$Duplexing,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 5)]
        [ValidateSet("None","SaddleStitch","StapleBottomLeft","StapleBottomRight","StapleDualBottom","StapleDualLeft","StapleDualRight","StapleDualTop","StapleTopLeft","StapleTopRight")]
        [String]$Stapling,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 6)]
        [ValidateSet(1,2,4,6,9,16)]
        [Int]$PagesPerSheet,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 7)]
        [ValidateSet("Landscape","Portrait","ReverseLandscape","ReversePortrait")]
        [String]$PageOrientation,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 8)]
        [ValidateSet("Archival","AutoSelect","BackPrintFilm","Bond","CardStock","Continuous","EnvelopePlain","EnvelopeWindow","Fabric","HighResolution","Label","MultiLayerForm","MultiPartForm","None","Photographic","PhotographicFilm","PhotographicGlossy","PhotographicHighGloss","PhotographicMatte","PhotographicSatin","PhotographicSemiGloss","Plain","Screen","ScreenPaged","Stationery","TabStockFull","TabStockPreCut","Transparency","TShirtTransfer")]
        [String]$PageMediaType,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 9)]
        [ValidateSet("AutoSelect","AutoSheetFeeder","Cassette","Manual","Tractor")]
        [Int]$InputBin,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        Position = 10)]
        [ValidateSet("Automatic","Draft","Fax","High","Normal","Photographic","Text")]
        [String]$OutputQuality
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
                    #region Foreach parameter, check if it is null. If not, check if capability exists. If so, set Print Tickets to value
                    if ($PageMediaSize) {
                        $PageCaps = $NewQueue.GetPrintCapabilities().PageMediaSizeCapability
                        if ($null -ne $PageCaps) {
                            if ($PageCaps.PageMediaSizeName.Contains([System.Printing.PageMediaSizeName]::$PageMediaSize)) {
                                $NewQueue.DefaultPrintTicket.PageMediaSize = [System.Printing.PageMediaSizeName]::$PageMediaSize
                                $NewQueue.UserPrintTicket.PageMediaSize = [System.Printing.PageMediaSizeName]::$PageMediaSize
                                Write-Verbose "$PageMediaSize set"
                            } else {
                                Write-Error "$PageMediaSize unavailable on $Printer"
                            }
                        }
                    }
                    if ($Collate) {
                            $CollateCaps = $NewQueue.GetPrintCapabilities().CollationCapability
                            if ($null -ne $CollateCaps) {
                                if ($CollateCaps.Contains([System.Printing.Collation]::$Collate)) {
                                    $NewQueue.DefaultPrintTicket.Collation = [System.Printing.Collation]::$Collate
                                    $NewQueue.UserPrintTicket.Collation = [System.Printing.Collation]::$Collate
                                    Write-Verbose "$Collate set"
                                } else {
                                    Write-Error "$Collate unavailable on $Printer"
                                }
                            }
                    }
                    if ($OutputColor) {
                            $OutputColorCaps = $NewQueue.GetPrintCapabilities().OutputColorCapability
                            if ($null -ne $OutputColorCaps) {
                                if ($OutputColorCaps.Contains([System.Printing.OutputColor]::$OutputColor)) {
                                    $NewQueue.DefaultPrintTicket.OutputColor = [System.Printing.OutputColor]::$OutputColor
                                    $NewQueue.UserPrintTicket.OutputColor = [System.Printing.OutputColor]::$OutputColor
                                    Write-Verbose "$OutputColor set"
                                } else {
                                    Write-Error "$OutputColor unavailable on $Printer"
                                }
                            }
                    }
                    if ($Duplexing) {
                        $DuplexCaps = $NewQueue.GetPrintCapabilities().DuplexingCapability
                        if ($null -ne $DuplexCaps) {
                            if ($DuplexCaps.Contains([System.Printing.Duplexing]::$Duplexing)) {
                                $NewQueue.DefaultPrintTicket.Duplexing = [System.Printing.Duplexing]::$Duplexing
                                $NewQueue.UserPrintTicket.Duplexing = [System.Printing.Duplexing]::$Duplexing
                                Write-Verbose "$Duplexing set"
                            } else {
                                Write-Error "$Duplexing unavailable on $Printer"
                            }
                        }
                    }
                    if ($Stapling) {
                        $StapleCaps = $NewQueue.GetPrintCapabilities().StaplingCapability
                        if ($null -ne $StapleCaps) {
                            if ($StapleCaps.Contains([System.Printing.Stapling]::$Stapling)) {
                                $NewQueue.DefaultPrintTicket.Stapling = [System.Printing.Stapling]::$Stapling
                                $NewQueue.UserPrintTicket.Stapling = [System.Printing.Stapling]::$Stapling
                                Write-Verbose "$Stapling set"
                            } else {
                                Write-Error "$Stapling unavailable on $Printer"
                            }
                        }
                    }
                    if ($PagesPerSheet) {
                        $PPSCaps = $NewQueue.GetPrintCapabilities().PagesPerSheetCapability
                        if ($null -ne $PPSCaps) {
                            if ($PPSCaps.Contains($PagesPerSheet)) {
                                $NewQueue.DefaultPrintTicket.PagesPerSheet = $PagesPerSheet
                                $NewQueue.UserPrintTicket.PagesPerSheet = $PagesPerSheet
                                Write-Verbose "$PagesPerSheet Pages Per Sheet set"
                            } else {
                                Write-Error "$PagesPerSheet unavailable on $Printer"
                            }
                        }
                    }
                    if ($PageOrientation) {
                        $OrientationCaps = $NewQueue.GetPrintCapabilities().PageOrientationCapability
                        if ($null -ne $OrientationCaps) {
                            if ($OrientationCaps.Contains([System.Printing.PageOrientation]::$PageOrientation)) {
                                $NewQueue.DefaultPrintTicket.PageOrientation = [System.Printing.PageOrientation]::$PageOrientation
                                $NewQueue.UserPrintTicket.PageOrientation = [System.Printing.PageOrientation]::$PageOrientation
                                Write-Verbose "$PageOrientation set"
                            } else {
                                Write-Error "$PageOrientation unavailable on $Printer"
                            }
                        }
                    }
                    if ($PageMediaType) {
                        $MediaTypeCaps = $NewQueue.GetPrintCapabilities().PageMediaTypeCapability
                        if ($null -ne $MediaTypeCaps) {
                            if ($MediaTypeCaps.Contains([System.Printing.PageMediaType]::$PageMediaType)) {
                                $NewQueue.DefaultPrintTicket.PageMediaType = [System.Printing.PageMediaType]::$PageMediaType
                                $NewQueue.UserPrintTicket.PageMediaType = [System.Printing.PageMediaType]::$PageMediaType
                                Write-Verbose "$PageMediaType set"
                            } else {
                                Write-Error "$PageMediaType unavailable on $Printer"
                            }
                        }
                    }
                    if ($InputBin) {
                        $InputBinCaps = $NewQueue.GetPrintCapabilities().InputBinCapability
                        if ($null -ne $InputBinCaps) {
                            if ($InputBinCaps.Contains([System.Printing.InputBin]::$InputBin)) {
                                $NewQueue.DefaultPrintTicket.InputBin = [System.Printing.InputBin]::$InputBin
                                $NewQueue.UserPrintTicket.InputBin = [System.Printing.InputBin]::$InputBin
                                Write-Verbose "$InputBin set"
                            } else {
                                Write-Error "$InputBin unavailable on $Printer"
                            }
                        }
                    }
                    if ($OutputQuality) {
                        $OutputQualityCaps = $NewQueue.GetPrintCapabilities().OutputQualityCapability
                        if ($null -ne $OutputQualityCaps) {
                            if ($OutputQualityCaps.Contains([System.Printing.OutputQuality]::$OutputQuality)) {
                                $NewQueue.DefaultPrintTicket.OutputQuality = [System.Printing.OutputQuality]::$OutputQuality
                                $NewQueue.UserPrintTicket.OutputQuality = [System.Printing.OutputQuality]::$OutputQuality
                                Write-Verbose "$OutputQuality set"
                            } else {
                                Write-Error "$OutputQuality unavailable on $Printer"
                            }
                        }
                    }
                    #endregion
                    #Save changes to queue and cleanup
                    $NewQueue.commit()
                    $NewQueue.dispose()
                }
                catch {
                    if ($null -ne $NewQueue) {
                        $NewQueue.dispose()
                    }
                    Write-Error "Error configuring $Printer, changes discarded"
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