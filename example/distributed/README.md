#### Distributed Example

Requires coffee-script `npm install -g coffee-script`

#### terminal 1

```bash

./hub

   info  - socket.io started
listening @ https://0.0.0.0:3000


```

#### terminal 2

```bash

SECRET=right ./client
SECRET=wrong ./client

```