#!/usr/bin/env bash
# Kullanım: ./scripts/bump-image.sh <app-name> <env> <new-tag>
# Örnek:    ./scripts/bump-image.sh ubys-core-web-app dev abc1234
#           ./scripts/bump-image.sh ubys-core-web-app prod v1.5.0

set -euo pipefail

APP_NAME="${1:?'App name gerekli'}"
ENV="${2:?'Ortam gerekli: dev | test | staging | prod'}"
NEW_TAG="${3:?'Image tag gerekli'}"

REGISTRY="harbor.example.com/ubys"
OVERLAY="apps/${APP_NAME}/overlays/${ENV}"
KUSTOMIZATION="${OVERLAY}/kustomization.yaml"

[[ -f "$KUSTOMIZATION" ]] || { echo "HATA: $KUSTOMIZATION bulunamadi"; exit 1; }

VALID_ENVS=("dev" "test" "staging" "prod")
[[ " ${VALID_ENVS[*]} " =~ " ${ENV} " ]] || { echo "HATA: Gecersiz ortam '$ENV'"; exit 1; }

# Prod'a sadece semver tag
if [[ "$ENV" == "prod" && ! "$NEW_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "HATA: Prod'a sadece semver tag deploy edilebilir (ornek: v1.5.0)"
  exit 1
fi

echo "Uygulama : $APP_NAME"
echo "Ortam    : $ENV"
echo "Yeni tag : $NEW_TAG"

cd "$OVERLAY"
kustomize edit set image "${REGISTRY}/${APP_NAME##ubys-}=${REGISTRY}/${APP_NAME##ubys-}:${NEW_TAG}"
cd - > /dev/null

git config user.email "ci-bot@example.com"
git config user.name "CI Bot"
git add "$KUSTOMIZATION"
git commit -m "chore(${ENV}): bump ${APP_NAME} -> ${NEW_TAG} [ci skip]"

if [[ "$ENV" == "prod" ]]; then
  BRANCH="deploy/${APP_NAME}-${NEW_TAG}-prod"
  git checkout -b "$BRANCH"
  git push origin "$BRANCH"
  echo "PR aciniz: $BRANCH -> main (ArgoCD manuel sync bekleniyor)"
else
  git push origin HEAD
  echo "Deploy baslatildi. ArgoCD otomatik sync edecek."
fi
