## Check SSL Expiry and send notify to Slack

<img src='ssl.png' />

- Create a Slack channel and get Webhook Incomming
- Fill your information into file: /etc/ssl-expiry-checker-slack.env in the following format: 

```
WEBHOOK=mywebhook
SLACK_CHANNEL=test
NOTIFICATION_DAYS=30
```
- Run script

> ./ssl-checker.sh linuxvn.info

### Reference
- Special thanks to [@andrew](https://stackoverflow.com/users/538507/andrew)
- https://stackoverflow.com/questions/21297853/how-to-determine-ssl-cert-expiration-date-from-a-pem-encoded-certificate
