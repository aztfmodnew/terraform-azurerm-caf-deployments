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

Codigo generado y validacion local no significan despliegue ni ensayo Azure.
SQL NSP sigue documentado como preview. Reconfirmar soporte antes del evento.

Validacion local realizada: init y validate del modulo raiz 5.0.0, fmt y seis
pruebas con providers mock (A/B/C/D y dos entradas invalidas). Tras separar la
referencia SQL en remote_objects, paso tambien el test de primer plan con el
ID de SQL desconocido: siete pruebas comprobadas en total, sin llamadas de datos
ni apply en Azure. Estas pruebas verifican configuracion y plan, no el bloqueo
real ni la ejecucion T-SQL. Antes del evento hay que ensayar los cuatro estados.

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

Terraform >= 1.8, Azure CLI autenticada, SSMS con SQLCMD o `sqlcmd` con soporte
de Entra, draw.io solo para editar el diagrama. Suscripcion autorizada, permisos
de creacion y asignacion de roles, proveedores Microsoft.Sql, Microsoft.Storage,
Microsoft.Network y Microsoft.OperationalInsights ya registrados. No se
auto-registran proveedores de toda la suscripcion.

Copiar [terraform.tfvars.example](terraform.tfvars.example) a
`terraform.tfvars` y sustituir todos los valores de ejemplo. El usuario/grupo
administrador de SQL debe ser de este tenant. Su IP publica debe ser estable.
El sufijo de Storage/SQL debe ser globalmente unico.

```powershell
terraform init -input=false
terraform workspace select -or-create sql-nsp-tour
terraform fmt -check
terraform validate
terraform test
terraform plan -out=local-A.tfplan -var='access_mode=Transition' -var='allow_blob_outbound=false'
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
terraform plan -out=local-next.tfplan -var='access_mode=Enforced' -var='allow_blob_outbound=false'
terraform apply local-next.tfplan
sqlcmd -S "tcp:$server,1433" -d demo -G -b -i '.\02-leer.sql'
```

En B/D, un error de lectura es esperado, pero **no todo error es NSP**.
Microsoft documenta errores 25759/25717 o incluso resultado vacio. Un resultado
vacio no es exito ni prueba concluyente: comparar con A/C, verificar blob
existente, vigencia SAS y correlacionar diagnósticos NSP. Fallo de login 42118
seria inbound y **no demostraria nuestra salida**; revisar IP /32.
No ampliar FQDN a `*.blob.core.windows.net` ni IP a `0.0.0.0/0`.

Los cambios de asociacion aparecen en Activity Log; evaluaciones en diagnosticos
NSP. Se habilita `allLogs`; comprobar categorias y tabla reales en la region.
No asumir un nombre de tabla ni prometer latencia. Registrar hora UTC, modo,
FQDN, salida de lectura saneada y motivo del evento. Ensayar A/B/C/D antes del
evento; no ejecutar el despliegue inicial en directo. Si se excede el tiempo,
usar el diagrama y expectativas, identificandolas como no ejecutadas.

## Rollback y limpieza

Rollback solo en laboratorio: aplicar Transition sin regla outbound tras
revisar el plan; reabre la salida permitida en Transition. No aplicarlo a otros
servidores. Limpiar credencial/event session con [03-limpiar.sql](03-limpiar.sql)
(requiere `BlobHost`). Revisar `terraform plan -destroy`, despues ejecutar
`terraform destroy` con confirmacion. Verificar RG eliminado y costes residuales.
No hay borrado ni despliegue realizado por el asistente.

## Fuentes verificadas

- [NSP para SQL Database (preview)](https://learn.microsoft.com/en-us/azure/azure-sql/database/network-security-perimeter?view=azuresql)
- [Extended Events: matriz NSP, SAS, FQDN y errores](https://learn.microsoft.com/en-us/azure/azure-sql/database/xevent-db-diff-from-svr?view=azuresql#network-security-perimeter-preview)
- [Crear credencial y archivo de eventos](https://learn.microsoft.com/en-us/azure/azure-sql/database/xevent-code-event-file?view=azuresql)
- [CLI: SAS de delegacion de usuario](https://learn.microsoft.com/en-us/cli/azure/storage/container#az-storage-container-generate-sas)
- [aztfmodnew CAF 5.0.0](https://registry.terraform.io/modules/aztfmodnew/caf/azurerm/5.0.0)
