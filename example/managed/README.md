

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1`
```json
{
  "title": "Purchases Processor",
  "uuid": 1,
  "metrics": {
    "local": {
      "input": 260,
      "output": 259,
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
      "uuid": "initialize",
      "metrics": {}
    },
    {
      "title": "warehouse",
      "uuid": "warehouse",
      "metrics": {}
    },
    {
      "title": "accounts",
      "uuid": "accounts",
      "metrics": {}
    },
    {
      "title": "despatch",
      "uuid": "despatch",
      "metrics": {}
    },
    {
      "title": "final ize",
      "uuid": "final ize",
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
      "id": "initialize",
      "metrics": {}
    },
    {
      "title": "warehouse",
      "id": "warehouse",
      "metrics": {}
    },
    {
      "title": "accounts",
      "id": "accounts",
      "metrics": {}
    },
    {
      "title": "despatch",
      "id": "despatch",
      "metrics": {}
    },
    {
      "title": "final ize",
      "id": "final ize",
      "metrics": {}
    }
  ]
}
```

`curl -ku username:password 'https://127.0.0.1:44444/v1/hubs/1/middlewares/finalize`
```json
{
  "title": "final ize",
  "uuid": "final ize",
  "metrics": {}
}
```