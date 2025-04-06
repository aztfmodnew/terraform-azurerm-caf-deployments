  function terraform_with_var_files() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: terraform_with_var_files [OPTIONS]"
    echo "Options:"
    echo "  --dir DIR                Specify the directory containing .tfvars files"
    echo "  --action ACTION          Specify the Terraform action (plan, apply, destroy, import)"
    echo "  --auto AUTO              Specify 'auto' for auto-approve (optional)"
    echo "  --resource_address ADDR  Specify the resource address for import action (optional)"
    echo "  --resource_id ID         Specify the resource ID for import action (optional)"
    echo "  --workspace WORKSPACE    Specify the Terraform workspace (default: default)"
    echo "  --help, -h               Show this help message"
    return 0
  fi

  local dir=""
  local action=""
  local auto=""
  local resource_address=""
  local resource_id=""
  local workspace="default"

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --dir) dir="$2"; shift ;;
      --action) action="$2"; shift ;;
      --auto) auto="$2"; shift ;;
      --resource_address) resource_address="$2"; shift ;;
      --resource_id) resource_id="$2"; shift ;;
      --workspace) workspace="$2"; shift ;;
      *) echo "Unknown parameter passed: $1"; return 1 ;;
    esac
    shift
  done

  if [[ ! -d "$dir" ]]; then
    echo "El directorio especificado no existe."
    return 1
  fi

  if [[ "$action" != "plan" && "$action" != "apply" && "$action" != "destroy" && "$action" != "import" ]]; then
    echo "Acción no válida. Usa 'plan', 'apply', 'destroy' o 'import'."
    return 1
  fi

  local var_files=()
  for file in "$dir"/*.tfvars; do
    if [[ -f "$file" ]]; then
      var_files+=("--var-file $file")
    fi
  done

  if [[ ${#var_files[@]} -eq 0 ]]; then
    echo "No se encontraron archivos .tfvars en el directorio especificado."
    return 1
  fi

  echo "Inicializando Terraform..."
  eval terraform init
  if [[ $? -ne 0 ]]; then
    echo "La inicialización de Terraform falló."
    return 1
  fi

  echo "Seleccionando el workspace: $workspace"
  eval terraform workspace select "$workspace" || eval terraform workspace new "$workspace"
  if [[ $? -ne 0 ]]; then
    echo "La selección del workspace falló."
    return 1
  fi

  echo "Validando la configuración de Terraform..."
  eval terraform validate
  if [[ $? -ne 0 ]]; then
    echo "La validación de Terraform falló."
    return 1
  fi

  local command="terraform $action ${var_files[@]}"

  if [[ "$action" == "import" ]]; then
    if [[ -z "$resource_address" || -z "$resource_id" ]]; then
      echo "Para la acción 'import', se deben proporcionar la dirección del recurso y el ID del recurso."
      return 1
    fi
    command="terraform $action ${var_files[@]} $resource_address $resource_id"
  elif [[ "$auto" == "auto" && ( "$action" == "apply" || "$action" == "destroy" ) ]]; then
    command="$command -auto-approve"
  fi

  echo "Ejecutando: $command"
  eval "$command"
}

# Uso de la función
# terraform_with_var_files --dir "/ruta/al/directorio" --action "plan" --workspace "workspace"
# terraform_with_var_files --dir "/ruta/al/directorio" --action "apply" --auto "auto" --workspace "workspace"
# terraform_with_var_files --dir "/ruta/al/directorio" --action "destroy" --auto "auto" --workspace "workspace"
# terraform_with_var_files --dir "/ruta/al/directorio" --action "import" --resource_address "resource_address" --resource_id "resource_id" --workspace "workspace"