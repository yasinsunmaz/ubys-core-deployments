# ubys-deployments — GitOps Deployment Repository

## Mimari

```
CI Pipeline → Harbor (image push) → bu repo (tag commit/PR) → ArgoCD → K8s
```

## Ortam Stratejisi

| Ortam   | autoSync | selfHeal | prune | Onay        |
|---------|----------|----------|-------|-------------|
| dev     | ✅       | ✅       | ✅    | Otomatik    |
| test    | ✅       | ✅       | ❌    | Otomatik    |
| staging | ❌       | ❌       | ❌    | Manuel sync |
| prod    | ❌       | ❌       | ❌    | PR + manuel |

## Yeni Uygulama Ekleme

1. `apps/<app-adi>/` klasörünü mevcut birinden kopyala
2. `appsets/<app-adi>.yaml` oluştur
3. CI pipeline sonuna `bump-image.sh <app-adi> <env> <tag>` ekle

## Rollback

```bash
./scripts/bump-image.sh ubys-core-web-app prod v1.4.2
# veya
git revert <commit-sha> && git push
```
