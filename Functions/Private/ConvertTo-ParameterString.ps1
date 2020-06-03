function ConvertTo-ParameterString {
    [CmdletBinding()]
    param (
        # Input parameter as collection
        [Parameter(Mandatory)]
        #[ParameterType]
        $InputParameter
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    
    [string]$inputParameterFullName = $InputParameter.GetType().FullName
    [string]$inputParameterBaseType = $InputParameter.GetType().BaseType.FullName
    
    [string[]]$typesAsString = @(
        'System.String'
        'System.Guid'
        'System.Version'
        'System.Uri'
        'System.Reflection.ProcessorArchitecture'
    )
    [string[]]$typesConvertible = @(
        'System.String[]'
    )
    [string[]]$typesNotImplemented = @(
        'System.Collections.Hashtable'
        'System.Object'
        'System.Object[]'
    )

    if      ($inputParameterFullName -in $typesAsString) {
        Write-Verbose -Message "$theFName Type of input parameter is `'$inputParameterFullName`' and may be interpreted as `'System.String`' directly."
        [string]$outputString = $InputParameter
    }
    elseif  ($inputParameterFullName -in $typesConvertible)
    {
        Write-Verbose -Message "$theFName Type of input parameter is `'$inputParameterFullName`' and may be converted to `'System.String`'."
        [string]$paramJoined = @($InputParameter).ForEach({
            "`'$_`'"
        }) -join ', '
        [string]$outputString = "@($paramJoined)"
    }
    elseif  (
                ($inputParameterFullName -in $typesNotImplemented) -and `
                ($inputParameterBaseType -eq 'System.Array')
            )
    {
        Write-Verbose -Message "$theFName Type of input parameter is `'$inputParameterFullName`' and basetype is `'System.Array`'."
        [string]$memberType = $InputParameter[0].GetType().FullName
        if ($memberType -in $typesAsString) {
            Write-Verbose -Message "$theFName Type of array member is `'$memberType`'. Will convert array to string."
            [string]$paramJoined = @($InputParameter).ForEach({
                "`'$_`'"
            }) -join ', '
            [string]$outputString = "@($paramJoined)"
        } else {
            Write-Warning -Message "$theFName Conversion of array of type `'$memberType`' to string is not implemented yet! Return empty string."
            [string]$outputString = ''
        }
    }
    elseif  ($inputParameterFullName -in $typesNotImplemented) {
        Write-Warning -Message "$theFName Type of input parameter is `'$inputParameterFullName`'. Convertion to `'System.String`' is not implemented yet! Return empty string."
        [string]$outputString = ''
    }

    Write-Verbose -Message "$theFName Result: $outputString"
    Write-Verbose -Message "$theFName End of function."
    return $outputString
}
