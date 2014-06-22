俺API
=====

- https://ore-api.herokuapp.com
- https://github.com/shokai/ore-api


RUN
---

### create new Jawbone App

- https://jawbone.com/up/developer/
- get CLIENT_ID and APP_SECRET

### Run

    % export APP_SECRET=your-app-secret
    % export CLIENT_ID=your-app-client-id
    % npm start

### Debug

    % DEBUG=* npm start


DEPLOY
------

    % heroku create
    % git push heroku master

    % heroku config:set APP_SECRET=your-app-secret
    % heroku config:set CLIENT_ID=your-app-client-id
    % heroku config:set NODE_ENV=production
    % heroku config:add TZ=Asia/Tokyo


### enable MongoDB plug-in

    % heroku addons:add mongolab
    # or
    % heroku addons:add mongohq


### enable WebSocket

    % heroku labs:enable websockets
