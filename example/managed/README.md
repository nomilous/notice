

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1`
```json
{
  "title": "Purchases Processor",
  "uuid": 1,
  "metrics": {
    "pipeline": {
      "input": {
        "count": 210
      },
      "processing": {
        "count": 0
      },
      "output": {
        "count": 209
      },
      "error": {
        "usr": 0,
        "sys": 0
      },
      "cancel": {
        "usr": 1,
        "sys": 0
      }
    }
  },
  "errors": {
    "recent": []
  },
  "cache": {
    "purchases": {
      "largest": {
        "value": 9819
      },
      "smallest": {
        "value": 22.42
      }
    }
  },
  "middlewares": [
    {
      "title": "initialize",
      "enabled": true,
      "metrics": {}
    },
    {
      "title": "warehouse",
      "enabled": true,
      "metrics": {}
    },
    {
      "title": "accounts",
      "enabled": true,
      "metrics": {}
    },
    {
      "title": "despatch",
      "enabled": true,
      "metrics": {}
    },
    {
      "title": "finalize",
      "enabled": true,
      "metrics": {}
    }
  ]
}
```

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares`
```json
{
  "records": [
    {
      "title": "initialize",
      "enabled": true,
      "metrics": {}
    },
    {
      "title": "warehouse",
      "enabled": true,
      "metrics": {}
    },
    {
      "title": "accounts",
      "enabled": true,
      "metrics": {}
    },
    {
      "title": "despatch",
      "enabled": true,
      "metrics": {}
    },
    {
      "title": "finalize",
      "enabled": true,
      "metrics": {}
    }
  ]
}
```

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse`
```json
{
  "title": "warehouse",
  "enabled": true,
  "metrics": {}
}
```

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse/enable`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse/disable`
```json
{
  "title": "warehouse",
  "enabled": false,
  "metrics": {}
}
```

```bash
curl -ku username:password -H 'Content-Type: text/javascript' --data '

fn = function(next, capsule, traversal) {
    console.log(capsule.all);
    next();
};

' 'https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse/replace'
```
