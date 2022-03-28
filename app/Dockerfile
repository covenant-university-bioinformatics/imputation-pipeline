FROM node:16

ENV CI=true

WORKDIR /app

COPY package.json ./

RUN npm install

COPY ./ ./

#install R and packages
RUN apt update

RUN apt-get install -y r-base

#add bash
#RUN apk add --no-cache bash

#remove windows line endings
RUN apt-get install -y dos2unix
RUN dos2unix pipeline_scripts/distmix_v1.sh
RUN chmod 775 pipeline_scripts/distmix_v1.sh

RUN npm run build

#RUN adduser -D user
#USER user

CMD [ "npm", "run", "start:prod" ]
