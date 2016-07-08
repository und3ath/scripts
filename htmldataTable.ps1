# Enhancing ConvertTo-html cmdlet with HTMLDataTable 
# using jquery and css from CDN but can be hosted locally . 
# und3ath 06/07/2016


$jqueryUiTheme = @{
"black-tie" = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/black-tie/jquery-ui.css";
"blitzer"   = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/blitzer/jquery-ui.css";
"cupertino" = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/cupertino/jquery-ui.css";
"dark-hive" = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/dark-hive/jquery-ui.css";
"dot-luve"  = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/dot-luv/jquery-ui.css";
"eggplant"  = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/eggplant/jquery-ui.css";
"exit-bike" = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/excite-bike/jquery-ui.css";
"flick"     = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/flick/jquery-ui.css";
"hot-sneak" = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/hot-sneaks/jquery-ui.css";
"hummanity" = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/humanity/jquery-ui.css";
"le-frog"   = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/le-frog/jquery-ui.css";
"mint-choc" = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/mint-choc/jquery-ui.css";
"overcast"  = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/overcast/jquery-ui.css";
"smoothness"= "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/smoothness/jquery-ui.css";
"ui-darkness" = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/ui-darkness/jquery-ui.css";
"vader"     = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/vader/jquery-ui.css";

}



Function Convertto-DataTable
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [psobject[]]$InputObject,
        [string[]]$Head,
        [string]$Title="HTML TABLE",
        [object[]]$Property="*",
        [string[]]$PreContent,
        [string[]]$PostContent,
        [string]$JqueryUi="vader"    
    )


    $htmlDoc = "<!DOCTYPE html PUBLIC \`"-//W3C//DTD XHTML 1.0 Strict//EN\`"  \`"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\`">`n"
    $htmlDoc += "<html xmlns=\`"http://www.w3.org/1999/xhtml\`">`n"
    $htmlDoc += "`t<head>`n"

    #Title Document
    $htmlDoc += ("`t`t<title>{0}</title>`n" -f $Title)


    if($Head -ne $null) {
        foreach($s in $Head) {
            $htmlDoc += $s
        }
    }



    $htmlDoc += @"
    `t<link rel="stylesheet" type="text/css" charset="utf8" href="$($jqueryUiTheme[$JqueryUi])"> 
    `t<link rel="stylesheet" type="text/css" charset="utf8" href="https://cdn.datatables.net/1.10.12/css/dataTables.jqueryui.css">
    `t<script type="text/javascript" charset="utf8" src="https://code.jquery.com/jquery-1.12.3.js"></script>
    `t<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script>
    `t<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.12/js/dataTables.jqueryui.min.js"></script>`n
"@
    $htmlDoc += "`t</head>`n"




    $htmlDoc += "`t<body>`n"
    if($PreContent -ne $null) {
        foreach($t in $PreContent) {
            $htmlDoc += $t
        }
    }


    $htmlDoc += "`t`t<table id=`"myTable`" class=`"display`" cellspacing=`"0`" width=`"100%`">`n"

    
    # Get The properties for table head
    $properties = $InputObject | Get-Member -MemberType Properties
    $htmlDoc += "`t`t`t<thead>`n"
    $htmlDoc += "`t`t`t`t<tr>`n"
    foreach($prop in $properties) {
        if($Property -eq "*") {
            $htmlDoc += ("`t`t`t`t`t<th>{0}</th>`n" -f $prop.Name)
        }
        else {
            foreach($o in $Property) {
                if($o -eq $prop.Name) {
                     $htmlDoc += ("`t`t`t`t`t<th>{0}</th>`n" -f $prop.Name)
                }
            }
        }
    }
    $htmlDoc += "`t`t`t`t</tr>`n"
    $htmlDoc += "`t`t`t</thead>`n"



    # Create the table body
    $htmlDoc += "`t`t`t<tbody>`n"   
    foreach($input in $InputObject) {
        $htmlDoc += "`t`t`t`t<tr>"
        foreach($prop in $properties) {
            if($Property -eq "*") {
                $value = $input.($prop.Name)
                $htmlDoc += ("<td>{0}</td>" -f $value)
            }
            else {
                foreach($o in $Property) {
                    if($o -eq $prop.Name) {
                        $value = $input.($prop.Name)
                        $htmlDoc += ("<td>{0}</td>" -f $value)
                    }
                }
            }
        }
        $htmlDoc += "</tr>`n"
    }   
    $htmlDoc += "`t`t`t</tbody>`n"
    $htmlDoc += "`t`t</table>`n"




    $htmlDoc += @"
     <script>
        `$(document).ready(function()
        {
            `$('#myTable').dataTable( { 
                "sPaginationType": "full_numbers", 
                "jQueryUI": true,
                "lengthMenu" : [ [25, 50, 100, -1], [25, 50, 100, "All"] ]
            });
        });
    </script>`n
"@

    if($PostContent -ne $null) {
        foreach($t in $PostContent) {
            $htmlDoc += $t
        }
    }

    $htmlDoc += "`t</body>`n"
    $htmlDoc += "</html>"

    return $htmlDoc
}



#Example Usage
# using the ',' befor object array (unarray operator) when piping the command due to the powershell (ne needed for native dll cmdlet writted in c#) 

$processes = Get-Process

# default value
$result0 = ,$processes | Convertto-DataTable 
# with additional info and jqueryUi Theme
$result1 = ,$processes | Convertto-DataTable -Title "Table Jquery" -Property * -PreContent "<H1>Pre Content</H1>" -PostContent "<H1>Post Content</H1>" -JqueryUi "smoothness"
# without piping 
$result2 = Convertto-DataTable -InputObject $processes
# Filtering property
$result3 = ,$processes | Convertto-DataTable -Property Name,CPU,Path



#
$result0 | Out-File C:\test.html
Invoke-Expression C:\test.html
