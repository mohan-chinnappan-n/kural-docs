# Kural
![Kural Manuscript](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/Tirukkural_manuscript.jpg) 

## Utils for everyone!

## Install
```
# linux and mac
sudo npm -g kural
# windows
npm -g kural

```
## Chrome Driver

- Download the [Chrome Driver file](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/browser/chromedriver) and put this in your PATH

-------


# Command
## sf:login

```
kural sf:login -r sandbox|prod

# this depends on SFDX install, uses SFDX to login into the Salesforce org
# creates the auth json file, which can be used for other commands to login into the Salesforce org


```

## Lighthouse
- Run Lighthouse on a given site

```

# run lighthouse on a website
kural browser:lh -s https://www.apple.com


# run lighthouse on a salesforce org with given un/pwd
kural browser:sflh -r 508_sfdc.json

# run lighthouse on a salesforce org with authFile
kural browser:sflhp -r 508.json -a mohan.chinnappan.n.sel_at_gmail.com.json 

# run optimizer with authfile
kural browser:auto -r optimizer.json -a auth.json




```


### Mobile test
```
kural browser:mobile -r mobile_cfg.json

```
```
cat mobile_cfg.json 
```
```json
{
  "label": "Mobile Testing",
  "site": "https://mohan-chinnappan-n2.github.io/2021/wp/design/design.md.html#1",
  "outputFilename" : "design.png",

  "headless": false,
  "slowMo": 250,

  "device": "iPhone X"

}
```

- [![Mobile test demo](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/mobile-1.webm.gif)](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/mobile-1.webm.gif)
 


### Perf test
```

kural browser:perfTest -r perf_cfg.json 
```

```
cat perf_cfg.json 
```
```json
{
  "label": "Performance Testing",
  "maxConcurrency": 4,

  "sites": [
    { "url": "https://www.google.com"},
    { "url": "https://www.apple.com"},
    { "url": "https://www.salesforce.com"},
    { "url": "https:///mohan-chinnappan-n.github.io"},
    { "url": "https://www.wikipedia.org"}
   ]

}

```

### Perf test demo
[![Perf test demo](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/perfTest-1.webm.gif)](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/perfTest-1.webm.gif)


### Run data query
[![Run data query Demo](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/data_query.webm.gif)](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/data_query.webm.gif)


### Run 508 Demo
[![Run 508 Demo](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/508-1.webm.gif)](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/508-1.webm.gif)

### Run 508 Demo-2
[![Run 508 Demo-2](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/508-2.webm.gif)](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/508-2.webm.gif)


### Run Optimizer Demo
[![Run Optimizer Demo](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/run-Optimizer.webm.gif)](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/run-Optimizer.webm.gif)

$ cat 508_sfdc.json

```
{
            "testName": "508 - sfdc",
            "name": "login",
            "url": "https://login.salesforce.com",
            "port": 8041,
            "soMo": 50,
            "headless": false,
            "reportFilename": "sfdc_lh.html",

           "viewport": { "width": 1516, "height": 699 } ,
           "onlyCategories": ["accessibility", "best-practices", "performance", "pwa", "seo" ],

           "form": [
                {
                    "locator": "#username",
                    "value": "mohan.chinnappan.n.sel@gmail.com",
                    "action": "sendKeys"
                },
                {
                    "locator": "#password",
                    "value": "PWD",
                    "action": "sendKeys"
                },
                {
                    "locator": "#Login"
                }
           ]
}

```

$ cat 508.json
```
{
  "description": "Running 508 checks on Salesforce org page",
  "retURL" : "lightning/o/Account/list",
  "headless": false,

  "port": 8041,
  "slowMo": 50,


  "closeBrowser": true,
 "reportFilename": "sfdc_lh.html",

  "viewPort": { "width": 2040, "height": 699 },

  "onlyCategories": ["accessibility"]

}
```


$ cat  optimizer.json 

```
{
  "description": "Running Optimizer report",
  "retURL" : "lightning/o/OrgMetric/home",
  "headless": false,
  "closeBrowser": true,
  "viewPort": { "width": 2040, "height": 699 },
  "steps": [
    {  "label" : "Click Run Optimizer button",
      "xpath": "/html/body/div[4]/div[1]/section/div[1]/div[2]/div[2]/div[1]/div/div/div/div/div/runtime_platform_optimizer-org-metric-list-header/div/div[1]/div[2]/lightning-button/button",
       "op": "click"
    }
  ]

}
```

## Dot2SVG 
- Generates SVG for a given dot file

```
dot2svg -i input.dot -r [dot, circo, fdp, neato, osage, twopi]

# dot is default
```

## sf:data:query
- SOQL query with auth file
```
kural sf:data:query -q accounts.soql -a mohan.chinnappan.n.sel_at_gmail.com.json

```

## sf:tooling:query
```
kural sf:tooling:query -q EntityParticle_s.sql -a mohan.chinnappan.n_ea2_at_gmail.com.json
```
### Example usage

```
>cat EntityParticle_s.sql
SELECT
 Id
 ,DurableId
 ,QualifiedApiName
 ,EntityDefinitionId
 ,FieldDefinitionId
 ,NamespacePrefix
 ,DeveloperName
 ,InlineHelpText
 ,MasterLabel
 ,Label
 ,Length
 ,DataType
  FROM EntityParticle
 WHERE EntityDefinition.QualifiedApiName ='Account'

 ```

### Demo of tooling query

![Run tooling_query-1](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/tooling_query-1.webm.gif)


## kural sf:tooling:audit
```
kural sf:tooling:audit -s Account -a mohan.chinnappan.n_ea2_at_gmail.com.json 
```

### Demo of tooling audit
![Run tooling_audit-1](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/tooling_audit-1.webm.gif)

-----

##  kural browser:auto 
```
# Run optimizer report with auth file

 kural browser:auto -r optimizer.json -a mohan.chinnappan.n.sel_at_gmail.com.json 
 ```
--------------

- Built by [Mohan Chinnappan](https://www.linkedin.com/in/mohan-chinnappan-232ab632/) with ♥

