#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: PROJECT_DIR=/path/to/project $0 <dev|staging|production> [packer-validate-args...]" >&2
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

environment="$1"
shift

case "$environment" in
  dev|staging|production)
    ;;
  *)
    usage
    exit 1
    ;;
esac

project_dir="${PROJECT_DIR:-$PWD}"
var_file="$project_dir/vars/${environment}.pkrvars.hcl"

if [[ ! -f "$var_file" ]]; then
  echo "Missing var file: $var_file" >&2
  exit 1
fi

if ! compgen -G "$project_dir/*.pkr.hcl" > /dev/null; then
  echo "Missing Packer template in project directory: $project_dir" >&2
  exit 1
fi

cd "$project_dir"

packer init .
packer fmt -check .
packer validate -var-file="$var_file" "$@" .