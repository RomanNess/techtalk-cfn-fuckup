# Code for my talk at cosee FuckupNight

## terraform
Creates VPC resources to automatically setup the starting position. 
The Terraform configuration also renders parameters for the Cloudformation stack.

## cfn
Cloudformation Stack that includes a RouteTableAssociation for a given RouteTable and Subnet.
* When the Stack is created it automatically imports the existing RouteTableAssociation. 
* When the Stack is deleted it also deletes RouteTableAssociation and the Subnet falls back to the MainRouteTable.