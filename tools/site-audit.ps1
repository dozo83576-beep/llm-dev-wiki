param(
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [string[]]$Routes = @(),
    [string]$OutputDir = ".",
    [switch]$SkipLighthouse,
    [switch]$SkipSecurityHeaders,
    [switch]$FailOnHigh,
    [switch]$FailOnMedium,
    [int]$LighthouseMinPerformance = 90,
    [int]$LighthouseMinAccessibility = 95,
    [int]$LighthouseMinSeo = 95,
    [int]$LighthouseMinBestPractices = 90
)

$ErrorActionPreference = "Stop"

function New-Finding {
    param(
        [string]$Severity,
        [string]$Check,
        [string]$Message,
        [string]$Url
    )
    [pscustomobject]@{
        severity = $Severity
        check = $Check
        message = $Message
        url = $Url
    }
}

function Join-RouteUrl {
    param([string]$BaseUrl, [string]$Route)
    if ([string]::IsNullOrWhiteSpace($Route)) {
        return $BaseUrl
    }
    if ($Route -match '^https?://') {
        return $Route
    }
    $base = [Uri]$BaseUrl
    return ([Uri]::new($base, $Route)).AbsoluteUri
}

function Get-HeaderValue {
    param($Headers, [string]$Name)
    $value = $Headers[$Name]
    if ($null -eq $value) {
        return ""
    }
    if ($value -is [array]) {
        return ($value -join "; ")
    }
    return [string]$value
}

function Test-SecurityHeaders {
    param([string]$TargetUrl)

    $findings = [System.Collections.Generic.List[object]]::new()
    try {
        $response = Invoke-WebRequest -Uri $TargetUrl -Method Get -MaximumRedirection 5 -TimeoutSec 30 -UseBasicParsing
    }
    catch {
        $findings.Add((New-Finding -Severity "high" -Check "reachable" -Message "Request failed: $_" -Url $TargetUrl)) | Out-Null
        return $findings
    }

    $headers = $response.Headers
    $csp = Get-HeaderValue -Headers $headers -Name "Content-Security-Policy"
    $xFrame = Get-HeaderValue -Headers $headers -Name "X-Frame-Options"
    $referrer = Get-HeaderValue -Headers $headers -Name "Referrer-Policy"
    $permissions = Get-HeaderValue -Headers $headers -Name "Permissions-Policy"
    $hsts = Get-HeaderValue -Headers $headers -Name "Strict-Transport-Security"
    $corsOrigin = Get-HeaderValue -Headers $headers -Name "Access-Control-Allow-Origin"
    $corsCredentials = Get-HeaderValue -Headers $headers -Name "Access-Control-Allow-Credentials"

    if ([string]::IsNullOrWhiteSpace($csp)) {
        $findings.Add((New-Finding -Severity "medium" -Check "csp" -Message "Missing Content-Security-Policy header." -Url $TargetUrl)) | Out-Null
    }
    elseif ($csp -match "(?i)'unsafe-inline'") {
        $findings.Add((New-Finding -Severity "medium" -Check "csp" -Message "Content-Security-Policy contains unsafe-inline; verify it is justified." -Url $TargetUrl)) | Out-Null
    }

    if ([string]::IsNullOrWhiteSpace($xFrame) -and ($csp -notmatch "(?i)frame-ancestors")) {
        $findings.Add((New-Finding -Severity "medium" -Check "frame-protection" -Message "Missing X-Frame-Options and CSP frame-ancestors." -Url $TargetUrl)) | Out-Null
    }
    if ([string]::IsNullOrWhiteSpace($referrer)) {
        $findings.Add((New-Finding -Severity "low" -Check "referrer-policy" -Message "Missing Referrer-Policy header." -Url $TargetUrl)) | Out-Null
    }
    if ([string]::IsNullOrWhiteSpace($permissions)) {
        $findings.Add((New-Finding -Severity "low" -Check "permissions-policy" -Message "Missing Permissions-Policy header." -Url $TargetUrl)) | Out-Null
    }
    $targetUri = [Uri]$TargetUrl
    if ($targetUri.Scheme -eq "https") {
        if ([string]::IsNullOrWhiteSpace($hsts)) {
            $findings.Add((New-Finding -Severity "medium" -Check "hsts" -Message "Missing Strict-Transport-Security header on HTTPS route." -Url $TargetUrl)) | Out-Null
        }
    }
    if ($corsOrigin.Trim() -eq "*" -and $corsCredentials -match "(?i)^true$") {
        $findings.Add((New-Finding -Severity "high" -Check "cors" -Message "Wildcard CORS origin with credentials is unsafe." -Url $TargetUrl)) | Out-Null
    }

    return $findings
}

