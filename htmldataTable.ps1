
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






$process = Get-Process
$htmlData = $process | ConvertTo-Html -Head $htmlHead -PreContent $preContent  | Out-String

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
