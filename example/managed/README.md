

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1`
```json
{
  "title": "Purchases Processor",
  "uuid": 1,
  "metrics": {
    "local": {
      "input": 4,
      "output": 3,
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

