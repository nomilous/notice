

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1`
```json
{
  "records": [
    {
      "title": "Purchases Processor",
      "uuid": 1,
      "metrics": {
        "local": {
          "input": 9,
          "output": 9,
          "error": {
            "usr": 0,
            "sys": 0
          },
          "cancel": {
            "usr": 0,
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
          "metrics": {}
        },
        {
          "title": "warehouse",
          "metrics": {}
        },
        {
          "title": "accounts",
          "metrics": {}
        },
        {
          "title": "despatch",
          "metrics": {}
        },
        {
          "title": "finalize",
          "metrics": {}
        }
      ]
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
      "metrics": {}
    },
    {
      "title": "warehouse",
      "metrics": {}
    },
    {
      "title": "accounts",
      "metrics": {}
    },
    {
      "title": "despatch",
      "metrics": {}
    },
    {
      "title": "finalize",
      "metrics": {}
    }
  ]
}
```

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse`
```json



```