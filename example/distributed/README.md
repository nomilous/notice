#### Distributed Example

Requires coffee-script `npm install -g coffee-script`

#### terminal 1

```bash
./hub

```

#### terminal 2

```bash

curl -k https://127.0.0.1:11111


```


#### terminal 3

```bash
NAME=Name1 NODE_SECRET=right ./client
NAME=Name1 NODE_SECRET=right ./client # rejected, already connected
NAME=Name2 NODE_SECRET=wrong ./client # rejected, wrong secret
```
