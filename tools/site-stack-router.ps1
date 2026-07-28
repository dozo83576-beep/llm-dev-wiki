param(
    [Parameter(Mandatory = $true)]
    [string]$Request,
    [switch]$OutputJson,
    [switch]$FailOnLowConfidence,
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

function Test-Pattern {
    param([string]$Text, [string[]]$Patterns)
    foreach ($pattern in $Patterns) {
        if ($Text -match $pattern) { return $true }
    }
    return $false
}

function Get-PatternCount {
    param([string]$Text, [string[]]$Patterns)
    $count = 0
    foreach ($pattern in $Patterns) {
        if ($Text -match $pattern) { $count++ }
    }
    return $count
}

function Get-LessonLinks {
    param([string[]]$Ids, [string]$NormalizedRequest, [string]$RootPath, [int]$Limit = 5)
    $links = @()
    $lessonsDir = Join-Path $RootPath "lessons-learned"
    if (-not (Test-Path -LiteralPath $lessonsDir)) { return $links }
    foreach ($file in Get-ChildItem -LiteralPath $lessonsDir -Filter "*.md" -File) {
        $tagsLine = Get-Content -LiteralPath $file.FullName -TotalCount 15 -ErrorAction SilentlyContinue |
            Where-Object { $_ -match '^tags:' } | Select-Object -First 1
        if (-not $tagsLine) { continue }
        $tags = [regex]::Matches($tagsLine, '"([^"]+)"') |
            ForEach-Object { $_.Groups[1].Value.ToLowerInvariant() }
        foreach ($tag in $tags) {
            if ($Ids -contains $tag -or ($tag.Length -ge 4 -and $NormalizedRequest.Contains($tag))) {
                $links += "lessons-learned/$($file.Name)"
                break
            }
        }
        if ($links.Count -ge $Limit) { break }
    }
    return $links
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$contractPath = Join-Path $rootPath "resources/site-pipeline-contract.json"
$contract = Get-Content -Raw -Encoding UTF8 -LiteralPath $contractPath | ConvertFrom-Json
$normalized = $Request.ToLowerInvariant()

$productRules = @(
    [pscustomobject]@{ id='marketplace'; route='Marketplace'; patterns=@('маркетплейс','marketplace','multi.?vendor','мульти.?вендор','нескольк.*продавц','выплат.*продавц'); stack='Next.js + backend service + PostgreSQL + Redis'; gates=@('Order split, комиссии и выплаты покрыты интеграционными тестами.','Tenant-изоляция продавцов покрыта negative permission tests.'); questions=@('Как устроены выплаты продавцам и комиссия?','Какая модерация продавцов и товаров нужна?') },
    [pscustomobject]@{ id='api-only-backend'; route='API-only backend'; patterns=@('api[- ]?only','только api','без (ui|frontend|фронтенд)','rest api','graphql api','backend service','бэкенд без интерфейса'); stack='NestJS или FastAPI + PostgreSQL + OpenAPI'; gates=@('OpenAPI/contract tests и negative authorization tests.','Наблюдаемость, rate limits и rollback проверены.'); questions=@('Кто потребители API и какой протокол нужен?','Какие auth, SLA и data residency обязательны?') },
    [pscustomobject]@{ id='ai-rag-app'; route='AI/RAG application'; patterns=@('\brag\b','retrieval.augmented','векторн.*поиск','эмбеддинг','embedding','llm[- ]?(app|прилож)','ai[- ]?(app|прилож)','чат.*документ'); stack='Next.js + Python/NestJS AI service + PostgreSQL/pgvector'; gates=@('Eval-набор проверяет groundedness и качество retrieval.','Prompt injection, PII и cost/latency budgets проверены.'); questions=@('Какие источники знаний и требования к актуальности?','Приложение публичное или внутреннее?') },
    [pscustomobject]@{ id='real-time-app'; route='Real-time application'; patterns=@('real[- ]?time','реальн.*времен','websocket','web.?socket','live collaboration','совместн.*редакт','presence','онлайн[- ]?чат'); stack='Next.js + realtime backend + PostgreSQL/Redis'; gates=@('Reconnect, ordering, idempotency и degraded-mode покрыты тестами.','Проверена авторизация каналов и tenant isolation.'); questions=@('Какие latency/SLA и гарантии доставки нужны?','Приложение публичное или внутреннее?') },
    [pscustomobject]@{ id='admin-dashboard'; route='Private admin/dashboard'; patterns=@('админ','admin','внутренн.*кабинет','internal tool','backoffice','back.?office','операторск','дашборд для'); stack='Next.js + PostgreSQL + RBAC'; gates=@('RBAC и negative authorization tests.','robots/noindex и отсутствие публичной индексации проверены.'); questions=@('Какие роли и матрица доступа нужны?','Нужны ли SSO и audit log?') },
    [pscustomobject]@{ id='ecommerce'; route='E-commerce'; patterns=@('интернет[- ]?магазин','e[- ]?commerce','онлайн[- ]?магазин','checkout','корзин','cart','заказ.*товар','каталог товар'); stack='Next.js storefront + commerce backend + PostgreSQL'; gates=@('Catalog/cart/checkout E2E и webhook idempotency.','Цена, остатки, доставка и возвраты согласованы.'); questions=@('Какой commerce backend и эквайринг выбраны?','Нужны ли доставка, промокоды и личный кабинет?') },
    [pscustomobject]@{ id='saas'; route='SaaS'; patterns=@('\bsaas\b','подписк','multi.?tenant','мульти.?тенант','личн.*кабинет','billing','b2b.*платформ'); stack='Next.js fullstack + PostgreSQL + Auth + billing'; gates=@('Auth/authorization и tenant isolation tests.','Billing/webhook idempotency tests при наличии платежей.'); questions=@('Какая billing model и какие роли/teams нужны?','Есть ли compliance и data residency constraints?') },
    [pscustomobject]@{ id='content-site'; route='Content/CMS site'; patterns=@('корпоративн.*сайт','сайт компан','каталог услуг','блог','документац','docs','help center','новост','cms','редактор.*публикац','контентн.*сайт'); stack='Astro для static или CMS-backed frontend'; gates=@('Build, broken links, accessibility, metadata и site audit.','Редакторский preview/workflow проверен, если есть CMS.'); questions=@('Кто редактирует контент и нужна ли CMS?','Нужны ли server forms, поиск или личный кабинет?') },
    [pscustomobject]@{ id='landing'; route='Landing'; patterns=@('лендинг','landing','промо[- ]?сайт','одностранич','lead generation','форма заявк','сайт.*услуг','портфолио'); stack='Astro + server form при необходимости'; gates=@('Site audit, accessibility и lead-form smoke.','Проверены consent, analytics и mobile CTA.'); questions=@('Нужна ли серверная форма/CRM-интеграция?','Какие KPI и analytics events обязательны?') }
)

$matches = foreach ($rule in $productRules) {
    $score = Get-PatternCount -Text $normalized -Patterns $rule.patterns
    if ($score -gt 0) { [pscustomobject]@{ rule=$rule; score=$score } }
}
$best = @($matches | Sort-Object score -Descending | Select-Object -First 1)
$bestRule = if ($best.Count) { $best[0].rule } else { $null }
$productSignals = @($matches | Sort-Object score -Descending | ForEach-Object { $_.rule.id })

$platformSignals = @()
$supportingGuides = @()
$platformLinks = @()
$stackSuffix = @()
$shopifyMention = Test-Pattern $normalized @('shopify','hydrogen','storefront api')
$shopifyNegated = Test-Pattern $normalized @('shopify\s+(не|not)\s+(использ|нуж|выбран)','(не|без|no)\s+shopify','shopify\s+не')
if ($shopifyMention -and -not $shopifyNegated) {
    $platformSignals += 'shopify'
    $supportingGuides += 'shopify-hydrogen'
    $supportingGuides += 'headless-commerce'
    $platformLinks += 'docs/13-playbooks/shopify-hydrogen.md','docs/13-playbooks/headless-commerce.md'
    $stackSuffix += 'Shopify Hydrogen/Storefront API'
}
if (Test-Pattern $normalized @('woocommerce','woo.?commerce','вукоммерс')) {
    $platformSignals += 'woocommerce'
    $supportingGuides += 'wordpress-woocommerce'
    $platformLinks += 'docs/03-backend/WordPress-WooCommerce-backend.md'
    $stackSuffix += 'WordPress + WooCommerce'
}
elseif (Test-Pattern $normalized @('wordpress','вордпресс','\bwp\b')) {
    $platformSignals += 'wordpress'
    $supportingGuides += 'wordpress'
    $platformLinks += 'docs/02-frontend/WordPress.md'
    $stackSuffix += 'WordPress'
}
if (Test-Pattern $normalized @('webflow')) {
    $platformSignals += 'webflow'; $supportingGuides += 'webflow'
    $platformLinks += 'docs/02-frontend/Webflow.md'; $stackSuffix += 'Webflow'
}
if (Test-Pattern $normalized @('cloudflare workers','\bhono\b','edge runtime')) {
    $platformSignals += 'edge-runtime'; $supportingGuides += 'edge-runtime'
    $platformLinks += 'docs/08-devops-deploy/Cloudflare-Workers-fullstack.md'; $stackSuffix += 'edge runtime'
}
$frameworkSignals = @()
if (Test-Pattern $normalized @('react router','remix')) { $frameworkSignals += 'react-router'; $stackSuffix += 'React Router' }
if (Test-Pattern $normalized @('angular')) { $frameworkSignals += 'angular'; $stackSuffix += 'Angular' }
if (Test-Pattern $normalized @('nuxt','\bvue\b')) { $frameworkSignals += 'vue'; $stackSuffix += 'Nuxt/Vue' }
if (Test-Pattern $normalized @('svelte')) { $frameworkSignals += 'svelte'; $stackSuffix += 'SvelteKit' }
$platformSignals += $frameworkSignals

$hasPayments = Test-Pattern $normalized @('плат[её]ж','payment','stripe','эквайринг')
$hasPii = Test-Pattern $normalized @('персональн','\bpii\b','медицинск','паспорт','152[- ]?фз','gdpr')
$hasRiskDetails = Test-Pattern $normalized @('pci','oidc','rbac','изоляц','data residency','152[- ]?фз','gdpr','stripe checkout','shopify payments')
$isGeneric = Test-Pattern $normalized @('^\s*(сделай|создай|нужен|нужна|хочу)?\s*(сайт|проект|веб[- ]?сайт)\s*\.?\s*$')

if ($isGeneric -or $null -eq $bestRule) {
    $confidence = 'low'; $playbook = ''; $profile = ''; $route = ''; $stack = ''
    $questions = @('Какой тип продукта нужен: landing, content, SaaS, admin, e-commerce, marketplace, AI/RAG, API-only или real-time?','Нужны ли auth, роли, платежи, CMS, формы или realtime?','Какие hosting и platform constraints уже зафиксированы?')
    $assumptions = @(); $gates = @('Пройти discovery и повторить preflight.'); $rejected = @('Стек и playbook не выбраны до уточнения типа продукта.')
    $wikiLinks = @('docs/01-development-process/site-architecture-decision-router.md','checklists/project-discovery.md','prompts/create-new-project.md')
}
else {
    $playbook = $bestRule.id
    $route = $bestRule.route
    $entry = @($contract.primaryPlaybooks | Where-Object id -eq $playbook)[0]
    $profile = $entry.defaultDeliveryProfile
    $serverSignals = Test-Pattern $normalized @('форма заявк','crm','api','auth','логин','личн.*кабинет','server','backend','бэкенд','динамич')
    $privateSignals = Test-Pattern $normalized @('внутренн','private','только сотруд','закрыт.*систем')
    if (($playbook -in @('landing','content-site')) -and $serverSignals) { $profile = 'public-fullstack' }
    if (($playbook -in @('ai-rag-app','real-time-app')) -and $privateSignals) { $profile = 'private-app' }
    $confidence = if ($best[0].score -ge 2 -or $platformSignals.Count -gt 0) { 'high' } else { 'medium' }
    $stack = $bestRule.stack
    if ($stackSuffix.Count) { $stack = (@($stackSuffix | Select-Object -Unique) -join ' + ') }
    $questions = if ($confidence -eq 'medium') { @($bestRule.questions | Select-Object -First 3) } else { @() }
    $assumptions = @("Primary playbook: $playbook; delivery profile: $profile.")
    $gates = @($bestRule.gates)
    $rejected = @('Другие primary playbook не смешиваются; платформенные ограничения оформляются supporting guides.')
    $wikiLinks = @($entry.path) + @($platformLinks) + @('docs/01-development-process/site-pipeline-map.md')
    if ($hasPayments -and $hasPii -and -not $hasRiskDetails) {
        $confidence = 'blocker'; $stack = ''
        $questions = @('Какие payment/PII/compliance требования и провайдеры уже выбраны?','Какие роли, изоляция, audit log и data residency обязательны?')
        $gates = @('Security/compliance boundary review до реализации.','Auth/payment/webhook negative tests до релиза.')
        $wikiLinks += 'checklists/security-review.md','docs/05-auth-security/Compliance-baseline.md'
    }
}

$supportingGuides = @($supportingGuides | Select-Object -Unique)
$allSignals = @($productSignals + $platformSignals | Select-Object -Unique)
$lessonLinks = @(Get-LessonLinks -Ids $allSignals -NormalizedRequest $normalized -RootPath $rootPath)
$result = [pscustomobject]@{
    confidence = $confidence
    classification = [pscustomobject]@{ signals=$allSignals; productSignals=$productSignals; platformSignals=$platformSignals; riskDetected=($hasPayments -or $hasPii); riskDetailsDetected=$hasRiskDetails; genericRequest=$isGeneric }
    recommendedRoute = $route
    recommendedPlaybook = $playbook
    recommendedDeliveryProfile = $profile
    supportingGuides = $supportingGuides
    recommendedStack = $stack
    assumptions = @($assumptions)
    openQuestions = @($questions)
    rejectedAlternatives = @($rejected)
    acceptanceGates = @($gates)
    wikiLinks = @($wikiLinks | Select-Object -Unique)
    lessonLinks = $lessonLinks
}

if ($OutputJson) { $result | ConvertTo-Json -Depth 10 }
else {
    Write-Host "Decision confidence: $confidence"
    Write-Host "Primary playbook: $playbook"
    Write-Host "Delivery profile: $profile"
    Write-Host "Supporting guides: $($supportingGuides -join ', ')"
    Write-Host "Recommended route: $route"
    Write-Host "Recommended stack: $stack"
    Write-Host "Signals: $($allSignals -join ', ')"
    Write-Host ""
    Write-Host "Open questions:"
    foreach ($item in $questions) { Write-Host "- $item" }
    Write-Host ""
    Write-Host "Acceptance gates:"
    foreach ($item in $gates) { Write-Host "- $item" }
    Write-Host ""
    Write-Host "Wiki links:"
    foreach ($item in $result.wikiLinks) { Write-Host "- $item" }
}
if ($FailOnLowConfidence -and $confidence -in @('low','blocker')) { exit 1 }
exit 0
