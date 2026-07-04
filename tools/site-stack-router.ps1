param(
    [Parameter(Mandatory = $true)]
    [string]$Request,
    [switch]$OutputJson,
    [switch]$FailOnLowConfidence,
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

function Test-AnyPattern {
    param([string]$Text, [string[]]$Patterns)
    foreach ($pattern in $Patterns) {
        if ($Text -match $pattern) {
            return $true
        }
    }
    return $false
}

function Get-MatchCount {
    param([string]$Text, [string[]]$Patterns)
    $count = 0
    foreach ($pattern in $Patterns) {
        if ($Text -match $pattern) {
            $count++
        }
    }
    return $count
}

function New-Rule {
    param(
        [string]$Id,
        [string]$Route,
        [string]$Stack,
        [string[]]$Patterns,
        [string[]]$WikiLinks,
        [string[]]$Assumptions,
        [string[]]$OpenQuestions,
        [string[]]$RejectedAlternatives,
        [string[]]$AcceptanceGates,
        [int]$Priority = 0
    )
    [pscustomobject]@{
        id = $Id
        route = $Route
        stack = $Stack
        patterns = $Patterns
        wikiLinks = $WikiLinks
        assumptions = $Assumptions
        openQuestions = $OpenQuestions
        rejectedAlternatives = $RejectedAlternatives
        acceptanceGates = $AcceptanceGates
        priority = $Priority
    }
}

function Limit-Items {
    param([string[]]$Items, [int]$Count)
    return @($Items | Select-Object -First $Count)
}

function Get-LessonLinks {
    <#
        Возвращает уроки из lessons-learned/, чьи frontmatter-теги совпадают
        с id сработавшего правила или встречаются в тексте запроса.
        Замыкает петлю знаний: записанные уроки поднимаются автоматически,
        а не «по памяти» (прецедент: WP-7.0-урок 2026-06-21 переоткрывался заново).
    #>
    param([string]$RuleId, [string]$NormalizedRequest, [string]$RootPath, [int]$Limit = 5)

    $links = @()
    $lessonsDir = Join-Path $RootPath 'lessons-learned'
    if (-not (Test-Path -LiteralPath $lessonsDir)) {
        return $links
    }

    foreach ($file in Get-ChildItem -LiteralPath $lessonsDir -Filter '*.md' -File) {
        $head = Get-Content -LiteralPath $file.FullName -TotalCount 15 -ErrorAction SilentlyContinue
        $tagsLine = $head | Where-Object { $_ -match '^tags:' } | Select-Object -First 1
        if (-not $tagsLine) { continue }

        $tags = [regex]::Matches($tagsLine, '"([^"]+)"') | ForEach-Object { $_.Groups[1].Value.ToLowerInvariant() }
        foreach ($tag in $tags) {
            if ($tag -eq $RuleId -or ($tag.Length -ge 4 -and $NormalizedRequest.Contains($tag))) {
                $links += "lessons-learned/$($file.Name)"
                break
            }
        }
        if ($links.Count -ge $Limit) { break }
    }

    return $links
}

$rootPath = Resolve-Path -LiteralPath $Root
$null = $rootPath
$normalized = $Request.ToLowerInvariant()

$genericPatterns = @(
    '^\s*(сделай|создай|нужен|нужна|хочу)?\s*(сайт|проект|веб[- ]?сайт|web[- ]?site)\s*\.?\s*$'
)
$riskPatterns = @(
    'плат[её]ж', 'payment', 'checkout', 'stripe', 'персональн', '\bpii\b', 'gdpr',
    'hipaa', 'compliance', 'соответств', '\bsso\b', 'tenant', 'арендатор',
    'мульти[- ]?тенант', 'production data', 'продакшн[- ]?данн'
)
$riskDetailPatterns = @(
    'stripe checkout', 'shopify', 'pci', 'gdpr', 'hipaa', '\bsso\b', 'oidc',
    'clerk', 'auth\.?js', 'supabase', 'tenant isolation', 'rbac', 'abac',
    'роли', 'изоляц', 'политик'
)

$rules = @(
    (New-Rule -Id "woocommerce" -Route "WordPress + WooCommerce commerce/marketplace" -Stack "WordPress + WooCommerce + custom mu-plugin (маркетплейс-логика); React SPA кабинет при необходимости" `
        -Patterns @('woocommerce', 'вукоммерс', 'woo.?commerce', 'wordpress.*(магазин|маркетплейс|commerce|shop)', '(магазин|маркетплейс).*wordpress') `
        -WikiLinks @('docs/03-backend/WordPress-WooCommerce-backend.md', 'docs/13-playbooks/marketplace.md', 'docs/02-frontend/WordPress.md', 'patterns/backend/woocommerce-marketplace-order-split.md', 'patterns/devops/php-fpm-nginx-vps-deploy.md') `
        -Assumptions @('WooCommerce зафиксирован клиентом или требованием; кастомная логика строится поверх нативных хуков (mu-plugin), не через готовые multivendor-плагины, если требуется кастомный REST/кабинет.') `
        -OpenQuestions @('Один продавец (e-commerce) или несколько (маркетплейс: суб-заказы, комиссия, выплаты)?', 'Оплата: реальный эквайринг с самого начала или ручное подтверждение/экспорт для MVP?', 'Где хостинг: managed WP или VPS (PHP-FPM/Nginx/MySQL)?') `
        -RejectedAlternatives @('Dokan/WCFM: избыточны и конфликтуют с требованием кастомного REST/кабинета.', 'Next.js marketplace-стек: лучше при свободном выборе стека, но не при зафиксированном WordPress.', 'Shopify: другой vendor lock-in, не подходит при требовании WordPress.') `
        -AcceptanceGates @('Мультивендорная корзина корректно разбивается на суб-заказы с верной комиссией.', 'Изоляция продавцов: negative-тесты 403/404 на чужие ресурсы.', 'Локальный smoke (local-wp-smoke) + site audit на staging URL.') `
        -Priority 75),
    (New-Rule -Id "marketplace" -Route "Marketplace" -Stack "Next.js + NestJS/FastAPI + PostgreSQL + Redis + split-payments (Stripe Connect или аналог)" `
        -Patterns @('маркетплейс', 'marketplace', 'мульти.?вендор', 'multi.?vendor', 'нескольк.*продавц', 'продавц.*кабинет', 'комисси.*(продавц|заказ)', 'выплат.*продавц') `
        -WikiLinks @('docs/13-playbooks/marketplace.md', 'docs/01-development-process/stack-selection.md', 'docs/04-databases/Multi-tenancy.md') `
        -Assumptions @('Несколько независимых продавцов; нужны модерация, комиссия, выплаты и изоляция данных продавцов.') `
        -OpenQuestions @('Стек свободный или зафиксирован клиентом (например, WordPress/WooCommerce)?', 'Выплаты: сплит-платежи через эквайринг или ручной реестр/экспорт?', 'Какая модерация нужна: продавцов, товаров, отзывов?') `
        -RejectedAlternatives @('Обычный e-commerce: недостаточен при нескольких продавцах с выплатами.', 'WooCommerce+Dokan: только при зафиксированном WordPress и без кастомного кабинета.', 'Готовые SaaS-маркетплейсы: vendor lock-in и ограничение кастомной логики.') `
        -AcceptanceGates @('Order split / комиссия / выплаты покрыты интеграционными тестами.', 'Tenant-изоляция продавцов: negative permission tests.', 'KYC/модерация и anti-fraud отзывов включены в UAT.') `
        -Priority 55),
    (New-Rule -Id "wordpress" -Route "WordPress/editorial" -Stack "WordPress theme или headless WordPress + Astro/Next.js" `
        -Patterns @('wordpress', 'вордпресс', 'wp\b', 'редактор', 'editorial', 'block theme', 'plugin', 'плагин', 'headless wp', 'headless wordpress') `
        -WikiLinks @('docs/02-frontend/WordPress.md', 'docs/02-frontend/CMS-content.md', 'docs/01-development-process/site-architecture-decision-router.md') `
        -Assumptions @('WordPress выбран из-за редакторского workflow или существующей CMS, а не как SaaS backend.') `
        -OpenQuestions @('Кто владеет plugin allowlist и обновлениями WordPress?', 'Нужен theme mode или headless frontend?', 'Какие роли редакторов и preview-процесс нужны?') `
        -RejectedAlternatives @('Next.js fullstack: лишний, если основной риск — редакторский workflow.', 'Astro-only: не хватает CMS/admin workflow для редакторов.', 'Webflow: хуже, если уже есть WordPress контент и plugins.') `
        -AcceptanceGates @('Проверить roles/MFA/plugins/backups.', 'Проверить preview, redirects, SEO and cache invalidation.', 'Запустить site audit на public URL.') `
        -Priority 60),
    (New-Rule -Id "webflow" -Route "Visual builder marketing" -Stack "Webflow CMS + forms/API boundary" `
        -Patterns @('webflow', 'visual builder', 'визуальн', 'no.?code', 'маркетинг.*сам', 'marketing team', 'брендов') `
        -WikiLinks @('docs/02-frontend/Webflow.md', 'docs/13-playbooks/landing.md', 'docs/02-frontend/CMS-content.md') `
        -Assumptions @('Webflow ограничен marketing/content boundary и не заменяет product app.') `
        -OpenQuestions @('Есть ли auth, checkout или custom product logic?', 'Какие формы, analytics and scripts нужны?', 'Кто владеет SEO/redirect changes?') `
        -RejectedAlternatives @('Next.js: лучше для custom app logic, но медленнее для visual marketing iteration.', 'WordPress: лучше для plugin/editorial legacy.', 'Astro: лучше для developer-owned static site.') `
        -AcceptanceGates @('Проверить forms, SEO, redirects, consent and third-party scripts.', 'Запустить site audit на public URL.') `
        -Priority 55),
    (New-Rule -Id "shopify-hydrogen" -Route "Shopify-first commerce" -Stack "Shopify Hydrogen + Storefront API + Shopify checkout" `
        -Patterns @('shopify', 'hydrogen', 'storefront', 'cart', 'корзин', 'checkout', 'товар', 'product', 'catalog', 'каталог') `
        -WikiLinks @('docs/13-playbooks/shopify-hydrogen.md', 'docs/13-playbooks/headless-commerce.md', 'docs/13-playbooks/ecommerce.md') `
        -Assumptions @('Shopify является source of truth для catalog, cart and checkout.') `
        -OpenQuestions @('Shopify уже выбран как commerce backend?', 'Нужны ли markets, discounts, subscriptions or custom checkout?', 'Какие product/content routes критичны?') `
        -RejectedAlternatives @('Generic Next.js storefront: лучше при non-Shopify commerce backend.', 'Stripe Checkout only: проще для одного товара без catalog operations.', 'Medusa/Saleor: подходят, если команда владеет commerce backend.') `
        -AcceptanceGates @('Проверить product, collection, cart and checkout routes.', 'Проверить price/inventory cache policy.', 'Запустить checkout E2E and site audit.') `
        -Priority 65),
    (New-Rule -Id "saas" -Route "SaaS" -Stack "Next.js fullstack + PostgreSQL + Auth + Stripe" `
        -Patterns @('saas', 'подписк', 'личн.*кабинет', 'dashboard', 'дашборд', 'auth', 'логин', 'account', 'b2b', 'tenant', 'multi.?tenant') `
        -WikiLinks @('docs/13-playbooks/saas.md', 'stacks/nextjs-fullstack.md', 'docs/01-development-process/stack-selection.md') `
        -Assumptions @('Нужны login, protected routes and server-side authorization.', 'PostgreSQL подходит как default relational database.') `
        -OpenQuestions @('Какая billing model: trial, subscription, usage-based или one-off?', 'Нужны ли roles, teams or tenant isolation?', 'Есть ли compliance requirements?') `
        -RejectedAlternatives @('Astro: недостаточен для app-after-login.', 'React SPA + API: хорош при уже существующем API, но хуже как default full-stack start.', 'WordPress/Webflow: не подходят для custom SaaS domain.') `
        -AcceptanceGates @('Auth/authorization tests.', 'Billing/webhook idempotency tests if payments exist.', 'Playwright protected-route smoke and site audit.') `
        -Priority 50),
    (New-Rule -Id "service-portfolio" -Route "Service portfolio / lead generation" -Stack "Astro Node + server form + non-root VPS deploy when server endpoint is needed" `
        -Patterns @('портфолио', 'кейсы', 'услуг', 'заявк', 'лид', 'lead', 'форма', 'vps', 'депло') `
        -WikiLinks @('docs/13-playbooks/landing.md', 'docs/02-frontend/Astro.md', 'checklists/frontend-review.md', 'docs/08-devops-deploy/Release-flow.md', 'patterns/frontend/portfolio-case-screenshot-gallery.md', 'patterns/devops/non-root-vps-node-pm2-nginx-deploy.md') `
        -Assumptions @('Сайт публичный, продаёт услуги и собирает заявки через форму.', 'Кейсы показываются как реальные или демо-работы без выдуманных метрик.') `
        -OpenQuestions @('Нужен ли серверный endpoint формы или достаточно внешней формы?', 'Есть ли домен/VPS или деплой идёт на managed platform?', 'Какие кейсы и скриншоты можно показывать публично?') `
        -RejectedAlternatives @('Next.js fullstack: лишний, если нет app-after-login и сложного backend.', 'Root VPS deploy: не default, потому что повышает риск при обычных обновлениях сайта.', 'Фейковые метрики кейсов: недопустимы без аналитики.') `
        -AcceptanceGates @('Preview/full-page screenshots and lightbox smoke.', 'Form happy/error/dry-run or Telegram delivery smoke.', 'Non-root PM2 deploy, Nginx check and env preservation on VPS.') `
        -Priority 50),
    (New-Rule -Id "landing" -Route "Landing" -Stack "Astro или Next.js static + serverless form" `
        -Patterns @('landing', 'лендинг', 'маркетинг', 'seo', 'форма', 'lead', 'лид', 'waitlist', 'pre.?launch', 'промо') `
        -WikiLinks @('docs/13-playbooks/landing.md', 'docs/02-frontend/Astro.md', 'docs/09-testing/Site-audit-tooling.md') `
        -Assumptions @('Страница публичная, SEO/performance важнее app state.', 'Backend нужен только для forms/analytics integrations.') `
        -OpenQuestions @('Нужна ли CMS/editorial команда?', 'Какие form delivery and anti-spam requirements?', 'Нужны ли локали или campaign variants?') `
        -RejectedAlternatives @('Next.js fullstack: лишний для простого лендинга.', 'React SPA: хуже для SEO/performance.', 'Webflow: лучше только если marketing team должна править layout без разработчиков.') `
        -AcceptanceGates @('Lighthouse/site audit thresholds.', 'Form happy/error/spam tests.', 'SEO metadata, OG and redirects.') `
        -Priority 40),
    (New-Rule -Id "cms" -Route "CMS/content site" -Stack "Astro/Next.js/Nuxt + Payload/Strapi/Sanity/Directus/WordPress" `
        -Patterns @('cms', 'контент', 'blog', 'блог', 'newsroom', 'новост', 'публикац', 'редактор', 'preview', 'media library') `
        -WikiLinks @('docs/02-frontend/CMS-content.md', 'docs/02-frontend/Payload-CMS.md', 'docs/02-frontend/Strapi.md', 'docs/02-frontend/Sanity.md', 'docs/02-frontend/Directus.md') `
        -Assumptions @('Контент редактируют не только разработчики.') `
        -OpenQuestions @('Кто источник правды: filesystem, CMS или product DB?', 'Нужны ли draft preview, scheduled publish and media library?', 'Self-hosted или hosted CMS допустим?') `
        -RejectedAlternatives @('Astro-only: проще для developer-owned content.', 'WordPress: подходит при existing editorial workflow/plugin ecosystem.', 'Webflow: подходит для visual marketing, но слабее для structured product content.') `
        -AcceptanceGates @('Publish/unpublish/preview tests.', 'Cache invalidation and redirect tests.', 'SEO and media pipeline checks.') `
        -Priority 35),
    (New-Rule -Id "admin" -Route "Admin/internal CRUD" -Stack "React SPA + API или server-rendered htmx/Laravel Livewire" `
        -Patterns @('admin', 'админ', 'internal', 'внутрен', 'crud', 'таблиц', 'table', 'forms', 'оператор', 'backoffice') `
        -WikiLinks @('docs/13-playbooks/admin-dashboard.md', 'stacks/react-spa-api.md', 'docs/02-frontend/HTMX.md', 'docs/02-frontend/Laravel-Livewire.md') `
        -Assumptions @('SEO вторичен; важны permissions, dense UI and audit log.') `
        -OpenQuestions @('Есть ли existing API/backend?', 'Нужны SSO/RBAC/audit log?', 'UI rich client или mostly forms/tables?') `
        -RejectedAlternatives @('Landing/Astro: не подходит для protected CRUD.', 'Next.js fullstack: возможен, но не обязателен при existing API.', 'Webflow/WordPress: не подходят для internal permissions-heavy app.') `
        -AcceptanceGates @('Permission denied and audit-log tests.', 'Table/filter URL state tests.', 'Playwright smoke for critical flows.') `
        -Priority 35),
    (New-Rule -Id "edge" -Route "Edge-first app" -Stack "Vite/React or static frontend + Cloudflare Workers + Hono" `
        -Patterns @('cloudflare', 'workers', 'worker', 'edge', 'low latency', 'низк.*latency', 'hono', 'kv\b', 'r2\b', 'durable object') `
        -WikiLinks @('docs/08-devops-deploy/Cloudflare-Workers-fullstack.md', 'docs/03-backend/Hono.md', 'docs/01-development-process/runtime-selection.md') `
        -Assumptions @('Edge runtime constraints acceptable; no Node-only APIs or long-running jobs.') `
        -OpenQuestions @('Нужны ли Node-only APIs or long-running jobs?', 'Какие Cloudflare bindings: KV, R2, D1, Durable Objects?', 'Где authoritative database?') `
        -RejectedAlternatives @('Next.js/Vercel: проще для full-stack React default.', 'NestJS/FastAPI: лучше для long-running backend/domain services.', 'Static-only: недостаточно при API/runtime requirements.') `
        -AcceptanceGates @('Worker smoke tests.', 'Bindings/env parity checks.', 'Contract tests for API routes.') `
        -Priority 45),
    (New-Rule -Id "react-router" -Route "React Router Framework" -Stack "React Router v7 Framework/Data mode + Vite" `
        -Patterns @('react router', 'remix', 'framework mode', 'loader', 'action', 'nested route') `
        -WikiLinks @('docs/02-frontend/React-Router.md', 'docs/02-frontend/Vite-React.md', 'docs/01-development-process/stack-selection.md') `
        -Assumptions @('Команда хочет React routing/data conventions без Next.js App Router.') `
        -OpenQuestions @('Нужен framework mode SSR/pre-render или SPA data mode?', 'Какие deployment/runtime constraints?', 'Есть ли Remix migration?') `
        -RejectedAlternatives @('Next.js: лучше для App Router/RSC and Vercel-first default.', 'TanStack Start: лучше для Query-first full-stack React.', 'Vite SPA: проще, если SSR/data mode не нужны.') `
        -AcceptanceGates @('Route loader/action error tests.', 'SSR/hydration smoke if framework mode.', 'Protected route/API authorization tests.') `
        -Priority 55),
    (New-Rule -Id "static" -Route "Static docs/blog" -Stack "Astro, Eleventy или Hugo + CDN/static host" `
        -Patterns @('static', 'статич', 'docs', 'документац', 'documentation', 'help center', 'blog', 'блог', 'hugo', 'eleventy', '11ty') `
        -WikiLinks @('docs/02-frontend/Astro.md', 'docs/02-frontend/Eleventy.md', 'docs/02-frontend/Hugo.md', 'docs/13-playbooks/landing.md') `
        -Assumptions @('Auth/app state не нужны; content can be built statically.') `
        -OpenQuestions @('Нужен ли CMS/editorial preview?', 'Нужен ли search, i18n or thousands of pages?', 'Кто владеет redirects and content updates?') `
        -RejectedAlternatives @('Next.js fullstack: лишний без app state.', 'WordPress: лучше при редакторском workflow.', 'Webflow: лучше при visual builder ownership.') `
        -AcceptanceGates @('Build, broken links, sitemap and redirects.', 'SEO metadata and accessibility checks.', 'Site audit on preview URL.') `
        -Priority 30),
    (New-Rule -Id "angular" -Route "Enterprise Angular" -Stack "Angular SSR + enterprise API/backend" `
        -Patterns @('angular', 'ангулар') `
        -WikiLinks @('docs/02-frontend/Angular-SSR.md', 'docs/02-frontend/Frontend-blueprints.md', 'docs/02-frontend/Performance.md') `
        -Assumptions @('Angular уже является командным или enterprise standard.') `
        -OpenQuestions @('Angular уже принят как platform standard?', 'Нужен SSR/hydration or client-only enterprise app?', 'Какие API/backend constraints?') `
        -RejectedAlternatives @('Next.js: лучше для React/Vercel ecosystem.', 'Astro: лучше для static/content site.', 'Nuxt/SvelteKit: подходят только при Vue/Svelte team fit.') `
        -AcceptanceGates @('SSR/hydration smoke.', 'Browser-only API checks.', 'E2E for protected routes.') `
        -Priority 70),
    (New-Rule -Id "vue-svelte-solid" -Route "Non-React framework" -Stack "Nuxt, SvelteKit или SolidStart based on explicit team/runtime fit" `
        -Patterns @('vue', 'nuxt', 'svelte', 'sveltekit', 'solid', 'solidstart') `
        -WikiLinks @('docs/02-frontend/Nuxt.md', 'docs/02-frontend/SvelteKit.md', 'docs/02-frontend/SolidStart.md', 'docs/01-development-process/stack-selection.md') `
        -Assumptions @('Команда явно выбирает non-React ecosystem.') `
        -OpenQuestions @('Какая команда/SDK ecosystem: Vue, Svelte или Solid?', 'Нужны SSR/forms/server routes?', 'Какие component libraries обязательны?') `
        -RejectedAlternatives @('Next.js: лучше при React ecosystem default.', 'Astro: лучше для static content.', 'React SPA: лучше при existing React API app.') `
        -AcceptanceGates @('SSR/forms/E2E tests.', 'Adapter/deploy checks.', 'Component library compatibility review.') `
        -Priority 65)
)

$matchedRules = foreach ($rule in $rules) {
    $score = Get-MatchCount -Text $normalized -Patterns $rule.patterns
    if ($score -gt 0) {
        [pscustomobject]@{
            rule = $rule
            score = $score
            rank = ($score * 100) + $rule.priority
        }
    }
}

$isGeneric = Test-AnyPattern -Text $normalized -Patterns $genericPatterns
$hasRisk = Test-AnyPattern -Text $normalized -Patterns $riskPatterns
$hasRiskDetails = Test-AnyPattern -Text $normalized -Patterns $riskDetailPatterns
$best = @($matchedRules | Sort-Object -Property rank -Descending | Select-Object -First 1)
$bestMatch = if ($best.Count -gt 0) { $best[0].rule } else { $null }
$signalIds = @($matchedRules | Sort-Object -Property rank -Descending | ForEach-Object { $_.rule.id })

if ($isGeneric -or $null -eq $bestMatch) {
    $confidence = "low"
    $recommendedRoute = ""
    $recommendedStack = ""
    $assumptions = @()
    $openQuestions = @(
        "Какой тип сайта нужен: landing/content/SaaS/admin/e-commerce?",
        "Нужны ли login, роли, платежи, CMS или формы?",
        "Где будет hosting: Vercel, Cloudflare, Shopify/Webflow/WordPress или internal?"
    )
    $rejectedAlternatives = @(
        "Next.js не выбран: тип продукта и data/auth constraints неизвестны.",
        "Astro не выбран: неизвестно, является ли сайт static/SEO-first.",
        "WordPress/Webflow не выбраны: неизвестен editorial/visual-builder workflow."
    )
    $acceptanceGates = @("Сначала пройти discovery и повторить router preflight.")
    $wikiLinks = @(
        "docs/01-development-process/site-architecture-decision-router.md",
        "checklists/project-discovery.md",
        "prompts/create-new-project.md"
    )
}
elseif ($hasRisk -and -not $hasRiskDetails -and $bestMatch.id -ne "shopify-hydrogen") {
    $confidence = "blocker"
    $recommendedRoute = $bestMatch.route
    $recommendedStack = ""
    $assumptions = @("Запрос содержит high-risk constraints, но security/platform details не уточнены.")
    $openQuestions = Limit-Items -Items @(
        "Какие payment/PII/compliance requirements и провайдеры уже выбраны?",
        "Нужны ли roles, SSO, tenant isolation или audit log?",
        "Какие data residency, security review and release gates обязательны?"
    ) -Count 3
    $rejectedAlternatives = @(
        "Нельзя выбрать default stack до security/compliance discovery.",
        "Нельзя выбирать WordPress/Webflow для high-risk product logic без boundary review.",
        "Нельзя закрывать payments по browser redirect без webhook/idempotency plan."
    )
    $acceptanceGates = @("Security review before implementation.", "Compliance baseline and data boundary review.", "Auth/payment/webhook tests before release.")
    $wikiLinks = @(
        "docs/01-development-process/site-architecture-decision-router.md",
        "checklists/security-review.md",
        "docs/05-auth-security/Compliance-baseline.md"
    )
}
else {
    $confidence = if ($best[0].score -ge 2) { "high" } else { "medium" }
    $recommendedRoute = $bestMatch.route
    $recommendedStack = $bestMatch.stack
    $assumptions = $bestMatch.assumptions
    $openQuestions = if ($confidence -eq "medium") { Limit-Items -Items $bestMatch.openQuestions -Count 3 } else { @() }
    $rejectedAlternatives = Limit-Items -Items $bestMatch.rejectedAlternatives -Count 3
    $acceptanceGates = $bestMatch.acceptanceGates
    $wikiLinks = $bestMatch.wikiLinks
}

$classification = [pscustomobject]@{
    signals = $signalIds
    riskDetected = $hasRisk
    riskDetailsDetected = $hasRiskDetails
    genericRequest = $isGeneric
}

# @() снаружи if: пустой вывод if-выражения иначе присваивается как $null и в JSON уходит null.
$lessonLinks = @(if ($null -ne $bestMatch) {
    Get-LessonLinks -RuleId $bestMatch.id -NormalizedRequest $normalized -RootPath $rootPath.Path
})

$result = [pscustomobject]@{
    confidence = $confidence
    classification = $classification
    recommendedRoute = $recommendedRoute
    recommendedStack = $recommendedStack
    assumptions = @($assumptions)
    openQuestions = @($openQuestions)
    rejectedAlternatives = @($rejectedAlternatives)
    acceptanceGates = @($acceptanceGates)
    wikiLinks = @($wikiLinks)
    lessonLinks = $lessonLinks
}

if ($OutputJson) {
    $result | ConvertTo-Json -Depth 8
}
else {
    Write-Host "Decision confidence: $confidence"
    Write-Host "Recommended route: $recommendedRoute"
    Write-Host "Recommended stack: $recommendedStack"
    Write-Host "Signals: $($signalIds -join ', ')"
    Write-Host ""
    Write-Host "Assumptions:"
    foreach ($item in $assumptions) { Write-Host "- $item" }
    Write-Host ""
    Write-Host "Open questions:"
    foreach ($item in $openQuestions) { Write-Host "- $item" }
    Write-Host ""
    Write-Host "Rejected alternatives:"
    foreach ($item in $rejectedAlternatives) { Write-Host "- $item" }
    Write-Host ""
    Write-Host "Acceptance gates:"
    foreach ($item in $acceptanceGates) { Write-Host "- $item" }
    Write-Host ""
    Write-Host "Wiki links:"
    foreach ($item in $wikiLinks) { Write-Host "- $item" }
    if ($lessonLinks.Count -gt 0) {
        Write-Host ""
        Write-Host "Lessons learned (прочитать до реализации):"
        foreach ($item in $lessonLinks) { Write-Host "- $item" }
    }
}

if ($FailOnLowConfidence -and ($confidence -eq "low" -or $confidence -eq "blocker")) {
    exit 1
}
exit 0
