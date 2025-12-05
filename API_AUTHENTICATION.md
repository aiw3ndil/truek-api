# Truek API - Autenticación JWT

API REST para aplicación de intercambio gratuito de objetos con autenticación JWT.

## Configuración

### Requisitos
- Ruby 3.3.7
- Rails 7.1.5+
- SQLite3

### Instalación

```bash
bundle install
rails db:migrate
```

### Ejecutar Tests

```bash
bundle exec rspec
```

## Endpoints de Autenticación

### Registro de Usuario (Signup)

**POST** `/api/v1/auth/signup`

Crea un nuevo usuario y devuelve un token JWT.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2024-12-05T19:51:00.000Z"
  }
}
```

**Errores (422 Unprocessable Entity):**
```json
{
  "errors": [
    "Email can't be blank",
    "Password is too short (minimum is 6 characters)"
  ]
}
```

### Login de Usuario

**POST** `/api/v1/auth/login`

Autentica un usuario existente y devuelve un token JWT.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2024-12-05T19:51:00.000Z"
  }
}
```

**Errores (401 Unauthorized):**
```json
{
  "error": "Invalid email or password"
}
```

## Endpoints de Usuario (Requieren Autenticación)

Para todos estos endpoints, debes incluir el token JWT en el header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

### Obtener Perfil del Usuario Actual

**GET** `/api/v1/users/me`

Devuelve la información del usuario autenticado.

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2024-12-05T19:51:00.000Z"
}
```

**Error sin autenticación (401 Unauthorized):**
```json
{
  "error": "Unauthorized"
}
```

### Actualizar Perfil del Usuario

**PUT** `/api/v1/users/me`

Actualiza la información del usuario autenticado.

**Request Body (todos los campos son opcionales):**
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Jane Doe",
  "email": "jane@example.com",
  "updated_at": "2024-12-05T20:00:00.000Z"
}
```

**Errores (422 Unprocessable Entity):**
```json
{
  "errors": [
    "Email has already been taken"
  ]
}
```

## Modelo User

### Validaciones
- `email`: requerido, único (case-insensitive), formato válido
- `name`: requerido
- `password`: mínimo 6 caracteres (al crear o actualizar password)

### Características
- Password encriptado con `bcrypt`
- Email convertido a minúsculas automáticamente
- Token JWT con expiración de 24 horas

## Ejemplo de Uso desde Frontend

### JavaScript/Fetch

```javascript
// Registro
const signup = async () => {
  const response = await fetch('http://localhost:3000/api/v1/auth/signup', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      name: 'John Doe',
      email: 'john@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    })
  });
  
  const data = await response.json();
  // Guardar token en localStorage
  localStorage.setItem('token', data.token);
  return data;
};

// Login
const login = async () => {
  const response = await fetch('http://localhost:3000/api/v1/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      email: 'john@example.com',
      password: 'password123'
    })
  });
  
  const data = await response.json();
  localStorage.setItem('token', data.token);
  return data;
};

// Obtener perfil (requiere autenticación)
const getProfile = async () => {
  const token = localStorage.getItem('token');
  const response = await fetch('http://localhost:3000/api/v1/users/me', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return await response.json();
};

// Actualizar perfil
const updateProfile = async (updates) => {
  const token = localStorage.getItem('token');
  const response = await fetch('http://localhost:3000/api/v1/users/me', {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(updates)
  });
  
  return await response.json();
};
```

## CORS

CORS está configurado para aceptar requests de cualquier origen. En producción, configura origins específicos en `config/initializers/cors.rb`.

## Tests

Los tests incluyen:
- **Model specs**: Validaciones y callbacks del modelo User
- **Request specs**: Tests de integración para todos los endpoints
- **Service specs**: Tests para el servicio JsonWebToken
- **Factories**: FactoryBot para crear datos de prueba
- **Request helpers**: Helpers para autenticación en tests

Ejecutar todos los tests:
```bash
bundle exec rspec
```

Ejecutar tests específicos:
```bash
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/requests/api/v1/authentication_spec.rb
bundle exec rspec spec/requests/api/v1/users_spec.rb
```
