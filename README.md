俺API
=====

- https://ore-api.herokuapp.com
- https://github.com/shokai/ore-api


## Run

    % export APP_SECRET=your-app-secret
    % export CLIENT_ID=your-app-client-id
    % npm start

### debug run

    % DEBUG=* npm start


# Deploy

    % heroku create
    % git push heroku master

    % heroku config:set APP_SECRET=your-app-secret
    % heroku config:set CLIENT_ID=your-app-client-id
