import boto3
from datetime import datetime, timezone

iam = boto3.client('iam')
sns = boto3.client('sns')

SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:168990580234:iam-access-key-rotation-alerter"

'''
Logic:
1. List all IAM users
2. Loop through all users
    3. For each user, list their access key
        4. Calculate the age of the key. Creation date minus today's date. 
        5. If the key is older than 90 days, append to a list
6. If the list has anything in it, notify through SNS
'''

# Lists users with access keys older than 90 days
def get_old_keys():
    users = iam.list_users()

    old_keys = []

    for user in users['Users']:
        username = user['UserName']
        access_keys = iam.list_access_keys(UserName=username)

        for key in access_keys['AccessKeyMetadata']:
            created_date = key['CreateDate']
            today = datetime.now(timezone.utc)

            age = today - created_date

            if age.days > 90:
                old_keys.append({
                    'username' : username,
                    'key_id' : key['AccessKeyId'],
                    'age_days' : age.days
                })
    return old_keys

# SNS alert for old access keys
def send_alert(old_keys):
    message = ""

    for key in old_keys:
        message += f"User: {key['username']} has an access key of age: {key['age_days']}. Please rotate access keys.\n"
        
    sns.publish(
        TopicArn = SNS_TOPIC_ARN,
        Subject = "IAM Access Key Rotation Required",
        Message = message
    )

def lambda_handler(event,context):
    old_keys = get_old_keys()

    if old_keys:
        send_alert(old_keys)