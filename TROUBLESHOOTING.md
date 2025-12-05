# 🐛 Troubleshooting - Errores Comunes en Coolify

Soluciones a errores comunes durante el deployment en Coolify.

## 📋 Índice de Errores

1. [Error: psych gem installation failed](#error-psych-gem)
2. [Error: Database connection failed](#error-database-connection)
3. [Error: SECRET_KEY_BASE missing](#error-secret-key-base)
4. [Error: Port already in use](#error-port-in-use)
5. [Error: CORS blocked](#error-cors-blocked)
6. [Error: Build timeout](#error-build-timeout)
7. [Error: Out of memory](#error-out-of-memory)

---

## Error: psych gem

**Error completo:**
```
An error occurred while installing psych (5.2.6), and Bundler cannot continue.
```

**Causa:**
Falta la librería `libyaml` necesaria para compilar la gema psych.

**Solución:**
Ya está corregido en el Dockerfile actual. Si ves este error:

1. Verifica que tu Dockerfile incluya:
```dockerfile
# Build stage
RUN apt-get install --no-install-recommends -y \
    build-essential git libpq-dev pkg-config libyaml-dev

# Runtime stage  
RUN apt-get install --no-install-recommends -y \
    curl libpq5 libyaml-0-2
```

2. Commit y push:
```bash
git add Dockerfile
git commit -m "Fix: Add libyaml dependency"
git push
```

3. Redeploy en Coolify

---

## Error: Database connection

**Error:**
```
PG::ConnectionBad: could not connect to server
ActiveRecord::ConnectionNotEstablished
```

**Causas posibles:**

### 1. DATABASE_URL incorrecta

**Verificar formato:**
```bash
postgresql://usuario:password@host:5432/database
```

**En Coolify:**
- Ve a: Application → Environment Variables
- Verifica DATABASE_URL
- Sin espacios al principio/final
- Password sin caracteres especiales problemáticos

### 2. Firewall/IP bloqueada

**En Supabase:**
- Project Settings → Database → Connection Pooling
- Habilita "Allow all IPs" temporalmente
- O añade la IP de tu servidor Coolify

**En Neon:**
- Settings → IP Allow
- Añade 0.0.0.0/0 (todos) o IP específica

### 3. Database no existe

**Solución:**
```bash
# En Coolify → Execute Command
rails db:create
rails db:migrate
```

---

## Error: SECRET_KEY_BASE missing

**Error:**
```
ArgumentError: Missing `secret_key_base` for 'production' environment
```

**Solución:**

1. Genera una nueva clave:
```bash
rails secret
```

2. En Coolify:
   - Application → Environment Variables
   - Añade: `SECRET_KEY_BASE=la_clave_generada`

3. Redeploy

---

## Error: Port in use

**Error:**
```
Address already in use - bind(2) for "0.0.0.0" port 3000
```

**Solución:**

En Coolify:
1. Application → Settings
2. Verifica Port: 3000
3. Port mapping: 3000:3000
4. Redeploy

---

## Error: CORS blocked

**Error en navegador:**
```
Access to fetch at 'https://api.truek.xyz' from origin 'https://truek.xyz' 
has been blocked by CORS policy
```

**Causas y soluciones:**

### 1. HTTPS no configurado

**Verificar:**
- Coolify → Application → Domains
- HTTPS debe estar "Enabled"
- Force HTTPS: "Yes"

### 2. Dominio no en la lista

**Verificar config/initializers/cors.rb:**
```ruby
allow do
  origins 'https://www.truek.xyz', 
          'https://truek.xyz'
  # Tu dominio debe estar aquí
end
```

### 3. Reiniciar aplicación

```bash
# En Coolify
Application → Restart
```

---

## Error: Build timeout

**Error:**
```
Build timed out after 600 seconds
```

**Causas:**

1. Recursos insuficientes
2. Descarga lenta de dependencias
3. Red lenta

**Soluciones:**

### Aumentar timeout en Coolify

1. Application → Settings → Build
2. Build timeout: 900 (15 min)
3. Redeploy

### Optimizar Dockerfile

Ya está optimizado con:
- Multi-stage build
- Cache de layers
- Instalación limpia de paquetes

---

## Error: Out of memory

**Error:**
```
Killed
Container exited with code 137
```

**Causa:**
Memoria insuficiente (RAM).

**Soluciones:**

### 1. Aumentar recursos

En Coolify:
- Application → Resources
- Memory: Mínimo 512MB (recomendado 1GB)
- CPU: Mínimo 0.5 vCPU

### 2. Optimizar Gemfile

En `Gemfile`:
```ruby
# Excluir gemas de desarrollo en producción
gem "debug", group: [:development, :test]
gem "rspec-rails", group: [:development, :test]
```

Ya está configurado correctamente.

---

## Error: Migrations not running

**Síntoma:**
Base de datos no tiene las tablas necesarias.

**Solución manual:**

```bash
# En Coolify → Execute Command
rails db:migrate
```

**Verificar entrypoint:**

El archivo `bin/docker-entrypoint` debe tener:
```bash
if [ "${1}" == "./bin/rails" ] && [ "${2}" == "server" ]; then
  ./bin/rails db:prepare
fi
```

---

## Error: 502 Bad Gateway

**Causa:**
La aplicación no está escuchando correctamente.

**Verificar:**

### 1. Port binding

Dockerfile CMD debe ser:
```dockerfile
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
```

### 2. Variables de entorno

```bash
PORT=3000
RAILS_ENV=production
```

### 3. Logs

```bash
# En Coolify → Logs
# Buscar: "Booting Puma"
# Buscar: "Listening on 0.0.0.0:3000"
```

---

## Error: Assets not loading

**Síntoma:**
Falta CSS, JS o imágenes.

**Solución:**

Variable de entorno:
```bash
RAILS_SERVE_STATIC_FILES=true
```

Ya está configurado en `.env.production.example`.

---

## Error: SSL Certificate

**Error:**
```
SSL certificate problem: unable to get local issuer certificate
```

**Causa:**
Problema con Let's Encrypt o certificado.

**Solución:**

En Coolify:
1. Domain → SSL/TLS
2. Re-generate certificate
3. Wait 2-3 minutes
4. Test: `curl -I https://api.truek.xyz`

---

## Logs útiles

### Ver logs en tiempo real

```bash
# En Coolify
Application → Logs → Tail
```

### Buscar errores específicos

```bash
# Database errors
grep -i "database" log/production.log

# CORS errors  
grep -i "cors" log/production.log

# Authentication errors
grep -i "unauthorized" log/production.log
```

---

## Comandos útiles en Coolify

### Execute Command

```bash
# Ver versión de Ruby
ruby -v

# Ver versión de Rails
rails -v

# Count users
rails runner "puts User.count"

# Check database connection
rails runner "puts ActiveRecord::Base.connection.active?"

# Ver migraciones
rails db:migrate:status

# Rollback última migración
rails db:rollback

# Console (cuidado en producción)
rails console
```

---

## Verificación rápida

Ejecuta estos comandos para verificar que todo funciona:

```bash
# 1. Health check
curl https://api.truek.xyz/up
# Expected: {"status":"ok"}

# 2. CORS
curl -I https://api.truek.xyz/up -H "Origin: https://truek.xyz"
# Expected: Access-Control-Allow-Origin header

# 3. SSL
curl -I https://api.truek.xyz
# Expected: 200 OK with valid certificate

# 4. Database (en Coolify Execute Command)
rails runner "puts User.count"
# Expected: Number or 0
```

---

## Contacto y soporte

Si ninguna solución funciona:

1. **Revisa logs completos** en Coolify
2. **Verifica todas las variables** de entorno
3. **Test localmente** con docker-compose
4. **Consulta documentación**:
   - COOLIFY_DEPLOYMENT.md
   - COOLIFY_QUICKSTART.md

---

## Checklist de diagnóstico

Cuando algo falla, verifica en orden:

- [ ] Variables de entorno configuradas
- [ ] DATABASE_URL correcta y accesible
- [ ] SECRET_KEY_BASE configurado
- [ ] Dominio DNS apuntando correctamente
- [ ] HTTPS habilitado en Coolify
- [ ] Recursos suficientes (RAM/CPU)
- [ ] Logs sin errores críticos
- [ ] Health check responde
- [ ] Database conectada
- [ ] Migraciones ejecutadas

---

**Última actualización:** Diciembre 2024

Para más ayuda, consulta la documentación completa en `COOLIFY_DEPLOYMENT.md`.
