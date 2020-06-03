function Backup-OldManifest {
    [CmdletBinding()]
    param (
        # Path to local repository
        [Parameter(Mandatory)]
        [string]
        $Path,

        # Action: backup (default), restore, remove
        [Parameter()]
        [ValidateSet('Backup', 'Restore', 'Remove')]
        [string]
        $Action
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    [string]$backupExtension = '.old'
    [System.IO.FileInfo[]]$moduleFilesAll = Get-ChildItem -Path $Path -File
    [System.IO.FileInfo[]]$moduleScriptsAll = $moduleFilesAll.Where({$_.Extension -eq '.psm1'})
    [System.IO.FileInfo[]]$moduleManifestsAll = $moduleFilesAll.Where({$_.Extension -eq '.psd1'})
    [System.IO.FileInfo[]]$moduleManifestsBackups = $moduleFilesAll.Where({($_.Extension -eq $backupExtension) -and ($_.BaseName -match '.psd1$')})
    
    switch ($Action) {
        'Backup'    {
            if ($moduleManifestsAll.Count -eq 0) {
                Write-Warning -Message "$theFName Manifest files are not found! Exiting."
                return
            } else {
                Write-Verbose -Message "$theFName Found $($moduleManifestsAll.Count) manifests."
                $moduleManifestsAll.ForEach({
                    [string]$nameOfSource = $_.FullName
                    [string]$nameOfBackup = "$($nameOfSource)$($backupExtension)"
                    Copy-Item -Path $nameOfSource -Destination $nameOfBackup -Force
                })
            }
        }
        'Restore'   {
            if ($moduleManifestsBackups.Count -eq 0) {
                Write-Warning -Message "$theFName Backups are not found! Exiting."
                return
            } else {
                Write-Verbose -Message "$theFName Found $($moduleManifestsBackups.Count) backups."
                $moduleManifestsBackups.ForEach({
                    [string]$nameOfBackup = $_.FullName
                    [string]$nameToRestore = $nameOfBackup -replace $backupExtension
                    Copy-Item -Path $nameOfBackup -Destination $nameToRestore -Force
                })
            }
        }
        'Remove'    {
            if ($moduleManifestsBackups.Count -eq 0) {
                Write-Warning -Message "$theFName Backups are not found! Exiting."
                return
            } else {
                Write-Verbose -Message "$theFName Found $($moduleManifestsBackups.Count) backups."
                $moduleManifestsBackups.ForEach({
                    Remove-Item -Path $_.FullName -Force
                })
            }
        }
    }

    Write-Verbose -Message "$theFName End of function."
}
