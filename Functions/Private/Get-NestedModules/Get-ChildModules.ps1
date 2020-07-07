function Get-ChildModules {
    [CmdletBinding()]
    param (
        # Array of modules
        [Parameter()]
        [psmoduleinfo[]]
        $ModuleList
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    if ($ModuleList.Count -eq 0) {
        Write-Verbose -Message "$theFName Module list is empty. Nothing to do!"
        return
    }

    Write-Verbose -Message "$theFName Received list of $($ModuleList.Count) modules:"
    $ModuleList.ForEach({
        Write-Verbose -Message "$theFName Module `"$($_.Name)`" from path: $($_.Path)"
    })

    [string[]]$pathsToExclude = @()
    [string[]]$cultureNames = [System.Globalization.CultureInfo]::GetCultures('AllCultures')
    [string[]]$foldersToExclude = $ModuleList.ModuleBase.ForEach({
        [string]$mBase = $_
        [System.IO.Directory]::GetDirectories($mBase).Where({
            [System.IO.Path]::GetFileName($_) -in $cultureNames
        })
    })
    [string[]]$filesToExclude = $foldersToExclude.ForEach({
        [System.IO.Directory]::GetFiles($_)
    })
    if ($filesToExclude) {
        $pathsToExclude += $filesToExclude
    }

    [psmoduleinfo[]]$ModuleList = $ModuleList.Where({$_.Path -notin $pathsToExclude})

    [psmoduleinfo[]]$modulesFlat = $ModuleList.Where({
        -not ($_.NestedModules)
    })
    [psmoduleinfo[]]$modulesWithChilds = $ModuleList.Where({
        $_.NestedModules
    })
    [psmoduleinfo[]]$modulesToReturn = @()

    if  (
            (-not $modulesFlat) -and `
            (-not $modulesWithChilds)
    )
    {
        Write-Verbose -Message "$theFName There are no submodules found! Returning null."
        return
    }
    elseif  (
        (-not $modulesWithChilds)
    )
    {
        Write-Verbose -Message "$theFName There are no submodules with child modules. Returning $($modulesFlat.Count) flat submodules."
        return $modulesFlat
    }

    $modulesToReturn += $modulesFlat

    Write-Verbose -Message "$theFName Found $($modulesWithChilds.Count) submodules with child modules. We need to go deeper..."
    $modulesWithChilds.ForEach({
        [string]$modName = $_.Name
        [string]$modPath = $_.Path
        [string[]]$childPaths = $_.NestedModules.Path
        $pathsToExclude += $childPaths.Where({$_ -notin $pathsToExclude})
        Write-Verbose -Message "$theFName Adding module `"$modName`" from path: $modPath"
        $modulesToReturn += $_
        $_.NestedModules.ForEach({
            Write-Verbose -Message "$theFName Parent: $modName; child: $($_.Path)"
        })
    })

    [psmoduleinfo[]]$modulesNextlevel = (Get-ChildModules -ModuleList $modulesWithChilds.NestedModules).Where({
        $_.Path -notin $modulesToReturn.Path
    })

    if ($modulesNextlevel) {
        $modulesNextlevel.ForEach({
            Write-Verbose -Message "$theFName Next level module: $($_.Name); path: $($_.Path)"
        })
        $modulesToReturn += $modulesNextlevel
    }

    # Do some cleanup
    $modulesToReturn = $modulesToReturn.Where({
        $_.Path -notin $pathsToExclude
    })

    Write-Verbose -Message "$theFName End of function. Returning $($modulesToReturn.Count) submodules."
    return $modulesToReturn
}