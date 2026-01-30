#!/bin/bash

# Deploy Script - Invite Landing Page
# Usage: ./deploy-invite.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Deploying Invite Landing Page${NC}"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI not found${NC}"
    echo "Install it with: npm install -g firebase-tools"
    exit 1
fi

# Check if logged in
if ! firebase projects:list &> /dev/null; then
    echo -e "${YELLOW}🔐 Please login to Firebase${NC}"
    firebase login
fi

# Step 1: Check if invite.html exists
if [ ! -f "web/invite.html" ]; then
    echo -e "${RED}❌ web/invite.html not found${NC}"
    exit 1
fi

# Step 2: Create index.html from invite.html
echo -e "${YELLOW}📄 Preparing landing page...${NC}"
cp web/invite.html web/index.html

# Step 3: Deploy to Firebase Hosting
echo -e "${YELLOW}🚀 Deploying to Firebase Hosting...${NC}"
firebase deploy --only hosting:invite

# Step 4: Get the URL
echo ""
echo -e "${GREEN}✅ Deploy completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Note the hosting URL shown above"
echo "2. Update the database with:"
echo "   UPDATE cc_settings SET value = 'https://YOUR_URL' WHERE setting_key = 'email_invite_link';"
echo "3. Update web/invite.html with App Store/Play Store URLs (lines 120-122)"
echo "4. Test by sending an invitation!"
echo ""
echo -e "${GREEN}🎉 Your invite landing page is live!${NC}"
