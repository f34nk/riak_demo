FROM node:22-alpine AS build

WORKDIR /app
COPY package.json tsconfig.json ./
COPY src ./src
COPY generated ./generated
RUN npm install && npm run build && npm prune --omit=dev

FROM node:22-alpine

WORKDIR /app
COPY package.json ./
COPY --from=build /app/generated ./generated
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

CMD ["node", "dist/main.js"]
