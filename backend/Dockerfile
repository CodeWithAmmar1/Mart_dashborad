# Use Node.js version 20
FROM node:20

# Create app directory
WORKDIR /usr/src/app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your server code
COPY . .

# Match the port your app listens on
EXPOSE 3000

# Start the server
CMD [ "node", "server.js" ]