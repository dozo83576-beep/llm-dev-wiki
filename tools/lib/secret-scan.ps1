function Get-SecretScanPatterns {
    return @(
        @{ Name = "openai-key"; Pattern = '(?i)\bsk-(proj-)?[a-z0-9_-]{20,}\b' },
        @{ Name = "github-token"; Pattern = '\bgh[opusr]_[A-Za-z0-9_]{20,}\b' },
        @{ Name = "jwt"; Pattern = '\b[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b' },
        @{ Name = "slack-token"; Pattern = '(?i)\bxox[baprs]-[A-Za-z0-9-]{20,}\b' },
        @{ Name = "telegram-token"; Pattern = '\b\d{6,12}:[A-Za-z0-9_-]{25,}\b' },
        @{ Name = "presigned-url"; Pattern = '(?i)\b(X-Amz-Signature|AWSAccessKeyId|signature|sig)=\S+' },
        @{ Name = "token"; Pattern = '(?i)\b(access[_-]?token|refresh[_-]?token|api[_-]?key|secret[_-]?key|bearer\s+[a-z0-9._~+\/=-]{12,})\b' },
        @{ Name = "high-entropy-secret"; Pattern = '(?i)\b(token|key|secret|credential)\b\s*[:=]?\s*[A-Za-z0-9._~+\/=-]{24,}' },
        @{ Name = "private-key"; Pattern = '-----BEGIN (RSA |OPENSSH |EC |DSA |)?PRIVATE KEY-----' },
        @{ Name = "cookie"; Pattern = '(?i)\b(cookie|sessionid|connect\.sid|csrf[_-]?token)\s*[:=]' },
        @{ Name = "credential"; Pattern = '(?i)\b(password|passwd|pwd|credential|credentials)\s*[:=]' },
        @{ Name = "customer-payload"; Pattern = '(?i)\b(customer payload|client payload|production dump|database dump|private code)\b' },
        @{ Name = "pii-email"; Pattern = '(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b' },
        @{ Name = "pii-phone"; Pattern = '(?i)\b(phone|tel|mobile)\s*[:=]\s*\+?\d[\d\s().-]{8,}\d|(?<![\d-])\+\d[\d\s().-]{8,}\d(?![\d-])' }
    )
}

function Find-SecretLikeText {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return @()
    }

    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($item in Get-SecretScanPatterns) {
        $matches = [regex]::Matches($Text, $item.Pattern)
        foreach ($match in $matches) {
            $prefix = $Text.Substring(0, $match.Index)
            $line = ($prefix -split "`n").Count
            $lineStart = $prefix.LastIndexOf("`n")
            $column = if ($lineStart -lt 0) { $match.Index + 1 } else { $match.Index - $lineStart }
            $findings.Add([pscustomobject]@{
                Rule = $item.Name
                Line = $line
                Column = $column
                Sample = $match.Value.Substring(0, [Math]::Min($match.Value.Length, 16))
            }) | Out-Null
        }
    }
    return @($findings)
}

function Test-UnsafePreferenceText {
    param([string]$Text)

    $finding = @(Find-SecretLikeText -Text $Text) | Select-Object -First 1
    if ($finding) {
        return $finding.Rule
    }
    return $null
}
