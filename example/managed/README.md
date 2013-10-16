

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/metrics`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/errors`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse`

* inprocess capsules only run through middleware that was enabled at the time they entered the pipeline
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse/enable`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse/disable`


```bash
curl -ku username:password -H 'Content-Type: text/javascript' --data '

fn = function(next, capsule, traversal) {
    console.log(capsule.all);
    next();
};

' 'https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse/replace'
```
