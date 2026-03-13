
function Get-ComunicacionIPs {
    try {
        $conexiones = Get-NetTCPConnection -State Established -ErrorAction Stop
        $IPsFinales = $conexiones | 
            Where-Object {
                $_.RemoteAddress -notlike '127.*' -and 
                $_.RemoteAddress -notlike '192.168.*' -and
                $_.RemoteAddress -notlike '10.*' -and
                $_.RemoteAddress -ne '::1'
            } |
            Select-Object -ExpandProperty RemoteAddress | Sort-Object -Unique
        return $IPsFinales
    }
    catch {
        Write-Error "Ocurrio un error al mostrar las IPs"
    }
}

function Investigar-IP {
    param(
        [string]$IP
    )

    $ApiKey = " "

    $Headers = @{
        "Key" = $ApiKey
        "Accept" = "application/json"
    }

    $Url = "https://api.abuseipdb.com/api/v2/check?ipAddress=$IP&maxAgeInDays=90"

    try {
        $Respuesta = Invoke-RestMethod -Uri $Url -Headers $Headers -Method Get

        $Resultado = [PSCustomObject]@{
            IP = $IP
            PuntajeAbuso = $Respuesta.data.abuseConfidenceScore
            TotalReportes = $Respuesta.data.totalReports
            Pais = $Respuesta.data.countryCode
        }

        return $Resultado
    }
    catch {
        Write-Warning "No se pudo obtener informacion de la IP: $IP"
    }
}

function Get-Reporte {
    param(
        [Parameter(Mandatory)]
        [array]$Resultados,
        [int]$UmbralPeligro = 50
    )

    $Peligrosas  = ($Resultados | Where-Object { $_.PuntajeAbuso -ge $UmbralPeligro }).Count
    $Sospechosas = ($Resultados | Where-Object { $_.PuntajeAbuso -ge 20 -and $_.PuntajeAbuso -lt $UmbralPeligro }).Count
    $Limpias     = ($Resultados | Where-Object { $_.PuntajeAbuso -lt 20 }).Count

    Write-Host "`n----------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  RESUMEN" -ForegroundColor White
    Write-Host "------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Total analizadas    : $($Resultados.Count)" 
    Write-Host "  Peligrosas (>=$UmbralPeligro%)  : $Peligrosas"  -ForegroundColor Red
    Write-Host "  Sospechosas (>=20%) : $Sospechosas" -ForegroundColor Yellow
    Write-Host "  Sin riesgo  (<20%)  : $Limpias"     -ForegroundColor Green
    Write-Host "------------------------------------------------------`n" -ForegroundColor DarkGray
}

function Guardar-Reporte {
    param(
        [string]$RutaArchivo,
        [array]$Contenido 
    )

    $Contenido | Export-Csv -Path $RutaArchivo -NoTypeInformation -Encoding UTF8
    Write-Host "Reporte guardado exitosamente en: $RutaArchivo" -ForegroundColor Green
}