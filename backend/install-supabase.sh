#!/bin/bash

# Install Supabase dependency
echo "Installing Supabase JavaScript client..."
npm install @supabase/supabase-js

# Remove Prisma dependency if you want (optional)
echo "Note: You may want to remove Prisma dependencies:"
echo "npm uninstall @prisma/client prisma"

echo "Supabase installation complete!"
echo ""
echo "Next steps:"
echo "1. Create your Supabase project at https://supabase.com"
echo "2. Run the SQL schema from supabase_schema.sql in your Supabase dashboard"
echo "3. Update your .env file with your Supabase credentials"
echo "4. Test the connection with: npm run dev"