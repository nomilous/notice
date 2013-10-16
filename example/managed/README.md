

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1`
```json
{
  "title": "Purchases Processor",
  "uuid": 1,
  "metrics": {
    "pipeline": {
      "input": {
        "count": 16
      },
      "processing": {
        "count": 4
      },
      "output": {
        "count": 9
      },
      "error": {
        "usr": 1,
        "sys": 0
      },
      "cancel": {
        "usr": 2,
        "sys": 0
      }
    },
    "capsules": "pending metrics per capsule definition"
  },
  "clients": "pending approach to deal with large numbers",
  "cache": {
    "purchases": {
      "largest": {
        "value": 6392.160000000001
      },
      "smallest": {
        "value": 86.22
      }
    }
  },
  "errors": {
    "recent": [
      {
        "timestamp": "2013-10-16T22:13:00.937Z",
        "error": "Error: darn",
        "middleware": {
          "title": "initialize",
          "type": "usr"
        }
      }
    ]
  },
  "middlewares": {
    "initialize": {
      "enabled": true,
      "metrics": {
        "pending": "metrics per middleware"
      }
    },
    "warehouse": {
      "enabled": true,
      "metrics": {
        "pending": "metrics per middleware"
      }
    },
    "accounts": {
      "enabled": true,
      "metrics": {
        "pending": "metrics per middleware"
      }
    },
    "despatch": {
      "enabled": true,
      "metrics": {
        "pending": "metrics per middleware"
      }
    },
    "finalize": {
      "enabled": true,
      "metrics": {
        "pending": "metrics per middleware"
      }
    }
  }
}
```

`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse/enable`
`curl -ku username:password https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse/disable`
* inprocess capsules only run through middlware that was enabled at the time thy entered the pipeline

```bash
curl -ku username:password -H 'Content-Type: text/javascript' --data '

fn = function(next, capsule, traversal) {
    console.log(capsule.all);
    next();
};

' 'https://127.0.0.1:44444/v1/hubs/1/middlewares/warehouse/replace'
```
