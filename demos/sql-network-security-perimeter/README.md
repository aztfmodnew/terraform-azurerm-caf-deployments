# Demo: Azure SQL Database lee un archivo HTTPS y NSP decide la salida

## Resultado y limite

SQL Database lee un archivo de Extended Events (`.xel`) en un contenedor Blob
privado, **fuera del NSP**. A Transition (antes Learning): lectura permitida.
B Enforced sin regla outbound: lectura bloqueada. C Enforced con FQDN exacto:
lectura permitida. D retirada del FQDN: bloqueada.

Se elige este archivo, en lugar de una web arbitraria, porque Microsoft documenta
expresamente la evaluacion NSP de esta lectura saliente. No es un navegador, ni
una demostracion de exfiltracion generica. No se usa
`sp_invoke_external_rest_endpoint`: sus destinos estan restringidos y no se
presupone su cobertura NSP.

**Importante:** la credencial SQL usa un SAS de corta vida. Para Extended Events,
Microsoft documenta que la identidad administrada no necesita la regla FQDN en
este escenario: usarla invalidaria la prediccion de B. Storage no se asocia al
NSP y no se crea identidad administrada en SQL. Los datos son sinteticos.
El operador conecta por TDS con Entra ID y una regla inbound /32 permanente:
demostramos la **salida SQL -> Blob**, no un bloqueo de login.

**Ensayo Azure real: 2026-10-10, Spain Central.** Se ejecutaron plan/apply y
T-SQL en A/B/C/D: A y C devolvieron dos eventos; B y D mantuvieron el login
pero fallaron al leer Blob con error exterior 40197 e interno 25717.
NSPAccessLogs confirmo A Allowed/defaultPolicy, B Denied/DefaultDenyAll y
C Allowed/blob-outbound. El log de D no se habia ingerido en la ultima consulta:
su resultado SQL esta verificado, pero no se afirma correlacion de log para D.
Consultar [evidencia del ensayo](ensayo-azure.json) para tiempos y limpieza.
SQL NSP sigue documentado como preview; reconfirmar soporte y repetir el ensayo
antes del evento. El laboratorio destruido no constituye una demo desplegada.

Validacion local: init, validate, fmt y siete pruebas mock, incluyendo A/B/C/D,
entradas invalidas y primer plan con ID SQL desconocido. Se incorporan regresiones
para la traduccion API Learning y backups Local descubiertas en Azure.
Las pruebas mock verifican configuracion, no sustituyen el ensayo T-SQL.

## Infraestructura

- [Terraform](main.tf): RG, SQL logical server Entra-only, DB Basic, StorageV2
  LRS/Hot, contenedor privado, rol de datos para el operador, NSP y workspace.
- **Modulo raiz aztfmodnew CAF 5.0.0**, exactamente:

  ```hcl
  module "caf" {
    source  = "aztfmodnew/caf/azurerm"
    version = "5.0.0"
    # Entradas completas en main.tf.
  }
  ```

  Administra NSP, profile, asociacion al logical server y reglas inbound/outbound
  mediante su entrada `networking.network_security_perimeters`. Reutiliza el RG
  creado por el laboratorio. No se usan un submodulo directo ni una version 4.x.
  La asociacion usa `remote_objects.mssql_servers` para resolver el SQL externo
  por clave; el mapa de configuracion NSP mantiene claves conocidas incluso
  durante el primer plan, cuando el ID de SQL aun no existe.
- SQL y Storage usan AzureRM directamente. El submodulo SQL de esa version de
  CAF crea un secreto Key Vault incluso con Entra-only si no recibe password.
  Evitamos ese secreto innecesario; no pasamos passwords ficticias para sortearlo.
- No hay VNet, VM, Private Endpoint ni claves de Storage. La SAS de delegacion
  de usuario no entra en Terraform ni en su state.
- Storage tiene endpoint publico de red, **sin acceso anonimo**. Es deliberado
  para el destino externo de este laboratorio; no copiar a produccion.

## Precondiciones y despliegue (fuera de los nueve minutos)

Terraform >= 1.8, Azure CLI autenticada y PowerShell con System.Data.SqlClient
(runner probado localmente); alternativamente SSMS SQLCMD o `sqlcmd` con soporte
Entra. draw.io solo para editar el diagrama. Suscripcion autorizada, permisos
de creacion y asignacion de roles, proveedores Microsoft.Sql, Microsoft.Storage,
Microsoft.Network y Microsoft.OperationalInsights ya registrados. No se
auto-registran proveedores de toda la suscripcion.

Copiar [terraform.tfvars.example](terraform.tfvars.example) a
`terraform.tfvars` y sustituir todos los valores de ejemplo. El usuario/grupo
administrador de SQL debe ser de este tenant. Su IP publica debe ser estable.
El sufijo de Storage/SQL debe ser globalmente unico.

