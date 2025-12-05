# Truek API - Google OAuth Integration

Documentación completa para la integración de Google OAuth en el backend de Truek API.

## 🔧 Configuración Inicial

### 1. Obtener Credenciales de Google

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la API de Google+ o Google Identity
4. Ve a "Credenciales" y crea un "OAuth 2.0 Client ID"
5. Configura las URLs autorizadas:
   - **JavaScript origins**: `http://localhost:3000`, `http://localhost:5173` (tu frontend)
   - **Redirect URIs**: URLs de tu aplicación frontend
6. Copia el **Client ID** que se genera

### 2. Configurar Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:

```bash
GOOGLE_CLIENT_ID=tu_google_client_id_aqui.apps.googleusercontent.com
```

**Nota**: NO subas este archivo a Git. Ya existe un `.env.example` como plantilla.

### 3. Instalar Dependencias

```bash
bundle install
rails db:migrate
```

## 📡 Endpoint de Google OAuth

### POST /api/v1/auth/google

Autentica un usuario usando Google OAuth. El frontend envía el token de Google y el backend lo verifica.

**Request:**

```json
{
  "token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjhlM..."
}
```

**Response exitoso (200 OK):**

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@gmail.com",
    "picture": "https://lh3.googleusercontent.com/...",
    "provider": "google",
    "created_at": "2024-12-05T19:57:00.000Z"
  }
}
```

**Errores:**

```json
// 400 Bad Request - Token no proporcionado
{
  "error": "Token is required"
}

// 401 Unauthorized - Token inválido
{
  "error": "Invalid Google token"
}

// 401 Unauthorized - Email no verificado
{
  "error": "Email not verified"
}
```

## 🎯 Modelo User Actualizado

### Nuevos Campos

- `google_id`: ID único del usuario en Google (único, opcional)
- `picture`: URL de la foto de perfil de Google
- `provider`: "email" o "google" (por defecto: "email")

### Características

- Los usuarios de Google **no requieren contraseña**
- Si un usuario se registra con email y luego usa Google OAuth con el mismo email, su cuenta se vincula automáticamente
- El email se normaliza a minúsculas automáticamente
- La foto de perfil se actualiza desde Google

## 💻 Integración Frontend

### Opción 1: @react-oauth/google (Recomendado)

```bash
npm install @react-oauth/google
```

**App.jsx:**

```javascript
import { GoogleOAuthProvider } from '@react-oauth/google';

function App() {
  return (
    <GoogleOAuthProvider clientId="TU_GOOGLE_CLIENT_ID">
      <YourApp />
    </GoogleOAuthProvider>
  );
}
```

**Login Component:**

```javascript
import { GoogleLogin } from '@react-oauth/google';

function LoginPage() {
  const handleGoogleSuccess = async (credentialResponse) => {
    try {
      const response = await fetch('http://localhost:3000/api/v1/auth/google', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          token: credentialResponse.credential
        })
      });

      const data = await response.json();
      
      if (response.ok) {
        // Guardar token JWT en localStorage
        localStorage.setItem('token', data.token);
        localStorage.setItem('user', JSON.stringify(data.user));
        
        // Redirigir al dashboard
        navigate('/dashboard');
      } else {
        console.error('Error:', data.error);
      }
    } catch (error) {
      console.error('Error:', error);
    }
  };

  return (
    <div>
      <h1>Login</h1>
      <GoogleLogin
        onSuccess={handleGoogleSuccess}
        onError={() => {
          console.log('Login Failed');
        }}
        useOneTap
      />
    </div>
  );
}
```

### Opción 2: Google Identity Services (Vanilla JS)

**index.html:**

```html
<script src="https://accounts.google.com/gsi/client" async defer></script>
```

**JavaScript:**

```javascript
function handleCredentialResponse(response) {
  fetch('http://localhost:3000/api/v1/auth/google', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      token: response.credential
    })
  })
  .then(res => res.json())
  .then(data => {
    if (data.token) {
      localStorage.setItem('token', data.token);
      localStorage.setItem('user', JSON.stringify(data.user));
      window.location.href = '/dashboard';
    }
  })
  .catch(error => console.error('Error:', error));
}

