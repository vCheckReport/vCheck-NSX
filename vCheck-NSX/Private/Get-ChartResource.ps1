<# Creates a chart Image #>

function Get-ChartResource {
	param (
		$ChartDef
	)
	[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

	# Create a new chart object
	$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
	$Chart.Width = $ChartDef.width
	$Chart.Height = $ChartDef.height
	$Chart.AntiAliasing = "All"

	# Create a chartarea to draw on and add to chart
	$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
	$Chart.ChartAreas.Add($ChartArea)

	# Set title and axis labels
	if ($ChartDef.title) {
		$titleRef = $Chart.Titles.Add($ChartDef.title)
	}
	if ($ChartDef.titleX) {
		$ChartArea.AxisX.Title = $ChartDef.titleX
	}
	if ($ChartDef.titleY) {
		$ChartArea.AxisY.Title = $ChartDef.titleY
	}

	# change chart colours
	if ($ChartBackground) {
		$Chart.BackColor = Get-ChartColours $ChartBackground
		$ChartArea.BackColor = Get-ChartColours $ChartBackground
	} else {
		$Chart.BackColor = [System.Drawing.Color]::Transparent
		$ChartArea.BackColor = [System.Drawing.Color]::Transparent
	}
	# If we have style
	if ($ChartColours) {
		$Chart.PaletteCustomColors = Get-ChartColours $ChartColours
		$Chart.Palette = [System.Windows.Forms.DataVisualization.Charting.ChartColorPalette]::None
	}

	if ($ChartFontColour) {
		$Chart.ForeColor = Get-ChartColours $ChartFontColour
	}

	# Add data to chart and set chart type
	for ($i = 0; $i -lt $ChartDef.data.count; $i++) {
		[void]$Chart.Series.Add("Data$i")
		$Chart.Series["Data$i"].Points.DataBindXY($ChartDef.data[$i].Keys, $ChartDef.data[$i].Values)
		$Chart.Series["Data$i"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::($ChartDef.ChartType)
	}

	# Do some funky work to increase the DPI so charts look nice. Default 96 DPI looks terrible :(
	[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

	$bmp = New-Object System.Drawing.Bitmap(($ChartDef.width), ($ChartDef.height))
	$bmp.SetResolution(384, 384);
	if ($ChartArea.BackColor -eq [System.Drawing.Color]::Transparent) {
		$bmp.MakeTransparent()
	}
	$chart.DrawToBitmap($bmp, (new-object System.Drawing.Rectangle(0, 0, $ChartDef.width, $ChartDef.height)))
	$ms = new-Object IO.MemoryStream
	$bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png);
	$ms.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
	$byte = New-Object byte[] $ms.Length
	$ms.read($byte, 0, $ms.length) | Out-Null

	return ("png|{0}" -f [System.Convert]::ToBase64String($byte))
}