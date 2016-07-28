# gitserver-http

> A git server with Nginx as the HTTP frontend

![gitweb](./assets/gitweb.png)


## Usage

 
  ```sh
  docker run \
    -d  \                               # deamonize
    -v `pwd`/repositories:/var/git \    # mount the volume
    -p "8080:80" \                      # expose the port 
    cirocosta/gitserver-http
  ```


## Example

Run the example:

  ```sh
  make example
  ```


This will create a git server http service on `:80`. Now you can clone the sample repository:


  ```sh
  git clone http://localhost/repos/myrepo.git
  ```

