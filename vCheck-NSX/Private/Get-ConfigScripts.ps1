function Get-ConfigScripts {

    return "function createCSV() {
            var inputs = document.getElementsByTagName('input');

            var strsplit = null
            //var output = 'filename,question,var\n'
            var output = '<vCheck>\n'
            for (var i = 0; i < inputs.length; i += 1) {
                strsplit = inputs[i].name.split('|')
                output += '\t<setting>\n'
                output += '\t\t<filename>'
                output += strsplit[0]
                output += '</filename>\n'
                output += '\t\t<question>'
                output += strsplit[1]
                output += '</question>\n'
                output += '\t\t<varname>'
                output += strsplit[2]
                output += '</varname>\n'
                output += '\t\t<var>""'
                output += inputs[i].value
                output += '""</var>\n'
                output += '\t</setting>\n'
            }
            output += '</vCheck>'
            downloadFile('vCheckSettings.xml', output)
        }
        function downloadFile(filename, rows) {
            var fileContent = '';
            for (var i = 0; i < rows.length; i++) {
                fileContent += rows[i];
            }

            var blob = new Blob([fileContent], { type: 'text/xml;charset=utf-8;' });
            if (navigator.msSaveBlob) { // IE 10+
                navigator.msSaveBlob(blob, filename);
            } else {
                var link = document.createElement('a');
                if (link.download !== undefined) { // feature detection
                    // Browsers that support HTML5 download attribute
                    var url = URL.createObjectURL(blob);
                    link.setAttribute('href', url);
                    link.setAttribute('download', filename);
                    link.style.visibility = 'hidden';
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                }
            }
        }"

} # end function Get-ConfigScripts