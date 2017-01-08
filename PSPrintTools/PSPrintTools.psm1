#Get all script files in project root
$ScriptFiles  = @( Get-ChildItem -Path $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue )

#Try to dot source all the script files
Foreach($funct in $ScriptFiles) {
    Try {
        . $funct.fullname
    }
    Catch {
        Write-Error -Message "Import of $($funct.fullname) failed"
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
