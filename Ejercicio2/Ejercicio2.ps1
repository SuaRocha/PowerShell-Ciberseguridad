
try{
	$fechaejecucion = Get-Date -Format "dd-MM-yyyy-HH.mm"
	$rutaarchivo = "$PSScriptRoot\Reporte_$fechaejecucion.txt"
	Start-Transcript -Path $rutaarchivo -Append
	#Indico que se inicie el transcript y se guarde en la ruta que le proporciono con el nombre report y la fecha usando get-date, pongo ese formato ya que windows 	no permite /, \ o : en nombre de archivos
	$IPs = Read-Host "Ingrese las IPs. ejemplo:(1.1.1.1, 123.34.32.1)"
	$listaIPs = $IPs -split ","
	#-split: divide lo que recibe por cada "," que ve, haciendo como una lista y diviendo los elementos
	$puertos = Read-Host "Ingrese los puertos. ejemplo:(45, 80, 443)"
	$listapuertos = $puertos -split ","

	$ipexi = @()
	$ipfal = @()
	$pueabie = @()
	$puefal = @()
	foreach($ip in $listaIPs){
		$ip = $ip.Trim()
		#.Trim(): sirve para eliminar los espacios en blancos que puede contener, igual se puede con otro elemento
		$testip = Test-NetConnection $ip -InformationLevel Quiet
		#creamos una variable para guardar la ejecución del ping y enseguida hacemos un if para saber dividir a las que SI responden de las que no, para eso 		sirve Informationlevel quiet
		if ($testip){
			Write-Host "Conexion exitosa - $ip"
			$ipexi += $ip
		} else {
			Write-Host "Conexion fallida - $ip"
			$ipfal += $ip
		}
	}
	foreach($ipe in $ipexi){
		foreach($pue in $listapuertos){
		$testpuer = Test-NetConnection -ComputerName $ipe -Port $pue -WarningAction SilentlyContinue -InformationLevel Quiet
		#Warning-Action SilentlyContinue: si da un error seguira corriendo normal en ves de mostrar el error, ya que es posible que la ip funcione pero el puerto no y viceversa
		#-InformationLevel Quiet: es para decidir cuenta informacion nos muestra al ejectuar y evitar que nos muestre cada cosa que pasa osea que trabaja por asi decirlo en segundo plano y solo muestra el resultado final 
			if ($testpuer){
				Write-Host "Conexion con puerto exitosa - $pue"
				$pueabie += $pue
			} else {
				Write-Host "Conexion con puerto fallida - $pue"
				$puefal += $pue
			}
		}
	}
}
finally {
	Write-Host "--------------------------------------------"
	Write-Host "Reporte de conexion:"
	Write-Host "IPs exitosas:" -ForegroundColor Green
	$ipexi
	Write-Host "IPs fallidas:" -ForegroundColor Red
        Write-Host "--------------------------------------------"
	$ipfal
	Write-Host "Puertos abiertos:" -ForegroundColor Green
	$pueabie
	Write-Host "Puertos fallidos:" -ForegroundColor Red
	$puefal
	
}
