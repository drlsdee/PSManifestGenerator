function Get-CommonParameters {
    [CmdletBinding()]
    param (
        # PSBoundParameters of your function!
        [Parameter()]
        #[System.Management.Automation.PSBoundParametersDictionary]
        $BoundParameters
    )
    #$BoundParameters.Keys
    [string[]]$parameterNamesCommon = @(
        [System.Management.Automation.PSCmdlet]::CommonParameters
        [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
    )
    [string[]]$parameterNamesGivenAll = $BoundParameters.Keys
    [string[]]$parameterNamesFiltered = $parameterNamesGivenAll.Where({$_ -notin $parameterNamesCommon})
    $parameterNamesFiltered
}
