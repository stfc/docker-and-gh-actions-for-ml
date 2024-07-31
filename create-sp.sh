#!/bin/bash

# This script is used to create a service principal to allow workshop attendees to
# access the resources - it is not intended to be run by workshop attendees themselves
# but by the administrators of the course.

# This file must export the following variables:
# - tenant_id
# - subscription_id
# - resource_group
source ./azure.env

# TODO: Restrict scopes to only `/providers/Microsoft.Web/sites` and `/providers/Microsoft.Web/serverfarms`.
role="Contributor"
scopes="/subscriptions/$subscription_id/resourceGroups/$resource_group"
sp_name="supercharge-workshop"

set -x
az ad sp create-for-rbac --role="$role" --scopes="$scopes" --name="$sp_name"
