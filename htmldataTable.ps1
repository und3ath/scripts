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






$htmlHead = @"
        <link rel="stylesheet" type="text/css" charset="utf8" href="$($jqueryUiTheme["vader"])"> 
        <link rel="stylesheet" type="text/css" charset="utf8" href="https://cdn.datatables.net/1.10.12/css/dataTables.jqueryui.css"> 
       

        <script type="text/javascript" charset="utf8" src="https://code.jquery.com/jquery-1.12.3.js"></script>
        <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script>
        <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.12/js/dataTables.jqueryui.min.js"></script>
"@




function CreateDataTableAsHtmlString
{
    [CmdletBinding()]
    param(
        $Data,
        [string]$TableName,
        $Property)


       $preContent =
@"
<table id="$TableName" class="display" cellspacing="0" width="100%">
        <thead>
            <tr>
                KLX
            </tr>
        </thead> 
        <tbody>
"@


    $postContent = 
@"
<script>
    `$(document).ready(function()
    {
        `$('#$TableName').dataTable( { 
            "sPaginationType": "full_numbers", 
            "jQueryUI": true,
            "lengthMenu" : [ [25, 50, 100, -1], [25, 50, 100, "All"] ]
         });
    });
</script>
"@;


     $htmlData = $Data | ConvertTo-Html -PreContent $preContent -PostContent $postContent -Fragment -Property $Property

     # html magic's
     #supress colgroup 
     $htmlData = [regex]::Replace($htmlData, "<colgroup>.*</colgroup>", "")

     $property = [regex]::Match($htmlData, "<tr><th>.*</th></tr>")

     #supress column desc
     $htmlData = [regex]::Replace($htmlData, "<tr><th>.*</th></tr>", "")

     $property = $property -replace "<tr><th>", ""
     $property = $property -replace "</th></tr>", ""
     $propertyArray = $property -split "</th><th>"
     $propFormated = ""
     foreach($props in $propertyArray)
     {
        $p = ("`t`t`t<th>{0}</th>`n" -f $props)
        $propFormated += $p
     }
     $htmlData = $htmlData -replace "KLX", $propFormated
     $htmlData = $htmlData -replace "<table>" , ""
     $htmlData = $htmlData -replace "</table>", "`n</tbody>`n</table>`n"
     $htmlData = $htmlData -replace "</body>", ""
     $htmlData = $htmlData -replace "<body>", ""

     return $htmlData

}



function BuildHtmlForTable
{
    [CmdletBinding()]
    param(
        [string]$Title,
        [string]$DataTable)


$htmlDoc = @"
<!DOCTYPE html PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML>
    <HEAD>
        <meta charset="UTF-8">
        <TITLE>
           $Title
        </TITLE>
        $htmlHead
    </HEAD>
    <BODY>
        $DataTable
    </BODY>
</HTML>
"@

    return $htmlDoc
}







# EXAMPLE 

# -Properties arguement is passed as an array 
$property = @("Name",",","CPU", ",", "Path", ",", "Id")  # for all property simply pass "*" 

# The HtmlTable Name
$name = "myTable"

# The dataSource
$data = Get-Process








# Build the html table
$htmlTable = CreateDataTableAsHtmlString -Data $data -TableName $name -Property $property

# Create the html document
$htmlDoc = BuildHtmlForTable -Title "Process report" -DataTable $htmlTable



#outputing

$htmlDoc | Out-File C:\tmp.html
Invoke-Expression C:\tmp.html
