param(
  [string]$BaseUrl = "https://luxlog.vercel.app",
  [string]$PhotoId = "",
  [string]$Username = ""
)

$ErrorActionPreference = "Stop"

function Pass($msg) { Write-Host "PASS $msg" -ForegroundColor Green }
function Fail($msg) { Write-Host "FAIL $msg" -ForegroundColor Red }
function Warn($msg) { Write-Host "WARN $msg" -ForegroundColor Yellow }

function Assert-Contains {
  param(
    [string]$Content,
    [string]$Pattern,
    [string]$Label
  )

  if ($Content -match $Pattern) {
    Pass $Label
  } else {
    Fail $Label
  }
}

Write-Host "== Luxlog SEO QA =="
Write-Host "Target: $BaseUrl"

$robots = (Invoke-WebRequest "$BaseUrl/robots.txt").Content
Assert-Contains $robots "Disallow:\s*/upload" "robots.txt disallow upload"
Assert-Contains $robots "Disallow:\s*/notifications" "robots.txt disallow notifications"
Assert-Contains $robots "Sitemap:" "robots.txt has sitemap"

$sitemap = (Invoke-WebRequest "$BaseUrl/sitemap.xml").Content
Assert-Contains $sitemap "<urlset" "sitemap.xml is valid XML urlset"
Assert-Contains $sitemap "<loc>$([Regex]::Escape($BaseUrl))/" "sitemap includes home"
Assert-Contains $sitemap "<loc>$([Regex]::Escape($BaseUrl))/explore" "sitemap includes explore"

$home = (Invoke-WebRequest "$BaseUrl/").Content
Assert-Contains $home "property=\"og:title\"" "home has og:title"
Assert-Contains $home "name=\"twitter:card\"" "home has twitter card"
Assert-Contains $home "rel=\"canonical\"" "home has canonical"

if ($PhotoId -ne "") {
  $photoReq = Invoke-WebRequest "$BaseUrl/photo/$PhotoId" -Headers @{ "User-Agent" = "googlebot" }
  $photo = $photoReq.Content
  Assert-Contains $photo "ImageObject" "photo bot snapshot has ImageObject JSON-LD"
  Assert-Contains $photo "og:title" "photo bot snapshot has og:title"
  Assert-Contains $photo "canonical" "photo bot snapshot has canonical"
} else {
  Warn "Skip photo bot snapshot checks (pass -PhotoId <id>)"
}

if ($Username -ne "") {
  $userReq = Invoke-WebRequest "$BaseUrl/u/$Username" -Headers @{ "User-Agent" = "twitterbot" }
  $user = $userReq.Content
  Assert-Contains $user "ProfilePage" "profile bot snapshot has ProfilePage JSON-LD"
  Assert-Contains $user "og:type\" content=\"profile\"|og:type' content='profile'" "profile bot snapshot has og:type=profile"
} else {
  Warn "Skip profile bot snapshot checks (pass -Username <username>)"
}

Write-Host ""
Write-Host "Manual checks still required:"
Write-Host "1) Google Rich Results Test on one /photo/:id URL"
Write-Host "2) Facebook Sharing Debugger and X Card Validator"
Write-Host "3) Search Console sitemap submit + indexing coverage"
