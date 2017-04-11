$TestFolder = Split-Path -Parent $MyInvocation.MyCommand.Path

$ProjectRoot = Split-Path -Parent $TestFolder

$ModuleName = Split-Path $ProjectRoot -Leaf

$Manifest = Get-ChildItem (Join-Path $ProjectRoot $ModuleName) -Filter *.psd1

$ManifestName = $Manifest.BaseName

$Tests = Get-ChildItem $TestFolder -Filter "*Tests.ps1"

$FunctionScripts = Get-ChildItem (Join-Path $ProjectRoot $ModuleName) -Filter '*.ps1' -Recurse

Describe "Testing Module Layout" {

    It "Has one Module Manifest" {

        $Manifest.Count | Should be 1
    }

    It "has a Module Manifest that matches the project folder name" {

       $ManifestName | Should Be $ModuleName
    }

    It "has Tests which are located in a subfolder named Tests" {

        $Tests.Count | Should Not be 0
    }
}


Import-Module $Manifest.FullName

$ModuleData = Get-Module $ModuleName

Describe "Testing Module Manifest" {

    It 'Imports the Manifest' {

        $ModuleData | Should Not BeNullOrEmpty
    }

}


foreach($Function in $FunctionScripts) {

    Describe "Testing Function: $($Function.BaseName)" {

        It "Can be Tokenized" {

            $contents = Get-Content -Path $Function.FullName -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }

        It "Has a Test in the Tests Folder" {

            $Tests.BaseName -contains "$($Function.BaseName).Tests" | Should Be $True 

        }
        

        It 'Is exported with the same name as the script' {

            $ModuleData.ExportedFunctions.Values.Name -contains $($Function.BaseName) | Should Be $True 

        }

        It 'Passes the Script Analyzer ' {
            #The plural from .Net makes more sense than following the singular noun rule
            if ($Function.BaseName -eq "Get-PrinterCapabilities") {
                 (Invoke-ScriptAnalyzer -Path $Function.Fullname -ExcludeRule PSUseSingularNouns).Count | Should Be 0
            } else {
                (Invoke-ScriptAnalyzer -Path $Function.Fullname -ExcludeRule PSUseSingularNouns).Count | Should Be 0
            }
        }
    }
}