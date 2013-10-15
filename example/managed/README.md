

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1`
```json
{
  "records": [
    {
      "title": "Managed Hub",
      "uuid": 1,
      "metrics": {
        "local": {
          "input": 294,
          "output": 294,
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
          "title": "new line",
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
      "title": "new line",
      "metrics": {}
    }
  ]
}
```

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/middleware%20one`
```json



```