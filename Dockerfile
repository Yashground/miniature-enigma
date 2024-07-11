# Stage 1: Build the app
FROM node:18-alpine AS builder
WORKDIR /app
ENV NODE_OPTIONS=--openssl-legacy-provider
COPY package.json package-lock.json ./
RUN npm ci
# echo Cleaning NPM cache...
#RUN npm cache clean --force
#echo Installing dependencies...
RUN npm ci --legacy-peer-deps
RUN npm list next
COPY . .
RUN npm run build
RUN npm ls -la out

# Stage 2: Serve the app
FROM nginx:alpine
COPY --from=builder /app/out /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
