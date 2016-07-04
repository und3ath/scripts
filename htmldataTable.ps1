
# Enhancing ConvertTo-html cmdlet with HTMLDataTable 
# using jquery and css from CDN but can be hosted locally . 
# und3ath 04/07/2016


$htmlHead = @"
<meta charset="UTF-8">

<link rel="stylesheet" type="text/css" charset="utf8" href="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.0/css/jquery.dataTables.css">
<link rel="stylesheet" type="text/css" charset="utf8" href="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.0/css/jquery.dataTables_themeroller.css">

<script type="text/javascript" charset="utf8" src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.7.1.min.js"></script>
<script type="text/javascript" charset="utf8" src="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.0/jquery.dataTables.min.js"></script>

<script>
 `$(document).ready(function(){
        `$('#myTable').dataTable( { "sPaginationType": "full_numbers" } );
    });
</script>
"@


$preContent = @"
<table id="myTable" class="display" cellspacing="0" width="100%">
        <thead>
            <tr>
                KLX
            </tr>
        </thead> 
<tbody>
"@





# here pipe what u whant in the $htmlData in html format.
$process = Get-Process
$htmlData = $process | ConvertTo-Html -Head $htmlHead -PreContent $preContent  | Out-String




# html magic's
$htmlData = [regex]::Replace($htmlData, "<colgroup>.*", "")
$property = [regex]::Match($htmlData, "<tr><th>.*")
$htmlData = [regex]::Replace($htmlData, "<tr><th>.*", "")
$property = $property -replace "<tr><th>", ""
$property = $property -replace "</th></tr>", ""
$propertyArray = $property -split "</th><th>"
$propFormated = ""
foreach($props in $propertyArray)
{
    $p = ("<th>{0}</th>" -f $props)
    $propFormated += $p
}
$htmlData = $htmlData -replace "KLX", $propFormated
$htmlData = $htmlData -replace "<table>" , ""
$htmlData = $htmlData -replace "</table>", "</tbody></table>"
$htmlData = $htmlData -replace "</body>", ""
$htmlData = $htmlData -replace "<body>", ""


$htmlData | Out-File c:\tmp.html
Invoke-Expression C:\tmp.html
