FROM node:20.7.0

# create app directory in container
WORKDIR /news

# copy package.json and package-lock.json into the container
COPY ./package*.json ./

# install dependencies
RUN npm install

# copy rest of the source code into container
COPY ./ .

# Build the app
#RUN npm run build

# default port for app
EXPOSE 5173

# start the app
CMD ["npm", "run", "dev", "--", "--host"]
