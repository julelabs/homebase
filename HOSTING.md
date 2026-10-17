# Hosting

Die Frontpage läuft seit 17.10.2026 auf Bunny Static Sites:

- Domain: https://homebase.breyer.berlin
- Site: `homebase`, Dateien aus `src/`, Einstellungen in `bunny.jsonc`
- CDN: `sites-homebase-npe754.b-cdn.net`
- Storage-Zone: `1998738`, Pull-Zone: `6820407`, Speicherregion Deutschland
- DNS bei Cloudflare: CNAME `homebase` auf das CDN-Ziel, Modus `DNS only`
- Kostenloses TLS-Zertifikat mit erzwungenem HTTPS

## Deployment

`.github/workflows/frontend.yml` prüft die JavaScript-Syntax und veröffentlicht
Änderungen an `src/`, `bunny.jsonc` oder am Frontend-Workflow auf `main`.
Anschließend vergleicht es beide ausgelieferten HTML-Dateien über HTTPS mit dem
Repository. Laufende Deployments werden nicht abgebrochen.
Nach erfolgreicher Prüfung räumt der Workflow alte Bunny-Deployments mit
`--keep 3` auf. Die aktuelle und die vorherige Version bleiben immer erhalten.

Das GitHub-Secret `BUNNYNET_API_KEY` stammt aus dem angemeldeten lokalen
Bunny-CLI-Profil. Cloudflare-Secrets werden für das Frontend nicht mehr benötigt.

Manuell über GitHub Actions:

```sh
gh workflow run frontend.yml --repo julelabs/Homebase --ref main
```

Lokal aus dem Repository:

```sh
bunny sites deploy --no-link --output json
bunny sites show homebase
```

Der Backend-Workflow `ci.yml` bleibt separat. `bunny.json` enthält weiterhin die
Magic-Containers-App-ID und die API-Adresse. Der Frontend-Workflow verändert
weder den Backend-Container noch die Datenbank.

## Rückweg

Eine vorherige Bunny-Version kann ohne erneuten Upload veröffentlicht werden:

```sh
bunny sites deployments publish --previous --site homebase --force
```

Das bisherige Cloudflare-Pages-Projekt `homebase-breyer` bleibt als Rückweg
erhalten, bekommt aber keine automatischen Deployments mehr. Für einen
Hosting-Rückwechsel den CNAME `homebase` wieder auf `homebase-breyer.pages.dev`
setzen und den bisherigen Cloudflare-Proxy aktivieren. Der dortige Dateistand
ist der Stand vor dem Umzug.