function Invoke-LighthouseAudit {
    param([string]$TargetUrl, [string]$OutDir, [string]$Slug)

    $jsonPath = Join-Path $OutDir "lighthouse-$Slug.json"
    $htmlPath = Join-Path $OutDir "lighthouse-$Slug.html"
    $outputBase = Join-Path $OutDir "lighthouse-$Slug"
    & npx --yes lighthouse $TargetUrl --output=json --output=html "--output-path=$outputBase" --chrome-flags="--headless=new" --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Lighthouse failed for $TargetUrl"
    }
    $jsonCandidates = @($jsonPath, "$outputBase.report.json")
    $htmlCandidates = @($htmlPath, "$outputBase.report.html")
    foreach ($candidate in $jsonCandidates) {
        if ((Test-Path -LiteralPath $candidate) -and $candidate -ne $jsonPath) {
            Move-Item -LiteralPath $candidate -Destination $jsonPath -Force
            break
        }
    }
    foreach ($candidate in $htmlCandidates) {
        if ((Test-Path -LiteralPath $candidate) -and $candidate -ne $htmlPath) {
            Move-Item -LiteralPath $candidate -Destination $htmlPath -Force
            break
        }
    }
    $data = Get-Content -LiteralPath $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
    return [pscustomobject]@{
        url = $TargetUrl
        jsonPath = $jsonPath
        htmlPath = $htmlPath
        performance = [int]([double]$data.categories.performance.score * 100)
        accessibility = [int]([double]$data.categories.accessibility.score * 100)
        seo = [int]([double]$data.categories.seo.score * 100)
        bestPractices = [int]([double]$data.categories.'best-practices'.score * 100)
    }
}

