#!/bin/bash

# Deploy Script - Good Wishes Community App
# Usage: ./deploy.sh [environment]
# Environments: prod, staging

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default environment
ENV=${1:-prod}

echo -e "${GREEN}🚀 Good Wishes Community App - Deploy Script${NC}"
echo -e "${YELLOW}Environment: $ENV${NC}"
echo ""

# Step 1: Clean previous build
echo -e "${YELLOW}📦 Cleaning previous build...${NC}"
flutter clean
flutter pub get

# Step 2: Build for web
echo -e "${YELLOW}🔨 Building for web (release mode)...${NC}"
flutter build web --release --web-renderer canvaskit

# Step 3: Deploy to Firebase Hosting
if [ "$ENV" = "prod" ]; then
    echo -e "${YELLOW}🚀 Deploying to production...${NC}"
    firebase deploy --only hosting
elif [ "$ENV" = "staging" ]; then
    echo -e "${YELLOW}🚀 Deploying to staging...${NC}"
    firebase hosting:channel:deploy staging
else
    echo -e "${RED}❌ Invalid environment: $ENV${NC}"
    echo "Usage: ./deploy.sh [prod|staging]"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Deploy completed successfully!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Test the app at your Firebase Hosting URL"
echo "2. Update the invite link in the database:"
echo "   UPDATE cc_settings SET value = 'https://YOUR_DOMAIN/invite' WHERE setting_key = 'email_invite_link';"
echo "3. Send a test invitation"
