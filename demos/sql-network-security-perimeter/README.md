# Azure SQL outbound access with Network Security Perimeter

## Resultado y limites

SQL Database lee un archivo sintetico Extended Events (`.xel`) por HTTPS en
Blob privado **fuera del NSP**, usando una SAS efimera de delegacion de usuario.
Se mantiene el login SQL Entra-only y la misma regla inbound /32 en A/B/C/D.
No hay identidad administrada SQL: Microsoft documenta que, para esta lectura,
esa identidad no necesita la regla FQDN e invalidaria la expectativa de bloqueo.
No es un navegador ni una demo de exfiltracion generica. No usamos
`sp_invoke_external_rest_endpoint` ni damos por supuesta su cobertura NSP.

| Estado | `access_mode` | `allow_blob_outbound` | Lectura esperada |
| --- | --- | --- | --- |
| A | Transition | false | Eventos no vacios |
| B | Enforced | false | Bloqueada |
| C | Enforced | true | Mismos eventos |
| D | Enforced | false | Bloqueada de nuevo |

CAF 5 usa NSP API `2023-08-01-preview`: el wrapper traduce **Transition a Learning**.
No cambiar la entrada publica a Learning. Se permite solo el FQDN exacto
`<cuenta>.blob.core.windows.net`, nunca `*.blob.core.windows.net`.

## Integracion raiz (no es un segundo root)

Como `demos/300-advanced-network-manager`, esta carpeta contiene solamente
configuracion sectorial y scripts. **Ejecutar Terraform desde la raiz del repo.**
El unico modulo principal es `module.example`, source `aztfmodnew/caf/azurerm`,
version **5.0.0 exacta**. No ejecutar `terraform init` dentro de esta carpeta.

Ficheros publicos que copiar/adaptar juntos:

- `global_settings.tfvars`: region Spain Central, naming passthrough y providers.
- `resource_groups.tfvars`: RG exclusivo.
- `sql.tfvars`: servidor Entra-only, IP documental `203.0.113.10`, IDs dummy,
  DB Basic con backups **Local** (no Geo) y sin redundancia de zona.
- `storage.tfvars`: StorageV2 LRS/Hot, sin shared keys, contenedor privado.
- `logs.tfvars`: Log Analytics y categorias NSP explicitas.
- `network_security_perimeters.tfvars`: perfil, asociacion SQL por clave,
  diagnosticos y controles A/B/C/D.

RG, DB, Storage/contenedor, logs, NSP/perfil/asociacion/reglas y diagnosticos son
CAF. El helper raiz `sql_nsp.tf`, desactivado por defecto (`{}` / null), crea solo
el logical server Entra-only y firewall /32: CAF 5.0.0 genera password y secreto
Key Vault incluso Entra-only cuando no recibe password. No se proporciona una
password ficticia. El ID SQL se entrega a CAF mediante `remote_objects`, con
claves conocidas aunque el ID sea desconocido durante el primer plan.
El rol Storage Blob Data Contributor se asigna al administrador/operador SQL.
Para esta demo debe ser el usuario operador (no un grupo); esperar propagacion
RBAC antes de emitir SAS. No hay VNet/VM/Private Endpoint.

Storage permite red publica pero no acceso anonimo. Es deliberado para el destino
externo del laboratorio, no una recomendacion de produccion. La SAS solo vive en
memoria del runner/credencial SQL; no entra en tfvars, argumentos, state o logs.
Ver [compatibilidad CAF 5 del wrapper](../../tools/CAF5.md).

## Preparar y planificar desde la raiz

Terraform >= 1.8, Azure CLI autenticada y PowerShell con System.Data.SqlClient.
Usar una suscripcion autorizada con proveedores Sql, Storage, Network y
OperationalInsights ya registrados; no se auto-registran proveedores.
Necesita permisos de creacion y asignacion de roles. Comprobar cuotas, precios y
Azure Policy. Basic, Storage y Log Analytics tienen coste; la cuota diaria de
logs no es un limite financiero.

Adaptar nombres globalmente unicos, tenant y object ID del operador y su IP publica
estable. Guardar mapas completos modificados en `zz-local.tfvars` **ignorado**:
Terraform reemplaza mapas, no los fusiona entre var-files. El wrapper carga los
ficheros por nombre; `zz-local.tfvars` prevalece. Nunca publicar IDs personales,
IP real, tokens, state ni planes.

```powershell
# Desde la raiz del clone:
az login
$env:ARM_SUBSCRIPTION_ID = '<suscripcion-autorizada>'
.\demos\sql-network-security-perimeter\comprobar-region.ps1 -SubscriptionId $env:ARM_SUBSCRIPTION_ID -Location spaincentral
. .\tools\terraform_with_var_files.ps1
Terraform-WithVarFiles -Dir .\demos\sql-network-security-perimeter -Action plan -Workspace sql-nsp-tour -TerraformArguments @('-input=false', '-out=A.local.tfplan')
```

