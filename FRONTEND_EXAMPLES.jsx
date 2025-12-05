// EJEMPLO DE INTEGRACIÓN EN REACT
// Archivo: src/components/GoogleLogin.jsx

import { GoogleLogin } from '@react-oauth/google';
import { useNavigate } from 'react-router-dom';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000';

function GoogleLoginButton() {
  const navigate = useNavigate();

  const handleGoogleSuccess = async (credentialResponse) => {
    try {
      const response = await fetch(`${API_URL}/api/v1/auth/google`, {
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
        // Guardar token JWT
        localStorage.setItem('authToken', data.token);
        
        // Guardar datos del usuario
        localStorage.setItem('user', JSON.stringify(data.user));
        
        console.log('Login exitoso:', data.user);
        
        // Redirigir al dashboard
        navigate('/dashboard');
      } else {
        console.error('Error de autenticación:', data.error);
        alert(`Error: ${data.error}`);
      }
    } catch (error) {
      console.error('Error de red:', error);
      alert('Error al conectar con el servidor');
    }
  };

  const handleGoogleError = () => {
    console.log('Login con Google falló');
    alert('No se pudo iniciar sesión con Google');
  };

  return (
    <div className="google-login-container">
      <GoogleLogin
        onSuccess={handleGoogleSuccess}
        onError={handleGoogleError}
        useOneTap
        theme="outline"
        size="large"
        text="continue_with"
        shape="rectangular"
      />
    </div>
  );
}

export default GoogleLoginButton;

// ============================================
// EJEMPLO DE CONFIGURACIÓN EN APP
// Archivo: src/App.jsx
// ============================================

import { GoogleOAuthProvider } from '@react-oauth/google';
import GoogleLoginButton from './components/GoogleLogin';

const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID;

function App() {
  return (
    <GoogleOAuthProvider clientId={GOOGLE_CLIENT_ID}>
      <div className="App">
        <h1>Truek - Intercambio de Objetos</h1>
        <GoogleLoginButton />
      </div>
    </GoogleOAuthProvider>
  );
}

export default App;

// ============================================
// EJEMPLO DE HOOK PERSONALIZADO
// Archivo: src/hooks/useAuth.js
// ============================================

import { useState, useEffect } from 'react';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000';

export function useAuth() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Cargar usuario desde localStorage
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    }
    setLoading(false);
  }, []);

  const login = async (email, password) => {
    try {
      const response = await fetch(`${API_URL}/api/v1/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password })
      });

      const data = await response.json();

      if (response.ok) {
        localStorage.setItem('authToken', data.token);
        localStorage.setItem('user', JSON.stringify(data.user));
        setUser(data.user);
        return { success: true };
      } else {
        return { success: false, error: data.error };
      }
    } catch (error) {
      return { success: false, error: 'Error de conexión' };
    }
  };

  const signup = async (name, email, password, passwordConfirmation) => {
    try {
      const response = await fetch(`${API_URL}/api/v1/auth/signup`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name,
          email,
          password,
          password_confirmation: passwordConfirmation
        })
      });

      const data = await response.json();

      if (response.ok) {
        localStorage.setItem('authToken', data.token);
        localStorage.setItem('user', JSON.stringify(data.user));
        setUser(data.user);
        return { success: true };
      } else {
        return { success: false, errors: data.errors };
      }
    } catch (error) {
      return { success: false, error: 'Error de conexión' };
    }
  };

  const logout = () => {
    localStorage.removeItem('authToken');
    localStorage.removeItem('user');
    setUser(null);
  };

  const getAuthHeaders = () => {
    const token = localStorage.getItem('authToken');
    return {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    };
  };

  const isAuthenticated = () => {
    return !!localStorage.getItem('authToken');
  };

  return {
    user,
    loading,
    login,
    signup,
    logout,
    getAuthHeaders,
    isAuthenticated
  };
}

// ============================================
// EJEMPLO DE PÁGINA DE LOGIN COMPLETA
// Archivo: src/pages/LoginPage.jsx
// ============================================

import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import GoogleLoginButton from '../components/GoogleLogin';

function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    const result = await login(email, password);

    if (result.success) {
      navigate('/dashboard');
    } else {
      setError(result.error);
    }

    setLoading(false);
  };

  return (
    <div className="login-page">
      <div className="login-container">
        <h1>Iniciar Sesión</h1>

        {error && (
          <div className="error-message">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input
              type="email"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              placeholder="tu@email.com"
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">Contraseña</label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              placeholder="••••••••"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="btn btn-primary"
          >
            {loading ? 'Iniciando sesión...' : 'Iniciar Sesión'}
          </button>
        </form>

        <div className="divider">
          <span>o</span>
        </div>

        <GoogleLoginButton />

        <p className="signup-link">
          ¿No tienes cuenta? <Link to="/signup">Regístrate aquí</Link>
        </p>
      </div>
    </div>
  );
}

export default LoginPage;

// ============================================
// EJEMPLO DE COMPONENTE PROTEGIDO
// Archivo: src/components/ProtectedRoute.jsx
// ============================================

import { Navigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

function ProtectedRoute({ children }) {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return <div>Cargando...</div>;
  }

  if (!isAuthenticated()) {
    return <Navigate to="/login" replace />;
  }

  return children;
}

export default ProtectedRoute;

// ============================================
// CONFIGURACIÓN DE VARIABLES DE ENTORNO
// Archivo: .env.local (en el frontend)
// ============================================

/*
VITE_API_URL=http://localhost:3000
VITE_GOOGLE_CLIENT_ID=tu_google_client_id.apps.googleusercontent.com
*/

// ============================================
// INSTALACIÓN DE DEPENDENCIAS
// ============================================

/*
npm install @react-oauth/google react-router-dom

o

yarn add @react-oauth/google react-router-dom
*/
