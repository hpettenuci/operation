#!/bin/bash

LAMBDA_NAME="webRequestMonit"
AWS_ACCOUNT="<aws cli profile>"
AWS_REGION="<aws region>"

mkdir package
pip3 install --target ./package -r ./requirements.txt

cd ./package
zip -r9 ../function.zip .

cd ..
zip -g function.zip *.py

aws lambda update-function-code --function-name $LAMBDA_NAME --zip-file fileb://function.zip --profile $AWS_ACCOUNT --region $AWS_REGION

rm -f function.zip
rm -rf package
