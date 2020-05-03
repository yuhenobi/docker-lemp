# Simple Docker setup for PHP development

Run
````
make init
````

Edit .docker/.env file and run
````
make build-from-scratch && \
make up
````

When building will be done, add SSH key to your keychain
````
ssh-add .docker/backend/.ssh/id_docker
````

Connect to your backend container and install test compsoer requirements
````
ssh root@127.0.0.1 -p 2222 && \
cd /var/www/application && \
composer install
````

Enjoy!