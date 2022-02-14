# Resource/function: api gateway/rest api

## Purpose
API pipeline setup for generating apis for reciving files and storing in S3.

## Description
Generates a default API for reciving files using PUT method, and storing to chosen folder in S3. The API generates an API_KEY required for autorization, and activates logging to CloudWatch for each invokation.

## Requires
The following input variables are required:
- project_name
- api_name
- env
- resource_tags
- iam_api_role_arn
    - an IAM role giving API Gateway permission to store files in S3.
    - must contain the following policy statements (these resources correspond to the usage example further down)
    ```json
    {
      sid = "AllowGetPutInS3Key"
      actions = ["s3:GetObject",
                 "s3:PutObject"]
      resources = ["arn:aws:s3:::test-reg-website-setup-dev/dbt/transformations/*"]
    },
    {
      sid = "AllowAPIGatewayInvoke"
      actions = ["execute-api:Invoke",
                 "execute-api:ManageConnections"]
      resources = ["arn:aws:execute-api:*:*:*"]
    }
    ```



## API Usage

The API is invoked using:
- {invoke_url}/{stage}/{bucket}/{folder}/{item}, where:
    - invoke_url : is a url looking like this `https://e8xhab03x0.execute-api.eu-west-1.amazonaws.com/`
    - stage : is the same as the api name in this implementation
    - bucket : name of the bucket to store file in
    - folder : folder structure to store file in
        - note that api expects one folder, several folders must be given by replacing the `/` with `%2F` (`some/folders` --> `some%2Ffolder`)
    - item : filename to use in S3 (does not need to be the same as source name)

- Authorization is required by sending an api key in the header:
    - x-api-key : key_value
        - the `key_value` is generated by API Gateway on API creation and can be found in the console, under API Gateway - API Keys

- The file to send is passed in the body. 

Below is an example of how uploading a file to S3 using python code:

```py
import requests

url = "https://e8xhab03x0.execute-api.eu-west-1.amazonaws.com/TEST_API_FILES_Module/test-reg-website-setup-dev/dbt%2Ftransformations/index.html"

payload=open("index2.html", 'rb')
headers = {
  'x-api-key': 'key_value',
  'Content-Type': 'text/html'
}

response = requests.request("PUT", url, headers=headers, data=payload)

print(response.text)
```


