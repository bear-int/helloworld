FROM node:10

RUN mkdir -p /angular-intro
WORKDIR /angular-intro
COPY ./package.json ./package.json 
RUN npm install
RUN npm install -g @angular/cli@7.3.9
COPY ./ ./

EXPOSE 4200

CMD ng serve --host 0.0.0.0