function Get-RouteSlug {
    param([string]$TargetUrl)
    $uri = [Uri]$TargetUrl
    $slug = ($uri.Host + "-" + $uri.AbsolutePath).Trim("-/").Replace("/", "-")
    $slug = $slug -replace '[^A-Za-z0-9_.-]', '-'
    if ([string]::IsNullOrWhiteSpace($slug)) {
        return "root"
    }
    return $slug
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$targetUrls = [System.Collections.Generic.List[string]]::new()
$targetUrls.Add($Url) | Out-Null
foreach ($route in $Routes) {
    $targetUrls.Add((Join-RouteUrl -BaseUrl $Url -Route $route)) | Out-Null
}

$findings = [System.Collections.Generic.List[object]]::new()
$lighthouseResults = [System.Collections.Generic.List[object]]::new()

foreach ($target in $targetUrls) {
    if (-not $SkipSecurityHeaders) {
        foreach ($finding in Test-SecurityHeaders -TargetUrl $target) {
            $findings.Add($finding) | Out-Null
        }
    }

    if (-not $SkipLighthouse) {
        $slug = Get-RouteSlug -TargetUrl $target
        $lh = Invoke-LighthouseAudit -TargetUrl $target -OutDir $OutputDir -Slug $slug
        $lighthouseResults.Add($lh) | Out-Null
        if ($lh.performance -lt $LighthouseMinPerformance) {
            $findings.Add((New-Finding -Severity "high" -Check "lighthouse-performance" -Message "Performance score $($lh.performance) is below $LighthouseMinPerformance." -Url $target)) | Out-Null
        }
        if ($lh.accessibility -lt $LighthouseMinAccessibility) {
            $findings.Add((New-Finding -Severity "medium" -Check "lighthouse-accessibility" -Message "Accessibility score $($lh.accessibility) is below $LighthouseMinAccessibility." -Url $target)) | Out-Null
        }
        if ($lh.seo -lt $LighthouseMinSeo) {
            $findings.Add((New-Finding -Severity "medium" -Check "lighthouse-seo" -Message "SEO score $($lh.seo) is below $LighthouseMinSeo." -Url $target)) | Out-Null
        }
        if ($lh.bestPractices -lt $LighthouseMinBestPractices) {
            $findings.Add((New-Finding -Severity "medium" -Check "lighthouse-best-practices" -Message "Best practices score $($lh.bestPractices) is below $LighthouseMinBestPractices." -Url $target)) | Out-Null
        }
    }
}

$highCount = @($findings | Where-Object { $_.severity -eq "high" }).Count
$mediumCount = @($findings | Where-Object { $_.severity -eq "medium" }).Count
$lowCount = @($findings | Where-Object { $_.severity -eq "low" }).Count
$status = if ($highCount -gt 0) { "high-findings" } elseif ($mediumCount -gt 0) { "medium-findings" } elseif ($lowCount -gt 0) { "low-findings" } else { "ok" }

$report = [pscustomobject]@{
    status = $status
    url = $Url
    routes = @($targetUrls)
    findings = @($findings)
    findingCounts = [pscustomobject]@{
        high = $highCount
        medium = $mediumCount
        low = $lowCount
    }
    lighthouse = @($lighthouseResults)
    thresholds = [pscustomobject]@{
        performance = $LighthouseMinPerformance
        accessibility = $LighthouseMinAccessibility
        seo = $LighthouseMinSeo
        bestPractices = $LighthouseMinBestPractices
    }
}

$jsonReportPath = Join-Path $OutputDir "site-audit-report.json"
$mdReportPath = Join-Path $OutputDir "site-audit-report.md"
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonReportPath -Encoding UTF8

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Site audit report") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("- Status: $status") | Out-Null
$lines.Add("- URL: $Url") | Out-Null
$lines.Add("- Routes: $($targetUrls.Count)") | Out-Null
$lines.Add("- Findings: high=$highCount, medium=$mediumCount, low=$lowCount") | Out-Null
$lines.Add("") | Out-Null
if ($findings.Count -gt 0) {
    $lines.Add("## Findings") | Out-Null
    $lines.Add("") | Out-Null
    foreach ($finding in $findings) {
        $lines.Add("- [$($finding.severity)] $($finding.check): $($finding.message) ($($finding.url))") | Out-Null
    }
}
else {
    $lines.Add("No findings.") | Out-Null
}
if ($lighthouseResults.Count -gt 0) {
    $lines.Add("") | Out-Null
    $lines.Add("## Lighthouse") | Out-Null
    $lines.Add("") | Out-Null
    foreach ($lh in $lighthouseResults) {
        $lines.Add("- $($lh.url): performance=$($lh.performance), accessibility=$($lh.accessibility), SEO=$($lh.seo), best-practices=$($lh.bestPractices)") | Out-Null
    }
}
$lines | Set-Content -LiteralPath $mdReportPath -Encoding UTF8

Write-Host "Status: $status"
Write-Host "Report: $mdReportPath"
Write-Host "JSON: $jsonReportPath"
Write-Host "Findings: high=$highCount medium=$mediumCount low=$lowCount"

if ($FailOnHigh -and $highCount -gt 0) {
    exit 1
}
if ($FailOnMedium -and ($highCount -gt 0 -or $mediumCount -gt 0)) {
    exit 1
}
exit 0
