<# Create a new Chert object, this will get fed back down the output stream as part
   of plugin processing. This allows us to keep the same interface for plugins content #>

function New-Chart {
	param (
		[int]$height,
		[int]$width,
		[Parameter(Mandatory = $true)]
		[Hashtable[]]$data,
		[string]$title,
		[string]$titleX,
		[string]$titleY,
		[ValidateSet("Area", "Bar", "BoxPlot", "Bubble", "Candlestick", "Column", "Doughnut", "ErrorBar", "FastLine",
						 "FastPoint", "Funnel", "Kagi", "Line", "Pie", "Point", "PointAndFigure", "Polar", "Pyramid",
						 "Radar", "Range", "RangeBar", "RangeColumn", "Renko", "Spline", "SplineArea", "SplineRange",
						 "StackedArea", "StackedArea100", "StackedBar", "StackedBar100", "StackedColumn",
						 "StackedColumn100", "StepLine", "Stock", "ThreeLineBreak")]
		$ChartType = "bar"
	)

	# If chartsize is specified in style, use it unless explicitly set
	if ($ChartSize -and (-not $height -and -not $width)) {
		if ($ChartSize -match "(\d+)x(\d+)") {
			$height = $Matches[1]
			$width = $Matches[2]
		}
	}
	# if size not set in style or function call, default to 400x400 (maybe make this a globalVariable?)
	if (-not $ChartSize -and (-not $height -and -not $width)) {
		$height = 400
		$width = 400
	}

	return New-Object PSObject -Property @{
		"height" = $height;
		"width" = $width;
		"data" = $data;
		"title" = $title;
		"titleX" = $titleX;
		"titleY" = $titleY;
		"ChartType" = $ChartType
	}
}