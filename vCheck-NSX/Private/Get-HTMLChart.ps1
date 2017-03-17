<# Returns HTML fragment for chart. Calls Get-ChartResource to generate chart image #>

function Get-HTMLChart {
	param (
		[string]$cidbase,
		[Object[]]$ChartObjs
	)
	$html = ""
	$i = 0
	foreach ($ChartObj in $ChartObjs) {
		$i++
		$base64 = Get-ChartResource $ChartObj
		$cid = $cidbase + "-" + $i
		Add-ReportResource -cid $cid -ResourceData $Base64 -Type "Base64" -Used $true
		$html += "<img src='cid:$cid' />"
	}
	return $html
}