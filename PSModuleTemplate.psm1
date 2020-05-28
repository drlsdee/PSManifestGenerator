[string]$functionsFolderPath = "$PSScriptRoot\Functions"
[string]$functionsFolderPathPrivate = "$functionsFolderPath\Private"
[string]$functionsFolderPathPublic = "$functionsFolderPath\Public"

[System.IO.FileInfo[]]$functionsPublic = Get-ChildItem -Path $functionsFolderPathPublic -File -Filter '*.ps1'
[System.IO.FileInfo[]]$functionsPrivate = Get-ChildItem -Path $functionsFolderPathPublic -File -Filter '*.ps1'

@($functionsPublic, $functionsPrivate).ForEach({
    . "$($_.FullName)"
})

$functionsPublic.ForEach({
    Export-ModuleMember -Function $_.BaseName
})