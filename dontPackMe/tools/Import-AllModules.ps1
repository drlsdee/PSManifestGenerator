function Import-AllModules {
    [CmdletBinding()]
    param (
        [Parameter()]
        # Path to local repository
        [string]
        $Path,
        
        [Parameter()]
        [ValidateSet('Load', 'Unload')]
        # Load or unload
        [string]
        $Action
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Search for modules in `"$Path`""

    [System.Management.Automation.PSModuleInfo[]]$modulesAll = Get-Module -Name $Path -ListAvailable -Verbose -Refresh
    Write-Verbose "Found $($modulesAll.Count) modules:"
    $modulesAll.ForEach({
        [string]$modulePath = $_.Path
        [string]$moduleName = $_.Name
        Write-Verbose -Message "$theFName Module path: `"$modulePath`"; module name: `"$moduleName`""
        
        switch ($Action) {
            'Load'      {
                Import-Module -Name $modulePath -Force
            }
            'Unload'    {
                Get-Module -Name $moduleName | Remove-Module -Force
            }
        }
    })
}