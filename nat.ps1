# Verificar administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {
    Write-Host "Ejecuta PowerShell como Administrador." -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Hyper-V NAT Creator ===`n" -ForegroundColor Cyan

$SwitchName = Read-Host "Nombre del switch"
$NatName    = Read-Host "Nombre de la NAT"
$Network    = Read-Host "Red NAT (ej: 192.168.100.0/24)"
$Gateway    = Read-Host "Gateway (ej: 192.168.100.1)"

# Obtener prefijo
$PrefixLength = [int]($Network.Split('/')[1])

Write-Host "`nCreando switch..." -ForegroundColor Yellow

New-VMSwitch `
    -SwitchName $SwitchName `
    -SwitchType Internal `
    -ErrorAction Stop

Write-Host "OK - Switch creado" -ForegroundColor Green

Write-Host "Configurando gateway..." -ForegroundColor Yellow

New-NetIPAddress `
    -IPAddress $Gateway `
    -PrefixLength $PrefixLength `
    -InterfaceAlias "vEthernet ($SwitchName)" `
    -ErrorAction Stop

Write-Host "OK - Gateway configurado" -ForegroundColor Green

Write-Host "Creando NAT..." -ForegroundColor Yellow

New-NetNat `
    -Name $NatName `
    -InternalIPInterfaceAddressPrefix $Network `
    -ErrorAction Stop

Write-Host "OK - NAT creada" -ForegroundColor Green

Write-Host "`n=== Configuración completada ===" -ForegroundColor Cyan
Write-Host "Switch : $SwitchName"
Write-Host "NAT    : $NatName"
Write-Host "Red    : $Network"
Write-Host "Gateway: $Gateway"
