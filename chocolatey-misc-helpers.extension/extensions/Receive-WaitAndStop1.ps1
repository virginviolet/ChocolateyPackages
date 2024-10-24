$ErrorActionPreference = 'Stop'

function Receive-WaitAndStop {
    Write-Debug "Receive-WaitAndStop started."
    Receive-Job -Name WaitAndStop @args
}
