[string]$functionsFolderPath = "$PSScriptRoot\Functions"
[string]$functionsFolderPathPrivate = "$functionsFolderPath\Private"
[string]$functionsFolderPathPublic = "$functionsFolderPath\Public"

[System.IO.FileInfo[]]$functionsPublic = Get-ChildItem -Path $functionsFolderPathPublic -File -Filter '*.ps1'
[System.IO.FileInfo[]]$functionsPrivate = Get-ChildItem -Path $functionsFolderPathPrivate -File -Filter '*.ps1'

@($functionsPrivate + $functionsPublic).Where({$_.Extension -eq '.ps1'}).FullName.ForEach({
    . $_
})

$functionsPublic.ForEach({
    Export-ModuleMember -Function $_.BaseName
    try {
        Export-ModuleMember -Alias (Get-Alias -Definition $_.BaseName)
    } catch {
        Write-Warning -Message "Function `"$($_.BaseName)`" has no aliases!"
    }
})
