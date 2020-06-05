[string]$functionsFolderPath = "$PSScriptRoot\Functions"
[string]$functionsFolderPathPrivate = "$functionsFolderPath\Private"
[string]$functionsFolderPathPublic = "$functionsFolderPath\Public"

[System.IO.FileInfo[]]$functionsPublic = Get-ChildItem -Path $functionsFolderPathPublic -File -Filter '*.ps1'
[System.IO.FileInfo[]]$functionsPrivate = Get-ChildItem -Path $functionsFolderPathPrivate -File -Filter '*.ps1'

@($functionsPrivate + $functionsPublic).Where({$_.Extension -eq '.ps1'}).ForEach({
    Write-Verbose -Message "Dot sourcing the function `"$($_.BaseName)`" from path `"$($_.FullName)`"..." -Verbose
    . $_.FullName
})

$functionsPublic.ForEach({
    [string]$functionName = $_.BaseName
    Export-ModuleMember -Function $functionName
    try {
        [string[]]$aliasNames = Get-Alias -Definition $functionName -ErrorAction Stop
        $aliasNames.ForEach({
            Write-Verbose -Message "Found alias `"$($_)`" for function `"$($functionName)`". Exporting..." -Verbose
            Export-ModuleMember -Alias $_
        })
    } catch {
        Write-Warning -Message "Function `"$($functionName)`" has no aliases!"
    }
})