window.onload = function () {
  google.accounts.id.initialize({
    client_id: 'TU_GOOGLE_CLIENT_ID',
    callback: handleCredentialResponse
  });
  
  google.accounts.id.renderButton(
    document.getElementById('googleSignInButton'),
    { theme: 'outline', size: 'large' }
  );
  
  // Opcional: One Tap
  google.accounts.id.prompt();
};
```

**HTML:**

```html
<div id="googleSignInButton"></div>
```

## 🔐 Flujo de Autenticación

### Flujo Completo

1. **Frontend**: Usuario hace clic en "Sign in with Google"
2. **Google**: Muestra diálogo de autenticación
3. **Google**: Devuelve un token JWT (credential) al frontend
4. **Frontend**: Envía el token a `POST /api/v1/auth/google`
5. **Backend**: Verifica el token con Google
6. **Backend**: Crea o actualiza el usuario en la base de datos
7. **Backend**: Genera token JWT propio
8. **Backend**: Devuelve token JWT y datos del usuario
9. **Frontend**: Guarda el token JWT en localStorage
10. **Frontend**: Usa el token para requests autenticados

### Diagrama de Flujo

```
Frontend                 Google                  Backend
   |                       |                        |
   |--[Click Login]------->|                        |
   |                       |                        |
   |<--[Google Token]------|                        |
   |                                                |
   |----------[POST /auth/google + Token]--------->|
   |                                                |
   |                                    [Verify Token with Google]
   |                                    [Create/Update User]
   |                                    [Generate JWT]
   |                                                |
   |<----------[JWT + User Data]-------------------|
   |                                                |
   [Save JWT to localStorage]                      |
   |                                                |
   |-------[Authenticated Requests]--------------->|
         (Header: Authorization: Bearer JWT)
```

## 🧪 Testing

### Ejecutar Tests

```bash
bundle exec rspec
```

### Tests Incluidos

- ✅ Crear usuario nuevo desde Google
- ✅ Login de usuario existente con Google
- ✅ Vincular cuenta de email existente con Google
- ✅ Validación de token inválido
- ✅ Validación de email no verificado
- ✅ Validación de token faltante

## 🛡️ Seguridad

### Validaciones Implementadas

1. **Verificación del token**: El token se valida contra los servidores de Google
2. **Email verificado**: Solo se aceptan usuarios con email verificado en Google
3. **Client ID check**: El token debe ser emitido para tu Client ID específico
4. **Token expiration**: Los tokens de Google expiran automáticamente
5. **HTTPS en producción**: Asegúrate de usar HTTPS en producción

### Mejores Prácticas

- ✅ Nunca expongas tu `GOOGLE_CLIENT_ID` en código backend (usa variables de entorno)
- ✅ El `Client Secret` NO es necesario para esta implementación (solo Client ID)
- ✅ Configura dominios autorizados en Google Cloud Console
- ✅ En producción, restringe CORS a tu dominio específico
- ✅ Usa HTTPS en producción

## 🔄 Migración de Usuarios Existentes

Si ya tienes usuarios registrados con email/password:

1. El usuario inicia sesión con Google usando el mismo email
2. El backend detecta que ya existe un usuario con ese email
3. Se vincula automáticamente la cuenta de Google
4. El usuario ahora puede usar tanto email/password como Google OAuth

## 📊 Schema de Base de Datos

```ruby
create_table "users" do |t|
  t.string "email"                              # Email único
  t.string "name"                               # Nombre del usuario
  t.string "password_digest"                    # Hash del password (opcional para Google)
  t.string "google_id"                          # ID de Google (único)
  t.string "picture"                            # URL foto de perfil
  t.string "provider", default: "email"        # "email" o "google"
  t.datetime "created_at"
  t.datetime "updated_at"
  
  t.index ["email"], unique: true
  t.index ["google_id"], unique: true
end
```

## 🚀 Deployment

### Variables de Entorno en Producción

Configura estas variables en tu servicio de hosting (Heroku, Railway, etc.):

```bash
GOOGLE_CLIENT_ID=tu_client_id_de_produccion.apps.googleusercontent.com
RAILS_ENV=production
SECRET_KEY_BASE=tu_secret_key_base_de_produccion
```

### URLs Autorizadas en Google Cloud

Agrega tus dominios de producción:
- JavaScript origins: `https://tuapp.com`
- Redirect URIs: `https://tuapp.com/auth/callback`

## 📝 Endpoints Disponibles

```
POST   /api/v1/auth/signup      - Registro con email/password
POST   /api/v1/auth/login       - Login con email/password
POST   /api/v1/auth/google      - Autenticación con Google OAuth ⭐ NUEVO
GET    /api/v1/users/me         - Obtener perfil (requiere auth)
PUT    /api/v1/users/me         - Actualizar perfil (requiere auth)
```

## ❓ Troubleshooting

### "Invalid Google token"

- Verifica que `GOOGLE_CLIENT_ID` esté configurado correctamente
- Asegúrate de que el token no haya expirado
- Verifica que el Client ID del frontend coincida con el del backend

### "Email not verified"

- El usuario debe verificar su email en Google
- Esto es una medida de seguridad para evitar cuentas falsas

### CORS errors

- Verifica que tu frontend esté en la lista de orígenes permitidos en `config/initializers/cors.rb`
- En desarrollo, debería permitir `http://localhost:*`

## 📚 Recursos Adicionales

- [Google Identity Services](https://developers.google.com/identity/gsi/web/guides/overview)
- [@react-oauth/google](https://www.npmjs.com/package/@react-oauth/google)
- [Google Cloud Console](https://console.cloud.google.com/)
