# Deploy Admin Panel

```bash
cd C:\Users\hp\Desktop\projet\soukna\admin

# Set production API URL
echo "VITE_API_URL=https://soukna.mr/api" > .env

# Build
npm run build

# Or via Docker
docker build -t soukna-admin .
docker run -p 80:80 soukna-admin
```

## Via Docker Compose (full stack)
```bash
cd C:\Users\hp\Desktop\projet\soukna
docker-compose up -d --build admin
```
