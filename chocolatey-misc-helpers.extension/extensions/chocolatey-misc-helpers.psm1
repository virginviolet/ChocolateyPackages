# chocolatey-misc-helpers.extension v0.0.4 (08-24-2020) by Bill Curran - public domain

$scriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition

# LogLevel enum used for Start-CheckAndStop
enum MiscHelpers_LogLevel {
    None
    Success
    Error
    Warning
    Verbose
    Debug
}

$publicFunctions = @(
    'Enable-AutoPin',
	'Show-ToastMessage',
    'Show-Patreon',
	'Show-PayPal',
    'Start-CheckandStop',
	'Start-CheckandThrow',
	'Start-WaitandStop',
	'Start-WaitandStopActual',
    'Test-Dependency',
    'Test-URL'
)
 
Get-ChildItem -Path "$scriptRoot\*.ps1" | ForEach-Object { . $_ }
Export-ModuleMember -Function $publicFunctions