#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/terraform_with_var_files.sh"
declare -a calls=()
fail_action=""
terraform() {
  local encoded
  printf -v encoded '%s|' "$@"
  calls+=("$encoded")
  [[ "$1" != "$fail_action" ]]
}
fixtures="$script_dir/tests/var files"
terraform_with_var_files --dir "$fixtures" --action plan --workspace wrapper-test -- -input=false '-out=plan with spaces.tfplan'
[[ ${#calls[@]} -eq 4 ]]
[[ "${calls[0]}" == 'init|-input=false|' ]]
[[ "${calls[1]}" == 'workspace|select|-or-create|wrapper-test|' ]]
[[ "${calls[3]}" == "plan|-var-file=$fixtures/01 global.tfvars|-var-file=$fixtures/02 tags.tfvars|-input=false|-out=plan with spaces.tfplan|" ]]
calls=()
terraform_with_var_files --dir "$fixtures" --action import --workspace wrapper-test --resource_address 'module.example.resource["a b"]' --resource_id '/an id with spaces'
[[ "${calls[3]}" == *'|module.example.resource["a b"]|/an id with spaces|' ]]
fail_action=plan
if terraform_with_var_files --dir "$fixtures" --action plan --workspace wrapper-test; then
  echo 'FAIL: plan failure did not propagate.' >&2
  exit 1
fi
echo 'PASS: Bash wrapper quoting/order/import/failure (5 regressions).'