Elegir region explicitamente y consultar [comprobar-region.ps1](comprobar-region.ps1)
antes del plan. West Europe rechazo el aprovisionamiento SQL en la suscripcion
del ensayo; Spain Central lo permitio. La comprobacion de capacidades del servidor
no garantiza cuotas, SKU ni disponibilidad. Basic en Spain Central requirio
backups `Local` (incluidos en el codigo); no usar el valor Geo por defecto.
`Transition` se traduce a `Learning` para la API NSP 2023 usada por CAF 5.0.0;
`demo_state` muestra ambos nombres. No cambiar la variable publica a Learning.

```powershell
.\comprobar-region.ps1 -SubscriptionId '<suscripcion-autorizada>' -Location spaincentral
terraform init -input=false
terraform workspace select -or-create sql-nsp-tour
terraform fmt -check
terraform validate
terraform test
terraform plan '-out=local-A.tfplan' '-var=access_mode=Transition' '-var=allow_blob_outbound=false'
# Revisar suscripcion, costes y diff antes de aprobar:
terraform apply local-A.tfplan
```

Demo autocontenida: ejecutar estos comandos **desde este directorio**, no desde
la raiz del repositorio (cuyo wrapper usa otra version de CAF para otras demos).
Backend local explicito: state separado en el workspace `sql-nsp-tour`.
Para un equipo, configurar backend remoto aprobado antes del primer apply.
En Windows con rutas largas de Git, establecer solo para la terminal de init:

```powershell
$env:GIT_CONFIG_COUNT = '1'
$env:GIT_CONFIG_KEY_0 = 'core.longpaths'
$env:GIT_CONFIG_VALUE_0 = 'true'
```

No se modifica la configuracion global de Git.
Conservar el lock de providers. State y planes locales estan excluidos de Git,
pero contienen metadatos sensibles: protegerlos y no proyectarlos. No ejecutar
`apply` en produccion. Basic, Blob y Log Analytics tienen coste; cuota diaria
del workspace no es un limite financiero. Comprobar precios y Cost Management.

El principal que despliega recibe Storage Blob Data Contributor para emitir la
SAS de delegacion. Si la CLI usa otro principal, asignar el rol solo a ese
operador con autorizacion; no ampliar el acceso a toda la suscripcion.
Esperar propagacion RBAC. No eludir Azure Policy.

## Preparar la lectura

Ruta usada en el ensayo, sin instalar sqlcmd: [ejecutar-sql.ps1](ejecutar-sql.ps1)
obtiene token Entra, emite la SAS solo en Prepare y no imprime ni guarda secretos.
Read reutiliza la credencial y archivo existentes; un resultado sin filas sale
con codigo 2, no se presenta como exito.

```powershell
.\ejecutar-sql.ps1 -Action Prepare
.\ejecutar-sql.ps1 -Action Read
```

Alternativa SQLCMD:

En una terminal privada, sin transcripcion ni grabacion, obtener la SAS de
delegacion de usuario de dos horas. No imprimirla, pasarla en argumentos, subirla
al repo ni pegarla en diapositivas.

```powershell
$account = terraform output -raw storage_account_name
if ($LASTEXITCODE -ne 0) { throw 'No se pudo obtener Storage.' }
$env:BlobHost = terraform output -raw blob_host
if ($LASTEXITCODE -ne 0) { throw 'No se pudo obtener el host Blob.' }
$server = terraform output -raw sql_server_fqdn
if ($LASTEXITCODE -ne 0) { throw 'No se pudo obtener SQL.' }
$expiry = (Get-Date).ToUniversalTime().AddHours(2).ToString('yyyy-MM-ddTHH:mm:ssZ')
$start = (Get-Date).ToUniversalTime().AddMinutes(-5).ToString('yyyy-MM-ddTHH:mm:ssZ')
$env:ContainerSas = az storage container generate-sas --account-name $account --name events --permissions rwdl --start $start --expiry $expiry --https-only --auth-mode login --as-user --output tsv --only-show-errors
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($env:ContainerSas)) {
    Remove-Item Env:\ContainerSas -ErrorAction SilentlyContinue
    throw 'No se pudo emitir la SAS. Revisar identidad y propagacion del rol.'
}
try {
    sqlcmd -S "tcp:$server,1433" -d demo -G -b -i '.\01-preparar.sql'
    if ($LASTEXITCODE -ne 0) { throw 'Fallo preparando Extended Events.' }
} finally {
    Remove-Item Env:\ContainerSas
}
sqlcmd -S "tcp:$server,1433" -d demo -G -b -i '.\02-leer.sql'
if ($LASTEXITCODE -ne 0) { throw 'El baseline A no funciona. No continuar a B.' }
```

