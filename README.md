# Truek API - Backend

API REST para aplicación de intercambio gratuito de objetos con autenticación JWT y Google OAuth.

## 🚀 Quick Start

```bash
# Instalar dependencias
bundle install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tu GOOGLE_CLIENT_ID

# Migrar base de datos
rails db:migrate

# Ejecutar tests
bundle exec rspec

# Iniciar servidor
rails server
```

## ✨ Características

- ✅ Autenticación JWT
- ✅ Google OAuth 2.0
- ✅ CORS configurado para truek.xyz
- ✅ 48 tests con RSpec
- ✅ API REST completa

## 📚 Documentación

| Archivo | Descripción |
|---------|-------------|
| [QUICK_START.md](QUICK_START.md) | Inicio rápido |
| [GOOGLE_OAUTH_SETUP.md](GOOGLE_OAUTH_SETUP.md) | Configuración de Google OAuth |
| [CORS_CONFIGURATION.md](CORS_CONFIGURATION.md) | Configuración de CORS |
| [API_AUTHENTICATION.md](API_AUTHENTICATION.md) | Endpoints de autenticación |
| [FRONTEND_EXAMPLES.jsx](FRONTEND_EXAMPLES.jsx) | Ejemplos de código React |
| [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) | Checklist de deployment |

## 🔑 Endpoints

```
POST /api/v1/auth/signup      # Registro
POST /api/v1/auth/login       # Login
POST /api/v1/auth/google      # Google OAuth
GET  /api/v1/users/me         # Perfil (requiere auth)
PUT  /api/v1/users/me         # Actualizar perfil
```

## 🧪 Tests

```bash
bundle exec rspec  # 48 examples, 0 failures
```

## 🌐 CORS

Configurado para:
- Producción: `truek.xyz` y `www.truek.xyz`
- Development: `localhost` (múltiples puertos)

Ver [CORS_CONFIGURATION.md](CORS_CONFIGURATION.md) para más detalles.

## 📦 Stack

- Ruby 3.3.7
- Rails 7.1.5+
- SQLite3 (development)
- RSpec + FactoryBot (testing)
- JWT + Google OAuth
- rack-cors

## 🚀 Deployment

### Coolify (Recomendado)

Esta aplicación está lista para deployar en Coolify con PostgreSQL externa.

**Quick Start (10 minutos):**
- Ver [COOLIFY_QUICKSTART.md](COOLIFY_QUICKSTART.md)

**Guía Completa:**
- Ver [COOLIFY_DEPLOYMENT.md](COOLIFY_DEPLOYMENT.md)

**Helper Script:**
```bash
./scripts/deploy-helper.sh
```

### Requisitos para Producción

- PostgreSQL externa (Supabase, Neon, Railway)
- Variables de entorno configuradas
- Dominio con HTTPS

Ver [.env.production.example](.env.production.example) para todas las variables necesarias.

## 📝 License

Truek © 2024
