# 🚀 Quick Start - Coolify Deployment

Guía rápida para deployar Truek API en Coolify en 10 minutos.

## ⚡ Pasos Rápidos

### 1️⃣ Crear Base de Datos PostgreSQL (5 min)

**Opción A: Supabase (Recomendado)**
```bash
1. Ve a https://supabase.com
2. Click "New Project"
3. Nombre: truek-production
4. Genera password seguro
5. Copia el "Connection string"
   Format: postgresql://postgres:[PASSWORD]@db.[PROJECT].supabase.co:5432/postgres
```

**Opción B: Neon**
```bash
1. Ve a https://neon.tech
2. Click "New Project"
3. Copia la connection string del dashboard
```

### 2️⃣ Generar SECRET_KEY_BASE (1 min)

```bash
cd /Users/aiwen/code/truek-api
rails secret
# Copia el output
```

### 3️⃣ Configurar en Coolify (3 min)

**3.1 Crear Aplicación**
```
Coolify → New Resource → Application
- Source: Git Repository
- URL: https://github.com/tu-usuario/truek-api
- Branch: main
- Build Pack: Dockerfile
```

**3.2 Configurar Variables de Entorno**
```bash
# Mínimo requerido:
RAILS_ENV=production
SECRET_KEY_BASE=el_secreto_generado_en_paso_2
DATABASE_URL=postgresql://...de_paso_1...
GOOGLE_CLIENT_ID=tu_google_client_id.apps.googleusercontent.com
PORT=3000
RAILS_LOG_TO_STDOUT=true
```

**3.3 Configurar Dominio**
```
Domain: api.truek.xyz
HTTPS: Enabled
```

### 4️⃣ Deploy (1 min)

```bash
Click "Deploy" en Coolify
Espera 2-3 minutos
```

## ✅ Verificar Deployment

```bash
# Test 1: Health check
curl https://api.truek.xyz/up
# Expected: {"status":"ok"}

# Test 2: CORS
curl -I https://api.truek.xyz/up -H "Origin: https://truek.xyz"
# Expected: Access-Control-Allow-Origin header

# Test 3: Database
# En Coolify → Execute Command:
rails runner "puts User.count"
```

## 🔧 Variables de Entorno

Copiar y pegar en Coolify (reemplaza los valores):

```bash
RAILS_ENV=production
RACK_ENV=production
SECRET_KEY_BASE=genera_con_rails_secret
DATABASE_URL=postgresql://usuario:password@host:5432/database
GOOGLE_CLIENT_ID=tu_client_id.apps.googleusercontent.com
PORT=3000
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
```

## 📊 Resources Recomendados

```
CPU: 0.5 - 1 vCPU
RAM: 512MB - 1GB
Storage: 1GB
```

## 🐛 Troubleshooting Rápido

### Error: "Database connection failed"
```bash
# Verificar DATABASE_URL
# Formato: postgresql://user:pass@host:5432/db
# Verificar que la DB permita conexiones externas
```

### Error: "SECRET_KEY_BASE missing"
```bash
# Generar uno:
rails secret
# Añadirlo en Coolify Environment Variables
```

### Logs no aparecen
```bash
# Añadir:
RAILS_LOG_TO_STDOUT=true
```

## 📚 Documentación Completa

Ver [COOLIFY_DEPLOYMENT.md](COOLIFY_DEPLOYMENT.md) para:
- Configuración detallada
- Troubleshooting avanzado
- Optimizaciones
- Monitoring
- CI/CD

## 🆘 Ayuda Rápida

```bash
# Helper script
./scripts/deploy-helper.sh

# Verificar build local
docker build -t truek-api:test .

# Test con docker-compose
docker-compose up
```

## ✨ ¡Listo!

Tu API está en producción en: https://api.truek.xyz 🎉

**Próximos pasos:**
1. Configurar Google Cloud Console con tu dominio
2. Conectar tu frontend en truek.xyz
3. Monitorear logs y performance

---

**Tiempo total:** ~10 minutos

**Documentación completa:** [COOLIFY_DEPLOYMENT.md](COOLIFY_DEPLOYMENT.md)
