<#  #>
function Get-ReportResource {

    <#
    .SYNOPSIS
        Gets a resource in the specified ReturnType (eventually support both a base64 encoded string, and Linked Resource for email
    .DESCRIPTION
        Gets a resource in the specified ReturnType (eventually support both a base64 encoded string, and Linked Resource for email
    .PARAMETER CID

    .PARAMETER ReturnType

    .INPUTS

    .OUTPUTS

    .EXAMPLE

    .EXAMPLE

    .EXAMPLE

    .NOTES
        Author: {Name}
        Email: {Email}
        Last Updated: {Date}
        Last Updated By: {Name}
        Last Update Notes:
            -
    #>

    [OutPutType()]
    [CmdletBinding()]
    param (
        $cid,
        [ValidateSet("embed", "linkedresource")]
        $ReturnType = "embed"
    )

    PROCESS {
        $data = $global:ReportResources[$cid].Data.Split("|")

        # Process each resource type differently
        switch ($data[0]) {

            "File"   {

                # Check the path exists
                if (Test-Path $data[1] -ErrorAction SilentlyContinue) {

                    if ($ReturnType -eq "embed") {

                        # return a MIME/Base64 combo for embedding in HTML
                        $imgData = Get-Content ($data[1]) -Encoding Byte
                        $type = $data[1].substring($data[1].LastIndexOf(".") + 1)
                        return ("data:image/{0};base64,{1}" -f $type, [System.Convert]::ToBase64String($imgData))

                    } # end if

                    if ($ReturnType -eq "linkedresource") {

                        # return a linked resource to be added to mail message
                        $lr = New-Object system.net.mail.LinkedResource($data[1])
                        $lr.ContentId = $cid
                        return $lr

                    } # end if

                } else {

                    Write-Warning ($lang.resFileWarn -f $cid)

                } # end if/else

            } # end file

            "SystemIcons" {

                # Take the SystemIcon Name - see http://msdn.microsoft.com/en-us/library/system.drawing.systemicons(v=vs.110).aspx
                # Load the image into a MemoryStream in PNG format (to preserve transparency)

                [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
                $bmp = ([System.Drawing.SystemIcons]::($data[1])).toBitmap()
                $bmp.MakeTransparent()
                $ms = new-Object IO.MemoryStream
                $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::PNG)
                $ms.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null

                if ($ReturnType -eq "embed") {

                    # return a MIME/Base64 combo for embedding in HTML
                    $byte = New-Object byte[] $ms.Length
                    $ms.read($byte, 0, $ms.length) | Out-Null
                    return ("data:image/png;base64," + [System.Convert]::ToBase64String($byte))

                } # end if

                if ($ReturnType -eq "linkedresource") {

                    # return a linked resource to be added to mail message
                    $lr = New-Object system.net.mail.LinkedResource($ms)
                    $lr.ContentId = $cid
                    return $lr

                } # end if

            } # end SystemIcons

            "Base64" {

                if ($ReturnType -eq "embed") {

                    return ("data:image/{0};base64,{1}" -f $data[1], $data[2])

                } # end if

                if ($ReturnType -eq "linkedresource") {

                    $w  = [system.convert]::FromBase64String($data[2])
                    $ms = new-Object IO.MemoryStream

                    $ms.Write($w, 0, $w.Length)

                    $ms.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null

                    $lr = New-Object system.net.mail.LinkedResource($ms)
                    $lr.ContentId = $cid

                    return $lr

                } # end if

            } # end Base64

        } # end switch

    } # end PROCESS block

} # end function Get-ReportResource