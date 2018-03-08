# Based on the original works by captainmac40 (Zabbix Forums)
# Additional discovery functionality such as defining value types, mapping sensor parents to hardware names by ClontarfX, and other minor tweaks.
# All changes after 1:22AM 09-03-2018 AWST should be listed via GitHub @ https://github.com/clontarfx/zabbix-template-openhardwaremonitor

# Define temporary files

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

$strFileName=".\sensors.dat"
$strFileName2=".\sensortmp.dat"

If (Test-Path $strFileName){
	del $strFileName
}

If (Test-Path $strFileName2){
	del $strFileName2
}

# JSON Formats

$sensoridentifier		= '{"{#SENSOR_IDENTIFIER}":"'
$hardwarename			= '","{#HARDWARE_NAME}":"'
$hardwareidentifier		= '","{#HARDWARE_IDENTIFIER}":"'
$sensorparent			= '","{#SENSOR_PARENT}":"'
$sensorname				= '","{#SENSOR_NAME}":"'
$sensortype				= '","{#SENSOR_TYPE}":"'
$json_close				= '"},'

$bcl = 1

# Start JSON

ADD-content -path $strFileName -value '{"data":['

# Discover WMI objects

Get-WmiObject -Namespace "Root\OpenHardwareMonitor" -Query "SELECT * FROM Sensor" | ForEach-Object {

	# TODO: where Sensor.Parent -Match Hardware.Identifier; {#DISPLAYNAME} = Hardware.Name
	
	if ($_.SensorType -Match "Voltage") {
		$_.SensorType = 'volts'
		$_.Name = 'Voltage - ' + $_.Name
	}

	if ($_.SensorType -Match "Fan") {
		$_.SensorType = 'RPM'
		$_.Name = 'Speed - ' + $_.Name
	}

	if ($_.SensorType -Match "Temperature") {
		$_.SensorType = 'C'
		$_.Name = 'Temperature - ' + $_.Name
	}

	if ($_.SensorType -Match "Load") {
		$_.SensorType = '%'
		$_.Name = 'Load % - ' + $_.Name
	}

	if ($_.SensorType -Match "Data") {
		$_.SensorType = ''
	}

	if ($_.SensorType -Match "SmallData") {
		$_.SensorType = ''
	}

	if ($_.SensorType -Match "Control") {
		$_.SensorType = '%'
		$_.Name = 'Control - ' + $_.Name
	}

	if ($_.SensorType -Match "Clock") {
		$_.SensorType = 'hz'
		$_.Name = 'Clock Speed - ' + $_.Name
	}

	$discovered_sensor = $sensoridentifier + $_.Identifier + $sensorname + $_.Name + $sensortype + $_.SensorType + $sensorparent + $_.Parent
	
	Get-WmiObject -Namespace "Root\OpenHardwareMonitor" -Query "SELECT * FROM Hardware WHERE Identifier = '$($_.Parent)'" | ForEach-Object {

    	$discovered_sensor = $discovered_sensor + $hardwarename + $_.Name + $json_close

    }
	
    ADD-content -path $strFileName -value $discovered_sensor
    $bcl = $bcl +1
}

(get-content $strFileName -totalcount $bcl)[-1] | foreach-object {$_ -replace "},","}" | add-content $strFileName}
$bcl = $bcl - 2
$fichier = get-content $strFileName
$fichier[0..$bcl] > $strFileName2
$bcl = $bcl + 2
$fichier[$bcl] >> $strFileName2
move $strFileName2 $strFileName -Force 
']}' >> $strFileName
Get-Content $strFileName