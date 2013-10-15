

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1`
```json
{
  "records": [
    {
      "title": "Managed Hub",
      "uuid": 1,
      "metrics": {
        "local": {
          "input": 0,
          "output": 0,
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
          "title": "middleware one",
          "metrics": {}
        },
        {
          "title": "middleware two",
          "metrics": {}
        },
        {
          "title": "middleware three",
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
      "title": "middleware one",
      "metrics": {}
    },
    {
      "title": "middleware two",
      "metrics": {}
    },
    {
      "title": "middleware three",
      "metrics": {}
    }
  ]
}

```

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/middleware%20one`
```json



```