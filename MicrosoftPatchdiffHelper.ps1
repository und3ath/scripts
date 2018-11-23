Param(
    [parameter(Mandatory=$true)][string]$MsrcApiKey,
    [parameter(Mandatory=$false)][switch]$ListProductID,
    [parameter(Mandatory=$false)][switch]$PrintMsuUrl,
    [parameter(Mandatory=$true)][string]$CVE,
    [parameter(Mandatory=$false)][string]$ProductID,
    [parameter(Mandatory=$false)][switch]$DownloadOnly
    )

Import-Module -Name MsrcSecurityUpdates
Set-MSRCApiKey -ApiKey $MsrcApiKey


$catalogUrl = "https://catalog.update.microsoft.com/v7/site/Search.aspx?q=KB"

function Get-KBMsuDownloadUrl {
    Param([string]$Kb, [string]$ProductName)


    $null = @(
    $webreq = Invoke-WebRequest ("{0}{1}" -f $catalogUrl, $Kb)
    $bx = $webreq.Links | where { $_.innerText -match $ProductName }
    $kbid = $bx.id.Substring(0, $bx.id.LastIndexOf("_link"))
    $POSTContent = @{ updateIDs=("[{{`"size`":0,`"languages`":`"`", `"uidInfo`":`"{0}`",`"updateID`":`"{1}`"}}]" -f $kbid, $kbid) }
    $CatalogRequest = Invoke-WebRequest -uri "www.catalog.update.microsoft.com/DownloadDialog.aspx" -Method Post -Body $POSTContent 
    $CatalogRequest.RawContent -match ".*downloadInformation\[0\]\.files\[0\]\.url\ = '(?<content>.*)';"
    )
    
    return $Matches['content']
}

function Get-ProductTree {
    Param($cvrfdoc)
    $productTree = $cvrfdoc.ProductTree.FullProductName
    return  ($productTree | format-table | Out-String)
}

# Get The cvrf Doc
Write-Host ("Processing {0}" -f $CVE) -ForegroundColor Green
$secupdate = Get-MsrcSecurityUpdate -Vulnerability $CVE
$cvrfdoc = Get-MsrcCvrfDocument -ID $secupdate.ID 


# Print Product Tree
if($ListProductID) {
    write-host (PrintProductTree -cvrfdoc $cvrfdoc)
    exit
}

# if no product id entered
if($ProductID -eq $null) {
    Write-Host "Product ID Must be entered, use -ListProductID"
    exit
}

$productTree = $cvrfdoc.ProductTree.FullProductName

Write-Host ("Product: {0} - {1}" -f ($productTree | where { $_.ProductID -eq $ProductID }).ProductID, ($productTree | where { $_.ProductID -eq $ProductID }).Value) -ForegroundColor Green

$selectedProductID = $productTree | where { $_.ProductID -eq $ProductID }

if($selectedProductID.Value -match "Service Pack") {
    $selectedProductID.Value = $selectedProductID.Value.SubString(0, $selectedProductID.Value.LastIndexOf("Service Pack"))
}




$cvex = $cvrfdoc.Vulnerability | where { $_.CVE -eq $CVE }
$rem = $cvex.Remediations | where { $_.ProductID -eq $selectedProductID.ProductID }
$supercedenceKB  = ($rem | where { $_.SubType -eq "Monthly Rollup" }).Supercedence 
$fixKB = ($rem | where { $_.SubType -eq "Security Only" }).Description.Value



$supersedMsuUrl = Get-KBMsuDownloadUrl -Kb $supercedenceKB -ProductName $selectedProductID.Value
$fixMsuUrl = Get-KBMsuDownloadUrl -Kb  $fixKB -ProductName $selectedProductID.Value


if($PrintMsuUrl) {
    Write-Host ("Fix msu url: {0}" -f $fixMsuUrl) -ForegroundColor Green
    Write-Host ("Superseded msu url: {0}" -f $supersedMsuUrl) -ForegroundColor Green
    exit
}




$fixFolder = ("KB{0}-fix" -f $fixKB)
$supersedFolder = ("KB{0}-supersed" -f $supercedenceKB)

$fixMsuFilename = Split-Path $fixMsuUrl -Leaf
$supersedMsuFilename = Split-Path $supersedMsuUrl -Leaf

mkdir $fixFolder
mkdir $supersedFolder



Invoke-WebRequest $fixMsuUrl -OutFile ("{0}\{1}" -f $fixFolder, $fixMsuFilename)

Invoke-WebRequest $supersedMsuUrl -OutFile ("{0}\{1}" -f $supersedFolder, $supersedMsuFilename) 


if($DownloadOnly) {
    exit
}




expand -F:*  ("{0}\{1}" -f $fixFolder, $fixMsuFilename) ("{0}\{1}" -f $PSScriptRoot, $fixFolder)
Start-Sleep -Seconds 5
$cc = Get-ChildItem $fixFolder | where { $_.Extension -eq ".cab" } | select Name 
foreach($z in $cc) {
    expand -F:* ("{0}\{1}" -f $fixFolder, $z.Name) ("{0}\{1}" -f $PSScriptRoot, $fixFolder)
}



expand -F:*  ("{0}\{1}" -f $supersedFolder, $supersedMsuFilename) ("{0}\{1}" -f $PSScriptRoot, $supersedFolder)
Start-Sleep -Seconds 5
$ccx = Get-ChildItem $supersedFolder | where { $_.Extension -eq ".cab" } | select Name 
foreach($y in $ccx) {
    expand -F:* ("{0}\{1}" -f $supersedFolder, $y.Name) ("{0}\{1}" -f $PSScriptRoot, $supersedFolder)
}




