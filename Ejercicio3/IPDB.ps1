Write-Host "--- INICIANDO ESCANEO DE SEGURIDAD ---" -ForegroundColor Cyan

$listaIPs = Get-ComunicacionIPs

if ($listaIPs) {
    Write-Host "Se encontraron $($listaIPs.Count) IPs unicas. Investigando..." -ForegroundColor Yellow

    $reporteFinal = foreach ($ipIndividual in $listaIPs) {
        Investigar-IP -IP $ipIndividual
    }

    Write-Host "`nDetalle de IPs analizadas:" -ForegroundColor Cyan
    $reporteFinal | Format-Table -AutoSize

    Get-Reporte -Resultados $reporteFinal

    $CarpetaDestino = "$env:USERPROFILE\Desktop"
    $NombreArchivo  = "Reporte_Seguridad_$(Get-Date -Format 'dd-MM-yyyy-HH.mm').csv"
    $RutaCompleta   = Join-Path -Path $CarpetaDestino -ChildPath $NombreArchivo

    Guardar-Reporte -RutaArchivo $RutaCompleta -Contenido $reporteFinal

}
else {
    Write-Host "No se detectaron conexiones externas activas." -ForegroundColor Gray
}

Write-Host "`nProceso Finalizado." -ForegroundColor DarkYellow
