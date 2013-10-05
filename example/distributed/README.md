#### Distributed Example

Requires coffee-script `npm install -g coffee-script`

#### terminal 1

```bash
./hub


```

#### terminal 2

```bash
NAME=name1 SECRET=right ./client
NAME=name1 SECRET=right ./client # rejected, already connected
NAME=name2 SECRET=wrong ./client # rejected, wrong secret
```