Las variables de entorno son variables SQLCMD; no usar `-e` (echo de consultas).
Elegir el flujo Entra de la version de sqlcmd instalada; `-G` no sustituye una
sesion/login interactivo requerido por el cliente. Alternativa: SSMS SQLCMD con
autenticacion Entra y sustitucion privada, sin guardar la SAS. Necesita CONTROL
en `demo` para crear la credencial. No usar `master`.

[01-preparar.sql](01-preparar.sql) crea credencial SAS, genera eventos sinteticos
y detiene la sesion. Debe ejecutarse **solo en A**, antes de proyectar. El mismo
archivo existente y la misma credencial se reutilizan en A/B/C/D. Confirmar
filas no vacias en A y que el SAS no expire durante la comparacion.

## Guion A/B/C/D

Mantener la IP inbound, login Entra, SAS, archivo y consulta constantes.
Revisar el plan de cada cambio; esperar a que la asociacion efectiva y reglas
coincidan en el portal. No prometer tiempos de propagacion.

| Estado | `access_mode` | `allow_blob_outbound` | Lectura esperada |
| --- | --- | --- | --- |
| A | Transition | false | Eventos no vacios |
| B | Enforced | false | Bloqueo NSP |
| C | Enforced | true | Mismos eventos |
| D | Enforced | false | Bloqueo de nuevo |

Para cada estado posterior:

```powershell
# B; para C cambiar false a true; D vuelve a false.
terraform plan '-out=local-next.tfplan' '-var=access_mode=Enforced' '-var=allow_blob_outbound=false'
terraform apply local-next.tfplan
.\ejecutar-sql.ps1 -Action Read
```

En B/D, un error de lectura es esperado, pero **no todo error es NSP**.
Microsoft documenta errores 25759/25717 o incluso resultado vacio. Un resultado
vacio no es exito ni prueba concluyente: comparar con A/C, verificar blob
existente, vigencia SAS y correlacionar diagnósticos NSP. Fallo de login 42118
seria inbound y **no demostraria nuestra salida**; revisar IP /32.
No ampliar FQDN a `*.blob.core.windows.net` ni IP a `0.0.0.0/0`.

Los cambios de asociacion aparecen en Activity Log; evaluaciones en diagnosticos
NSP. Se habilita `allLogs`; en el ensayo la tabla real fue `NSPAccessLogs`,
no `AzureDiagnostics`. [diagnosticos-query.json](diagnosticos-query.json) consulta
las columnas verificadas. Los archivos de [tablas](diagnosticos-tablas.json) y
[esquema](diagnosticos-schema.json) permiten comprobar el destino antes de filtrar.
No prometer latencia. Registrar hora UTC, modo,
FQDN, salida de lectura saneada y motivo del evento. Ensayar A/B/C/D antes del
evento; no ejecutar el despliegue inicial en directo. Si se excede el tiempo,
usar el diagrama y expectativas, identificandolas como no ejecutadas.

## Rollback y limpieza

Rollback solo en laboratorio: aplicar Transition sin regla outbound tras
revisar el plan; reabre la salida permitida en Transition. No aplicarlo a otros
servidores. Limpiar credencial/event session con [03-limpiar.sql](03-limpiar.sql)
(requiere `BlobHost`) o `.\ejecutar-sql.ps1 -Action Cleanup`.
Guardar y revisar el plan de destruccion antes de aplicarlo:

```powershell
terraform plan -destroy '-out=local-destroy.tfplan'
terraform apply local-destroy.tfplan
terraform state list
az group exists --name '<rg-exclusivo-del-laboratorio>'
```

Si se usa un var-file distinto de terraform.tfvars, pasarlo explicitamente
en **todos** los planes, incluido destroy. Verificar state vacio y RG inexistente;
no eliminar el state antes. Revisar Cost Management por cargos ya devengados:
destroy no revierte costes ni garantiza desaparicion de retencion soft-delete.

## Fuentes verificadas

- [NSP para SQL Database (preview)](https://learn.microsoft.com/en-us/azure/azure-sql/database/network-security-perimeter?view=azuresql)
- [Extended Events: matriz NSP, SAS, FQDN y errores](https://learn.microsoft.com/en-us/azure/azure-sql/database/xevent-db-diff-from-svr?view=azuresql#network-security-perimeter-preview)
- [Crear credencial y archivo de eventos](https://learn.microsoft.com/en-us/azure/azure-sql/database/xevent-code-event-file?view=azuresql)
- [CLI: SAS de delegacion de usuario](https://learn.microsoft.com/en-us/cli/azure/storage/container#az-storage-container-generate-sas)
- [aztfmodnew CAF 5.0.0](https://registry.terraform.io/modules/aztfmodnew/caf/azurerm/5.0.0)
