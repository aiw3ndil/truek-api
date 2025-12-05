# 🚀 Quick Start - Google OAuth Backend

## Backend está listo ✅

El backend ya está 100% configurado con:
- ✅ Autenticación JWT
- ✅ Google OAuth integrado
- ✅ CORS configurado para truek.xyz y www.truek.xyz
- ✅ 48 tests pasando

## Para empezar AHORA:

### 1️⃣ Configura variable de entorno

Crea archivo `.env` en la raíz:

```bash
GOOGLE_CLIENT_ID=tu_google_client_id.apps.googleusercontent.com
```

### 2️⃣ Arranca el servidor

```bash
rails server
```

### 3️⃣ En el FRONTEND:

```bash
# Instala la librería
npm install @react-oauth/google

# Configura en tu App.jsx
import { GoogleOAuthProvider } from '@react-oauth/google';

<GoogleOAuthProvider clientId="TU_GOOGLE_CLIENT_ID">
  <App />
</GoogleOAuthProvider>

# Usa el componente de login
import { GoogleLogin } from '@react-oauth/google';

<GoogleLogin
  onSuccess={async (response) => {
    const res = await fetch('http://localhost:3000/api/v1/auth/google', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: response.credential })
    });
    const data = await res.json();
    localStorage.setItem('token', data.token);
    // ¡Listo! Usuario autenticado
  }}
/>
```

## 📚 Ver más ejemplos:

- **Frontend completo**: `FRONTEND_EXAMPLES.jsx`
- **Guía detallada**: `GOOGLE_OAUTH_SETUP.md`
- **API docs**: `API_AUTHENTICATION.md`

## 🔧 Obtener Google Client ID:

1. https://console.cloud.google.com/
2. Crear proyecto
3. APIs & Services > Credentials
4. Create OAuth 2.0 Client ID
5. Copiar Client ID

## 🧪 Tests:

```bash
bundle exec rspec  # 48 tests, 0 failures ✅
```

## 📡 Endpoint principal:

```
POST /api/v1/auth/google
Body: { "token": "google_token_aqui" }
Response: { "token": "jwt_token", "user": {...} }
```

¡Eso es todo! 🎉
