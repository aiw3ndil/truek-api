# 🚀 Deploy en Coolify - Truek API

Guía completa para deployar la API de Truek en Coolify con base de datos PostgreSQL externa.

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Configuración en Coolify](#configuración-en-coolify)
3. [Variables de Entorno](#variables-de-entorno)
4. [Base de Datos PostgreSQL](#base-de-datos-postgresql)
5. [Deployment](#deployment)
6. [Post-Deployment](#post-deployment)
7. [Troubleshooting](#troubleshooting)

---

## 📦 Requisitos Previos

### ✅ Checklist

- [ ] Cuenta en Coolify configurada
- [ ] Base de datos PostgreSQL externa (Supabase, Neon, Railway, etc.)
- [ ] Dominio configurado (api.truek.xyz)
- [ ] Google Client ID obtenido
- [ ] Repositorio Git accesible

### 🗄️ Base de Datos PostgreSQL Externa

Puedes usar cualquiera de estos servicios:

- **Supabase** (Free tier disponible) - https://supabase.com
- **Neon** (Free tier disponible) - https://neon.tech
- **Railway** - https://railway.app
- **ElephantSQL** - https://www.elephantsql.com
- **Amazon RDS** - https://aws.amazon.com/rds/
- **Google Cloud SQL** - https://cloud.google.com/sql

---

## 🔧 Configuración en Coolify

### Paso 1: Crear Nueva Aplicación

1. **Login en Coolify**
   - Ve a tu instancia de Coolify
   - Click en "New Resource"

2. **Seleccionar Tipo**
   - Elige "Application"
   - Source: "Git Repository"

3. **Conectar Repositorio**
   ```
   Repository URL: https://github.com/tu-usuario/truek-api.git
   Branch: main (o production)
   ```

4. **Configuración Básica**
   ```
   Name: truek-api
   Description: Truek API - Backend
   Build Pack: Dockerfile
   Port: 3000
   ```

### Paso 2: Configurar Build

1. **Build Settings**
   ```
   Dockerfile Location: ./Dockerfile
   Build Command: (dejar vacío, usa Dockerfile)
   Start Command: (dejar vacío, usa Dockerfile CMD)
   ```

2. **Health Check** (Opcional pero recomendado)
   ```
   Path: /up
   Port: 3000
   Interval: 30s
   Timeout: 5s
   Retries: 3
   ```

### Paso 3: Configurar Dominio

1. **Domain Settings**
   ```
   Domain: api.truek.xyz
   HTTPS: Enabled (Let's Encrypt)
   Force HTTPS: Yes
   ```

2. **DNS Configuration**
   - Añade un registro A o CNAME apuntando a tu servidor Coolify
   ```
   Type: A
   Name: api
   Value: [IP de tu servidor Coolify]
   ```

---

## 🔐 Variables de Entorno

### Configurar en Coolify

Ve a: **Application → Environment Variables**

#### Variables Requeridas

```bash
# Rails
RAILS_ENV=production
RACK_ENV=production
RAILS_LOG_TO_STDOUT=true
SECRET_KEY_BASE=genera_con_rails_secret_abajo

# Database (PostgreSQL externa)
DATABASE_URL=postgresql://usuario:password@host:5432/truek_production

# Google OAuth
GOOGLE_CLIENT_ID=tu_google_client_id.apps.googleusercontent.com

# Server
PORT=3000
RAILS_SERVE_STATIC_FILES=true
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
```

#### Generar SECRET_KEY_BASE

En tu máquina local:

```bash
cd /Users/aiwen/code/truek-api
rails secret
```

Copia el output y úsalo como `SECRET_KEY_BASE`.

#### Formato de DATABASE_URL

**Formato general:**
```
postgresql://usuario:password@host:puerto/nombre_base_datos
```

**Ejemplos por proveedor:**

**Supabase:**
```
postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres
```

**Neon:**
```
postgresql://[user]:[password]@[endpoint-id].neon.tech/truek_production
```

**Railway:**
```
postgresql://postgres:[PASSWORD]@[HOST]:[PORT]/railway
```

#### Variables Opcionales

```bash
# Logging
RAILS_LOG_LEVEL=info

# CORS (ya configurado en código)
# CORS_ALLOWED_ORIGINS=https://truek.xyz,https://www.truek.xyz

# Redis (para futuro)
# REDIS_URL=redis://localhost:6379/0
```

### 📝 Copiar desde .env.production.example

Usa `.env.production.example` como referencia y completa los valores reales.

---

## 🗄️ Base de Datos PostgreSQL

### Opción A: Supabase (Recomendado - Free)

1. **Crear Proyecto**
   - Ve a https://supabase.com
   - Click "New Project"
   - Nombre: truek-production

2. **Obtener Connection String**
   - Ve a: Project Settings → Database
   - Copia "Connection string" (URI)
   - Formato: `postgresql://postgres:[PASSWORD]@...`

3. **Configurar en Coolify**
   ```bash
   DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT].supabase.co:5432/postgres
   ```

### Opción B: Neon (Recomendado - Free)

1. **Crear Proyecto**
   - Ve a https://neon.tech
   - Click "New Project"

2. **Obtener Connection String**
   - Copia la connection string de tu dashboard
   - Ya está en formato PostgreSQL

3. **Configurar en Coolify**
   ```bash
   DATABASE_URL=tu_connection_string_de_neon
   ```

### Opción C: Railway

1. **Crear Base de Datos**
   - Add New → Database → PostgreSQL

2. **Obtener Variables**
   - Click en PostgreSQL service
   - Ve a "Connect" tab
   - Usa "Database URL"

### Ejecutar Migraciones Iniciales

**Desde tu máquina local (una sola vez):**

```bash
# Configura la DATABASE_URL de producción temporalmente
export DATABASE_URL=postgresql://...tu_url...

# Ejecuta las migraciones
RAILS_ENV=production bundle exec rails db:migrate

# Opcional: Seed inicial
RAILS_ENV=production bundle exec rails db:seed
```

**O desde Coolify (después del deploy):**

```bash
# En Coolify, ve a Application → Execute Command
# Ejecuta:
rails db:migrate
```

---

## 🚀 Deployment

### Deploy Manual

1. **En Coolify**
   - Ve a tu aplicación
   - Click "Deploy"
   - Espera a que termine el build

2. **Verificar Logs**
   - Ve a "Logs" tab
   - Verifica que no haya errores
   - Busca: "Booting Puma"

### Deploy Automático (CI/CD)

1. **Configurar Webhook**
   - En Coolify: Application → Webhooks
   - Copia la Webhook URL

2. **Configurar en GitHub**
   - Repository Settings → Webhooks
   - Payload URL: [Webhook URL de Coolify]
   - Content type: `application/json`
   - Events: "Just the push event"

3. **Deploy Automático**
   - Cada push a `main` deployará automáticamente

---

## ✅ Post-Deployment

### Verificar Deployment

#### 1. Health Check

```bash
curl https://api.truek.xyz/up
# Expected: {"status":"ok"}
```

#### 2. Verificar CORS

```bash
curl -I https://api.truek.xyz/up \
  -H "Origin: https://truek.xyz"

# Debe incluir:
# Access-Control-Allow-Origin: https://truek.xyz
```

#### 3. Test Endpoint de Google OAuth

```bash
curl -X POST https://api.truek.xyz/api/v1/auth/google \
  -H "Content-Type: application/json" \
  -H "Origin: https://truek.xyz" \
  -d '{"token":"test"}'

# Debería devolver error pero con CORS headers correctos
```

#### 4. Verificar Base de Datos

En Coolify, ejecuta comando:

```bash
rails runner "puts User.count"
# Debería ejecutarse sin errores
```

### Monitoreo

#### Ver Logs en Tiempo Real

```bash
# En Coolify: Application → Logs → Tail
```

#### Logs Importantes

Busca estos mensajes:
```
✓ Database is up - continuing...
✓ Running database migrations...
✓ Booting Puma
✓ Listening on 0.0.0.0:3000
```

### Configurar Google Cloud Console

1. **Agregar Dominio Autorizado**
   ```
   Authorized JavaScript origins:
   - https://truek.xyz
   - https://www.truek.xyz
   
   Authorized redirect URIs:
   - https://truek.xyz/auth/callback
   - https://www.truek.xyz/auth/callback
   ```

2. **Verificar Client ID**
   - El mismo ID debe estar en `GOOGLE_CLIENT_ID` en Coolify

---

## 🔍 Troubleshooting

### Error: "Database connection failed"

**Causa:** DATABASE_URL incorrecta o base de datos no accesible.

**Solución:**
```bash
# Verificar DATABASE_URL
echo $DATABASE_URL

# Testar conexión
psql $DATABASE_URL -c "SELECT 1"

# Verificar que la base de datos permita conexiones externas
# (Supabase/Neon lo permiten por defecto)
```

### Error: "PG::ConnectionBad"

**Causa:** Firewall o IP no permitida.

**Solución:**
- En Supabase/Neon: Permite "All IPs" o la IP de tu servidor Coolify
- En Project Settings → Database → Connection pooling

### Error: "SECRET_KEY_BASE is missing"

**Causa:** Variable de entorno no configurada.

**Solución:**
```bash
# Genera una nueva
rails secret

# Añádela en Coolify Environment Variables
SECRET_KEY_BASE=el_secreto_generado
```

### Error: "Port 3000 already in use"

**Causa:** Puerto mal configurado en Coolify.

**Solución:**
- Ve a Application Settings
- Port mapping: 3000:3000
- Redeploy

### Logs no se ven

**Solución:**
```bash
# Asegúrate de tener esta variable:
RAILS_LOG_TO_STDOUT=true
```

### Migraciones no se ejecutan

**Solución 1:** Ejecutar manualmente

```bash
# En Coolify → Execute Command
rails db:migrate
```

**Solución 2:** Verificar bin/docker-entrypoint

```bash
# Debe tener permisos de ejecución
chmod +x bin/docker-entrypoint
git add bin/docker-entrypoint
git commit -m "Fix entrypoint permissions"
git push
```

### CORS no funciona

**Solución:**

1. Verificar que el dominio esté en `config/initializers/cors.rb`
2. Verificar que estés usando HTTPS en producción
3. Reiniciar la aplicación en Coolify

---

## 📊 Recursos y Límites

### Recursos Recomendados

**Para empezar (tráfico bajo/medio):**
```
CPU: 0.5 - 1 vCPU
RAM: 512MB - 1GB
Storage: 1GB
```

**Para producción (tráfico alto):**
```
CPU: 2 vCPU
RAM: 2GB
Storage: 5GB
```

### Auto-scaling

Coolify soporta auto-scaling. Configura en:
```
Application → Resources → Auto-scaling
Min instances: 1
Max instances: 3
```

---

## 🔄 Actualizar Aplicación

### Actualización Manual

```bash
# 1. Hacer cambios en el código
git add .
git commit -m "Update: descripción"
git push

# 2. En Coolify, click "Deploy"
```

### Rollback

```bash
# En Coolify → Deployments
# Click en un deployment anterior
# Click "Redeploy"
```

---

## 📝 Checklist Final

Antes de considerar el deployment completo:

- [ ] Aplicación responde en https://api.truek.xyz
- [ ] Health check `/up` retorna 200
- [ ] CORS funciona desde truek.xyz
- [ ] Base de datos conectada correctamente
- [ ] Migraciones ejecutadas
- [ ] Google OAuth configurado
- [ ] Logs se ven correctamente
- [ ] HTTPS funcionando
- [ ] Monitoring activo

---

## 🆘 Soporte

Si tienes problemas:

1. Revisa los logs en Coolify
2. Verifica las variables de entorno
3. Testa la conexión a la base de datos
4. Revisa la documentación de Coolify
5. Contacta el soporte de tu proveedor de base de datos

---

## 📚 Recursos Adicionales

- [Coolify Documentation](https://coolify.io/docs)
- [Rails Deployment Guide](https://guides.rubyonrails.org/deployment.html)
- [PostgreSQL Connection Strings](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)
- [Supabase Docs](https://supabase.com/docs)
- [Neon Docs](https://neon.tech/docs)

---

**¡Deployment exitoso!** 🎉

Tu API ahora está corriendo en producción con Coolify.
