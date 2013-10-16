

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
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/cache`
```json
{
  "purchases": 1212,
  "total": {
    "sales": 304468.3
  }
}
```
