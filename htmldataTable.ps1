# Enhancing ConvertTo-html cmdlet with HTMLDataTable 
# using jquery and css from CDN but can be hosted locally . 
# und3ath 06/07/2016

$htmlHead = @"
<link rel="stylesheet" type="text/css" charset="utf8" href="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.0/css/jquery.dataTables.css">
        <link rel="stylesheet" type="text/css" charset="utf8" href="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.0/css/jquery.dataTables_themeroller.css">

        <script type="text/javascript" charset="utf8" src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" charset="utf8" src="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.0/jquery.dataTables.min.js"></script>
"@




function CreateDataTableAsHtmlString($data,$tablename, $property)
{
       $preContent =
@"
<table id="$tablename" class="display" cellspacing="0" width="100%">
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
        `$('#$tablename').dataTable( { "sPaginationType": "full_numbers" } );
    });
</script>
"@;


     $htmlData = $data | ConvertTo-Html -PreContent $preContent -PostContent $postContent -Fragment -Property $property

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



function BuildHtmlHeadForTable($title, $dataTable)
{
$htmlDoc = @"
<!DOCTYPE html PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML>
    <HEAD>
        <meta charset="UTF-8">
        <TITLE>
           $title
        </TITLE>
        $htmlHead
    </HEAD>
    <BODY>
        $dataTable
    </BODY>
</HTML>
"@

    return $htmlDoc
}



# -Properties arguement is passed as an array 
$pros = @("Name",",","CPU")
# The HtmlTable Name
$name = "myTable"
# The dataSource
$datax0 = Get-Process

# Build the html table
$htmlTable = CreateDataTableAsHtmlString $datax0 $name $pros 

# Create the html document
$htmlDoc = BuildHtmlHeadForTable "Example" $htmlTable



#outputing

$htmlDoc | Out-File C:\tmp.html
Invoke-Expression C:\tmp.html
