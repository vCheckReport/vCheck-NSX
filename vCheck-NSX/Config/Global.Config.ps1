# You can change the following defaults by altering the below settings:



$Global:vCheckEnv = @{

    SetupWizard              = $true  # Set the following to true to enable the setup wizard for first time run
    ReportHeader             = "vCheck" # Report header
    DisplaytoScreen          = $true   # Would you like the report displayed in the local browser once completed ?
    DisplayReportEvenIfEmpty = $true   # Display the report even if it is empty?
    SendEmail                = $false   # Use the following item to define if an email report should be sent once completed
    SMTPSRV                  = "mysmtpserver.mydomain.local"   # Please Specify the SMTP server address (and optional port) [servername(: port)]
    EmailSSL                 = $false   # Would you like to use SSL to send email?
    EmailFrom                = "me@mydomain.local"   # Please specify the email address who will send the vCheck report
    EmailTo                  = "me@mydomain.local"   # Please specify the email address(es) who will receive the vCheck report (separate multiple addresses with comma)
    EmailCc                  = ""   # Please specify the email address(es) who will be CCd to receive the vCheck report (separate multiple addresses with comma)
    EmailSubject             = "$Server vCheck Report"   # Please specify an email subject
    EmailReportEvenIfEmpty   = $true   # Send the report by e-mail even if it is empty?
    SendAttachment           = $false   # If you would prefer the HTML file as an attachment then enable the following:
    Style                    = "VMware"   # Set the style template to use.
    reportOnPlugins          = $true   # Do you want to include plugin details in the report?
    ListEnabledPluginsFirst  = $true   # List Enabled plugins first in Plugin Report?
    TimeToRun                = $true   # Set the following setting to $true to see how long each Plugin takes to run as part of the report
    PluginSeconds            = 30   # Report on plugins that take longer than the following amount of seconds

} # end $globalVariables