Linux (desde la raiz):

```bash
export ARM_SUBSCRIPTION_ID='<authorized-subscription>'
source ./tools/terraform_with_var_files.sh
terraform_with_var_files --dir demos/sql-network-security-perimeter --action plan --workspace sql-nsp-tour -- -input=false -out=A.local.tfplan
```

Elegir backend aprobado **antes** del primer apply. Sin bloque backend configurado
se usa backend local; el fichero `backend.azurerm` es una plantilla, no un backend
activado automaticamente. Los workspaces separan state, no son barreras de
seguridad. Proteger lock/state/planes y no proyectarlos. Con Windows/Git longpaths,
establecer solo en el proceso de init `GIT_CONFIG_COUNT=1`,
`GIT_CONFIG_KEY_0=core.longpaths`, `GIT_CONFIG_VALUE_0=true`; no cambiar Git global.
Conservar el lock raiz local (el repo lo ignora por convencion).

West Europe rechazo SQL durante el ensayo historico; Spain Central lo permitio.
`comprobar-region.ps1` consulta capacidades, no garantiza cuota/disponibilidad.
`terraform fmt -check` y `terraform validate` se ejecutan desde raiz; los tfvars
se comprueban con `terraform fmt -check demos/sql-network-security-perimeter`.

## Despliegue y lectura (solo tras revisar/aprobar el plan)

**Integracion desplegada y probada el 2026-10-10 desde el root compartido.**
El plan/apply inicial creo 19 objetos Terraform. A/C devolvieron dos eventos;
B y D bloquearon la lectura con error exterior 40197 e interno 25717, manteniendo
login y entrada /32. Ver [ensayo raiz](ensayo-raiz-azure.json) para tiempos,
propagacion, diagnosticos y comprobacion de destruccion. Los siguientes comandos
reproducen el flujo; revisar cada plan antes de aplicarlo:

```powershell
# El wrapper ya selecciono sql-nsp-tour; comprobar antes del apply guardado.
terraform workspace show
terraform apply A.local.tfplan
.\demos\sql-network-security-perimeter\ejecutar-sql.ps1 -Action Prepare -Workspace sql-nsp-tour
.\demos\sql-network-security-perimeter\ejecutar-sql.ps1 -Action Read -Workspace sql-nsp-tour
```

El runner busca endpoints en el output raiz `sql_nsp_demo`, comprueba workspace y
**no selecciona otro**. Obtiene token Entra SQL y SAS `--as-user --auth-mode login`
de dos horas solo en Prepare. Read reutiliza credencial/archivo. Resultado vacio
sale con codigo 2: no es prueba concluyente. Prepare solo en A antes de proyectar;
necesita CONTROL en `demo`, no `master`.

Para B/C/D, pasar el objeto completo `sql_nsp_demo` con los mismos selectores:

```powershell
# B; en C usar true; D vuelve a false.
$next = '-var=sql_nsp_demo={sql_server_key="lab",storage_account_key="external",nsp_key="lab",profile_key="demo",access_mode="Enforced",allow_blob_outbound=false}'
Terraform-WithVarFiles -Dir .\demos\sql-network-security-perimeter -Action plan -Workspace sql-nsp-tour -TerraformArguments @('-input=false', '-out=next.local.tfplan', $next)
# Revisar diff y workspace antes de aprobar:
terraform apply next.local.tfplan
.\demos\sql-network-security-perimeter\ejecutar-sql.ps1 -Action Read -Workspace sql-nsp-tour
```

Mantener IP, login, SAS, archivo y consulta constantes. Esperar propagacion.
No todo error es NSP: comprobar archivo/SAS y correlacionar diagnosticos.
25759/25717, error exterior 40197 o resultado vacio pueden aparecer; fallo de
login 42118 es inbound y **no** demuestra salida. No ampliar IP a `0.0.0.0/0`.
Las consultas [diagnosticos-query.json](diagnosticos-query.json),
[tablas](diagnosticos-tablas.json) y [esquema](diagnosticos-schema.json) usan las
columnas historicamente verificadas de `NSPAccessLogs`. El nuevo root configura
categorias explicitas, no `allLogs`. No se promete latencia.

## Evidencia y validacion

