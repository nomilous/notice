

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/metrics`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/errors`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse`

* inprocess capsules only run through middleware that was enabled at the time they entered the pipeline
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse/enable`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse/disable`


`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/cache`
```json
{
  "purchases": 500
}
```
```bash

#
# update accounts middleware to accumulate total sales
#

curl -ku username:password -H 'Content-Type: text/coffee-script' --data '

fn = (next, capsule, {cache}) -> 

    cache.total ||= sales: 0
    cache.total.sales += (capsule.quantity * capsule.unit_price)
    next()

' 'https://127.0.0.1:44444/v1/hubs/1/middlewares/accounts/replace'

```
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/cache/total/sales`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/cache/total`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/cache`
```json
{
  "purchases": 1212,
  "total": {
    "sales": 304468.3
  }
}
```


```bash
#
# OOOPS
#
curl -ku username:password -H 'Content-Type: text/coffee-script' --data '
fn = (next, capsule, {cache}) ->  throw new Error "Broke Something!!"
' 'https://127.0.0.1:44444/v1/hubs/1/middlewares/accounts/replace'
```

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/errors`
```json
{
  "recent": [
    {
      "timestamp": "2013-10-16T23:56:59.912Z",
      "error": "Error: Broke Something!!",
      "middleware": {
        "title": "accounts",
        "type": "usr"
      }
    },
    {
      "timestamp": "2013-10-16T23:57:00.013Z",
      "error": "Error: Broke Something!!",
      "middleware": {
        "title": "accounts",
        "type": "usr"
      }
    }
  ]
}
```
