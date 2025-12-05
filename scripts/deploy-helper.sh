#!/bin/bash

# Coolify Deployment Helper Script
# This script helps you prepare and verify your deployment

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║           Truek API - Coolify Deployment Helper              ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."
echo ""

# Check Docker
if command_exists docker; then
    echo -e "${GREEN}✓${NC} Docker is installed"
else
    echo -e "${RED}✗${NC} Docker is not installed"
    echo "  Install from: https://docs.docker.com/get-docker/"
fi

# Check PostgreSQL client (optional)
if command_exists psql; then
    echo -e "${GREEN}✓${NC} PostgreSQL client is installed"
else
    echo -e "${YELLOW}!${NC} PostgreSQL client not found (optional)"
fi

# Check if .env file exists
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} .env file exists"
else
    echo -e "${YELLOW}!${NC} .env file not found"
    echo "  Create one from: .env.production.example"
fi

echo ""
echo "─────────────────────────────────────────────────────────────"
echo ""

# Menu
PS3="Select an option: "
options=(
    "Generate SECRET_KEY_BASE"
    "Test Docker build locally"
    "Test with docker-compose"
    "Verify DATABASE_URL connection"
    "Run database migrations"
    "Show deployment checklist"
    "Exit"
)

select opt in "${options[@]}"
do
    case $opt in
        "Generate SECRET_KEY_BASE")
            echo ""
            echo "🔑 Generating SECRET_KEY_BASE..."
            echo ""
            if [ -f "bin/rails" ]; then
                rails secret
                echo ""
                echo -e "${GREEN}✓${NC} Copy this value to your Coolify environment variables"
            else
                echo -e "${RED}✗${NC} Rails not found. Run this in your Rails app directory."
            fi
            echo ""
            ;;
        "Test Docker build locally")
            echo ""
            echo "🐳 Building Docker image..."
            echo ""
            docker build -t truek-api:test .
            echo ""
            echo -e "${GREEN}✓${NC} Docker build successful!"
            echo ""
            echo "To run the container:"
            echo "  docker run -p 3000:3000 -e DATABASE_URL=postgresql://... truek-api:test"
            echo ""
            ;;
        "Test with docker-compose")
            echo ""
            echo "🐳 Starting services with docker-compose..."
            echo ""
            if [ -f "docker-compose.yml" ]; then
                docker-compose up --build
            else
                echo -e "${RED}✗${NC} docker-compose.yml not found"
            fi
            echo ""
            ;;
        "Verify DATABASE_URL connection")
            echo ""
            echo "🗄️  Testing database connection..."
            echo ""
            read -p "Enter your DATABASE_URL: " db_url
            
            if command_exists psql; then
                psql "$db_url" -c "SELECT version();" && \
                echo -e "${GREEN}✓${NC} Database connection successful!" || \
                echo -e "${RED}✗${NC} Database connection failed"
            else
                echo -e "${YELLOW}!${NC} psql not installed. Install PostgreSQL client to test connection."
            fi
            echo ""
            ;;
        "Run database migrations")
            echo ""
            echo "📊 Running database migrations..."
            echo ""
            read -p "Enter your DATABASE_URL: " db_url
            
            export DATABASE_URL="$db_url"
            export RAILS_ENV=production
            
            bundle exec rails db:migrate && \
            echo -e "${GREEN}✓${NC} Migrations completed!" || \
            echo -e "${RED}✗${NC} Migrations failed"
            echo ""
            ;;
        "Show deployment checklist")
            echo ""
            echo "✅ DEPLOYMENT CHECKLIST"
            echo "══════════════════════"
            echo ""
            echo "Pre-deployment:"
            echo "  [ ] PostgreSQL database created (Supabase/Neon/etc)"
            echo "  [ ] DATABASE_URL obtained"
            echo "  [ ] SECRET_KEY_BASE generated"
            echo "  [ ] GOOGLE_CLIENT_ID configured"
            echo "  [ ] Domain DNS configured (api.truek.xyz)"
            echo ""
            echo "In Coolify:"
            echo "  [ ] Application created"
            echo "  [ ] Git repository connected"
            echo "  [ ] Environment variables configured"
            echo "  [ ] Domain configured with HTTPS"
            echo "  [ ] Health check configured (/up)"
            echo ""
            echo "Post-deployment:"
            echo "  [ ] Health check passes (curl https://api.truek.xyz/up)"
            echo "  [ ] CORS works (test from truek.xyz)"
            echo "  [ ] Database migrations ran successfully"
            echo "  [ ] Google OAuth configured in Google Cloud Console"
            echo "  [ ] Logs showing no errors"
            echo ""
            echo "Documentation:"
            echo "  📄 COOLIFY_DEPLOYMENT.md - Full deployment guide"
            echo "  📄 .env.production.example - Environment variables template"
            echo ""
            ;;
        "Exit")
            echo ""
            echo "👋 Goodbye!"
            echo ""
            break
            ;;
        *) 
            echo "Invalid option $REPLY"
            ;;
    esac
done