[ensayo-azure.json](ensayo-azure.json) es **historico del root autonomo anterior**
(2026-10-10, Spain Central), no evidencia de este nuevo root: A/C devolvieron dos
eventos; B/D fallaron en Blob con 40197/25717 manteniendo login. Logs A/B/C
confirmaron Allowed/defaultPolicy, Denied/DefaultDenyAll y Allowed/blob-outbound;
D no estaba ingerido. Se destruyeron 15 recursos y el state quedo vacio.
No hay una demo actualmente desplegada. SQL NSP sigue documentado como preview.
Reensayar este root antes del evento; no presentar planes como pruebas T-SQL.

Las siete pruebas mock del root anterior se retiraron. Las regresiones actuales
estan en `tools/test_terraform_with_var_files.ps1` y `.sh` (argumentos/workspace),
`tools/test_sql_nsp_configuration.ps1` (A/B/C/D y helpers desactivados por defecto)
y `tools/test_sql_nsp_plan.ps1` (inspeccion de planes reales de este root).
Los planes iniciales usan state vacio e IDs SQL desconocidos; no `-refresh=false`.

Validacion de la integracion raiz (2026-10-10):
`terraform init -input=false`, `terraform validate`, `terraform fmt -check`
y fmt de los tfvars finalizaron correctamente. Planes autenticados mediante el
wrapper: A **19 altas**, C **20 altas**, demo original `300-advanced-network-manager`
**39 altas**, todos con cero cambios/bajas. Las comprobaciones de planes A/C
verifican IDs SQL y asociacion NSP desconocidos, sin password/Key Vault/identidad
SQL; la regresion 300 confirma helpers SQL/NSP desactivados y los tres modulos
CAF instalados exactamente en 5.0.0. Pasaron 9 regresiones PowerShell, 5 Bash y
5 comprobaciones de configuracion A/B/C/D/default. Ademas se ejecuto plan/apply
y T-SQL A/B/C/D con workspace exclusivo del root compartido.
Tras retirar FQDN, la primera lectura D aun devolvio filas; ARM confirmo Enforced
y solo la regla inbound. Una repeticion posterior fallo con 40197/25717:
esperar propagacion real, no prometer bloqueo instantaneo.
Azure devuelve `geo_backup_enabled=true` en Basic aunque CAF predetermina false;
se explicita true para evitar drift durante B/C/D, manteniendo backups Local.
AzureRM avisa de deprecacion
`public_network_access_enabled` dentro de CAF 5.0.0 (no error); la demo mantiene
el atributo realmente soportado por esa API CAF. No modificar el modulo descargado.

```powershell
# Desde raiz, despues de init; generar los planes con el wrapper como arriba.
.\tools\test_terraform_with_var_files.ps1
.\tools\test_sql_nsp_configuration.ps1
.\tools\test_sql_nsp_plan.ps1 -PlanFile A.local.tfplan -State A
.\tools\test_sql_nsp_plan.ps1 -PlanFile C.local.tfplan -State C
.\tools\test_caf5_network_manager_plan.ps1 -PlanFile network-manager.local.tfplan
```

Estos contratos de planes usan la IP/nombre de Storage documentales del ejemplo.
Tras personalizarlos, adaptar las expectativas locales; no publicar datos privados.

## Rollback y limpieza futura

Ensayo compartido cerrado: sesion/credencial SQL limpiadas a las 20:56:03 UTC.
Plan final revisado y aplicado: 19 objetos Terraform destruidos.
A las 21:03:17 UTC se comprobaron state vacio y RG inexistente.
NSPAccessLogs confirmo A y B; C/D no llegaron en la ultima consulta antes de
limpiar. No se afirma correlacion de logs C/D para este nuevo ensayo.

En laboratorio, volver a A tras revisar el plan. Limpiar T-SQL con
`ejecutar-sql.ps1 -Action Cleanup -Workspace sql-nsp-tour`.
Para destruccion, usar el mismo wrapper/var-files/workspace y
`-TerraformArguments @('-destroy','-out=destroy.local.tfplan')`, revisar y aplicar
ese plan; comprobar `terraform state list` vacio y RG inexistente antes de retirar
state. Destroy no revierte costes ni elimina necesariamente retencion soft-delete.

## Fuentes

- [NSP SQL (preview)](https://learn.microsoft.com/en-us/azure/azure-sql/database/network-security-perimeter?view=azuresql)
- [Extended Events: SAS/FQDN/identidad y errores NSP](https://learn.microsoft.com/en-us/azure/azure-sql/database/xevent-db-diff-from-svr?view=azuresql#network-security-perimeter-preview)
- [Credencial y archivo Extended Events](https://learn.microsoft.com/en-us/azure/azure-sql/database/xevent-code-event-file?view=azuresql)
- [SAS de delegacion de usuario](https://learn.microsoft.com/en-us/cli/azure/storage/container#az-storage-container-generate-sas)
- [CAF 5.0.0](https://registry.terraform.io/modules/aztfmodnew/caf/azurerm/5.0.0)
