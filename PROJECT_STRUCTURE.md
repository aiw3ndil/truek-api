# Estructura del Proyecto - Autenticación JWT + Google OAuth

## Archivos Principales Creados/Modificados

### Models
- `app/models/user.rb` - Modelo User con validaciones, has_secure_password y Google OAuth

### Controllers
- `app/controllers/api/v1/authentication_controller.rb` - Signup y Login tradicional
- `app/controllers/api/v1/google_auth_controller.rb` - Autenticación con Google OAuth ⭐ NUEVO
- `app/controllers/api/v1/users_controller.rb` - Gestión de perfil de usuario
- `app/controllers/concerns/authentication.rb` - Concern para autenticación JWT

### Services
- `app/services/json_web_token.rb` - Servicio para codificar/decodificar JWT
- `app/services/google_auth_service.rb` - Servicio para verificar tokens de Google ⭐ NUEVO

### Configuration
- `config/routes.rb` - Rutas de la API (incluye endpoint de Google)
- `config/initializers/cors.rb` - Configuración de CORS
- `Gemfile` - Dependencias añadidas (bcrypt, jwt, google-id-token, rack-cors, rspec, etc.)
- `.env.example` - Template para variables de entorno ⭐ NUEVO

### Database
- `db/migrate/XXXXXX_create_users.rb` - Migración para tabla users
- `db/migrate/XXXXXX_add_google_fields_to_users.rb` - Campos para Google OAuth ⭐ NUEVO

### Tests (RSpec)
- `spec/models/user_spec.rb` - Tests del modelo User (incluye Google OAuth)
- `spec/requests/api/v1/authentication_spec.rb` - Tests de signup/login
- `spec/requests/api/v1/google_auth_spec.rb` - Tests de Google OAuth ⭐ NUEVO
- `spec/requests/api/v1/users_spec.rb` - Tests de endpoints de usuario
- `spec/services/json_web_token_spec.rb` - Tests del servicio JWT
- `spec/factories/users.rb` - Factory para crear usuarios (incluye trait :google_user)
- `spec/support/request_helpers.rb` - Helpers para autenticación en tests
- `spec/rails_helper.rb` - Configuración de RSpec

### Documentation
- `API_AUTHENTICATION.md` - Documentación de API tradicional
- `GOOGLE_OAUTH_SETUP.md` - Documentación completa de Google OAuth ⭐ NUEVO
- `PROJECT_STRUCTURE.md` - Este archivo

## Gemas Añadidas

- `bcrypt` - Encriptación de passwords
- `jwt` - JSON Web Tokens
- `google-id-token` - Validación de tokens de Google ⭐ NUEVO
- `rack-cors` - CORS para API
- `rspec-rails` - Framework de testing
- `factory_bot_rails` - Factories para tests
- `faker` - Datos de prueba
- `shoulda-matchers` - Matchers para RSpec

## Endpoints Disponibles

```
POST   /api/v1/auth/signup    - Registro de usuario con email/password
POST   /api/v1/auth/login     - Login con email/password
POST   /api/v1/auth/google    - Autenticación con Google OAuth ⭐ NUEVO
GET    /api/v1/users/me       - Obtener perfil (requiere auth)
PUT    /api/v1/users/me       - Actualizar perfil (requiere auth)
```

## Tests

48 ejemplos, 0 fallos:
- 18 tests del modelo User (incluye Google OAuth)
- 10 tests de autenticación tradicional (signup/login)
- 7 tests de Google OAuth ⭐ NUEVO
- 8 tests de endpoints de usuario
- 5 tests del servicio JWT

## Características de Google OAuth

✅ Login con Google en un clic
✅ No requiere password para usuarios de Google
✅ Vinculación automática de cuentas existentes
✅ Foto de perfil desde Google
✅ Verificación de email por Google
✅ Tests completos con mocks

## Configuración Requerida

1. Obtener Google Client ID desde [Google Cloud Console](https://console.cloud.google.com/)
2. Crear archivo `.env` con `GOOGLE_CLIENT_ID=...`
3. Configurar frontend con librería de Google OAuth
4. Ver `GOOGLE_OAUTH_SETUP.md` para instrucciones detalladas

## Próximos Pasos Sugeridos

1. Agregar modelo Item para los objetos a intercambiar
2. Implementar CRUD de Items con asociación a User
3. Agregar imágenes con Active Storage
4. Implementar sistema de intercambios/ofertas
5. Agregar búsqueda y filtros
6. Implementar notificaciones
7. Agregar refresh tokens para mayor seguridad
8. Implementar logout en backend (token blacklist)
9. Agregar más providers OAuth (Facebook, Apple)
