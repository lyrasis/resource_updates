# resource-updates

Get list of uris for published resources updated / deleted since timestamp.

## Example

```bash
./archivesspace-cli request \
  --path=resource-updates \
  --params=modified_since=1493622000 | jq
```

Will return a json response like:

```json
{
  "deleted": [
    {
      "uri": "/repositories/2/resources/2"
    }
  ],
  "updated": [
    {
      "uri": "/repositories/2/resources/1",
    }
  ],
  "time": {
    "modified_since_time": "2017-05-01 00:00:00 -0700",
    "timestamp": 1493622000
  }
}
```

---