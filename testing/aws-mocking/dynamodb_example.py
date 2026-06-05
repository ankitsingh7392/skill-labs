import json
from moto import mock_aws
import boto3
from pathlib import Path


@mock_aws
def seed_and_export():
    dynamodb = boto3.resource("dynamodb", region_name="eu-west-1")
    table = dynamodb.create_table(
        TableName="users",
        KeySchema=[{"AttributeName": "pk", "KeyType": "HASH"}],
        AttributeDefinitions=[{"AttributeName": "pk", "AttributeType": "S"}],
        BillingMode="PAY_PER_REQUEST",
    )

    table.put_item(Item={"pk": "u#1", "name": "Ankit"})
    table.put_item(Item={"pk": "u#2", "name": "Singh"})

    # scan and export
    items = table.scan()["Items"]
    Path("users.json").write_text(json.dumps(items, indent=2), encoding="utf-8")


seed_and_export()
