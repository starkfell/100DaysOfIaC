# Getting to Know ARM & JSON

In this installment, you're going to get to know core JSON and Azure Resource Manager (ARM) template concepts, which will help you in the rest of your Infrastructure-as-Code journey.

JSON is short for **JavaScript Object Notation**, and is a way to store information in an organized, easy-to-access manner. In short, it provides a human-readable collection of data that easily accessible.

## Why JSON

JSON has replaced XML as a de facto standard in deployment scenarios for several very good reasons:

- JSON is shorter
- JSON is quicker to read and write
- JSON can use arrays
- XML is much more difficult to parse than JSON.
- JSON is parsed into a ready-to-use JavaScript object

And ARM templates are written in JSON, so if you learn the basics of JSON syntax, ARM templates will be MUCH easier to interpret and author. 

> NOTE: ARM templates are key to Infrastructure-as-Code (IaC) because they are both *idempotent* and *declarative*, two highly desirable qualities in IaC and CI/CD. We'll unpack these important terms soon in future article.

In this installment, we'll dig into foundational concepts in JSON and ARM, including:

[Objects](#objects)<br />
[Arrays](#arrays)<br />
[Nesting Objects](#nesting-objects)<br />
[Parameters](#parameters)<br />
[Variables](#variables)<br />
[ARM Template Basics](#arm-template-basics)<br />
[Homework](#homework)<br />

<br />

## Objects

In JSON, an **object** is an instance of a real-life object

- It contains properties and values 
- One object is represented by **curly brackets{}**

Examples: In Azure RM template, examples of an object include a resource group, VM, storage account, APIM instance  

``` JSON
{
    "Name" : "Jack",
    "Age" : "25"
}
```

In the example above, "Name" is the property and "Jack" is the value. 

<br />

## Arrays

A collection of objects is an *array*. In JSON, an array is  represented by **square brackets[]**.

``` JSON
[
  {
      "Name" : "Jack",
      "Age" : "25"
  },
  {
      "Name" : "Jill",
      "Age" : "24"
  },
  {
      "Name" : "Johnny",
      "Age" : "30"
  }
]
```

<br />

## Nesting Objects

You can nest objects within other objects in JSON. For example, an address as an object (a physical place) can be nested within the definition of a user, as shown here:

``` JSON
{
    "Name" : "Jack",
    "Age" : "25",
    "Department" : "Finance",
    "Address" : {
                    "StreetNumber" : "1600",
                    "StreetName" : "Pennsylvania Ave NW",
                    "City" : "Washington",
                    "Country" : "USA"
                }
}
```

<br />

## Parameters

Parameters are values that perhaps we don't know at design time, and often cannot construct dynamically. Parameters are data that is captured from user and overridable at deploy time. A parameter may consist of a single value or an array of values.

Below is a sample parameters segment extracted from an ARM template that deploys an Azure VM.

``` JSON
{
"parameters": {
    "adminUsername": {
      "value": "GEN-USER"
    },
    "adminPassword": {
      "value": "GEN-PASSWORD"
    },
    "dnsLabelPrefix": {
      "value": "GEN-UNIQUE"
    }
  }
}
```

<br />

## Variables

Variables are values you need to use multiple times throughout a template, but are not supplied by the user, and often dynamically constructed at deploy time. 

A variable can be an consist of a single value or an array of values.

<br />

## ARM Template Basics

If we strip an ARM template down to it's most essential elements, a bare bones ARM template includes the following components at minimum:

``` JSON
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {},
  "variables": {},
  "resources": [ {}, {} ]
}
```

There are four optional, but useful elements we can tap into in ARM templates not shown above: **outputs**, **dependsOn**, **protectedsettings**, and **functions**. We will discuss these in "JSON and ARM - Part 2" sometime in the near future.

<br />

## Homework

If you have not mastered ARM, or find templates confusing, revisit the JSON concepts above until you recognize them on sight, and have committed them to memory. In Part 2, we'll dig into more advanced components, setting the stage for more powerful deployment examples later in the series.
