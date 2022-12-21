#!/bin/bash

starttime=`date +%s`

#input parameter
subscription=$1
assignment_name="tagging-policy"

subscription_id="/subscriptions/"$subscription

#Register policy source
az provider register --namespace Microsioft.PolicyInsights

# policy name

policy_name=$(az policy definition list --query "[?displayName == 'Require a tag and its value on resources'].name" -o tsv)
echo "Policy name: ${policy_name}"


# Assign policy
tagValue = 'linhnt58'
tagName="{'createdBy': $tagValue}"

az policy assignment create --name $assignment_name --display-name $assignment_name --policy $policy_name --scope $subscription_id --params "$tagName"


# verify

az policy assignment list

finishtime=`date +%s`

duration=$(( $(($finishtime-$starttime)) % 3600 / 60  ))
echo "create $assignment_name in $duration"
