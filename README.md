# Kural

- Name **Kural** is inspired from
  -  [Tirukkuṟaḷ](https://en.wikipedia.org/wiki/Kural) for its universality and secular nature 
  -  [curl](https://en.wikipedia.org/wiki/CURL) for its usefulness

![Kural Manuscript](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/Tirukkural_manuscript.jpg) 

## Utils for everyone!

# Topics
- [Install](#install)
- [Commands and Demos](#commands)
  - [sf:login](#sflogin)
  - [sf:data:query](#dataquery)
  - [sf:tooling:query](#toolingquery)
  - [sf:tooling:audit](#audit)
------
  - [browser:auto](#auto)
-----
  - [browser:pw:screenshot](#pw_screenshot)
-----
  - [dot2svg](#dot2svg)
  - [viz:dwg:mermaid](#mermaidEd)
  - [viz:uml:seq](#umlSeqEd)

------
  
  - [lighthouse](#lh)
-----
  - [Mobile test - browser:mobile ](#mobiletest)
----
  - [Perf test - browser:perfTest ](#perf)

----
  - [PMD Scan](#pmdscan)
  - [PMD New HTML report](#pmdscanHTML)

----
  - [Translate](#translate)
  - [Prepare for Translation](#prep_translate)
  - [STF2XML](#stf2xml)

----
  - [Data Viz - vega](#vega)
  - [Data Viz - chartjs](#chartjs)
----
  - [OCR](#ocr)
----
  - [CodeGen LWC](#codeGenLWC)





<a name='install'></a>
## Install
```
# linux and mac
sudo npm i -g kural
# windows
npm i -g kural

```
## Chrome Driver

- Download the [Chrome Driver file](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/browser/chromedriver) and put this in your PATH

-------

<a name='commands'></a>

# Commands and Demos

<a name='sflogin'></a>

## sf:login

```
kural sf:login -r sandbox|prod

# this depends on SFDX install, uses SFDX to login into the Salesforce org
# creates the auth json file, which can be used for other commands to login into the Salesforce org


```
<a name='lh'></a>
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



<a name='perf'></a>
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








```
$ cat 508_sfdc.json
```

```json
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

```

$ cat 508.json
```
```json
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

### Run 508 Demo
[![Run 508 Demo](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/508-1.webm.gif)](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/508-1.webm.gif)

### Run 508 Demo-2
[![Run 508 Demo-2](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/508-2.webm.gif)](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/508-2.webm.gif)



```
$ cat  optimizer.json 
```

```json
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
### Run Optimizer Demo
[![Run Optimizer Demo](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/run-Optimizer.webm.gif)](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/run-Optimizer.webm.gif)


<a name='mobiletest'></a>

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
 
<a name='dot2svg'></a>
## dot2svg 
- Generates SVG for a given dot file

```
kural viz:graphviz:dot2svg -i erd-1.dot -r dot -e y

# dot is default
# flag e opens up the editor
```

```
cat erd-1.dot
```

```
graph ER {
	node [shape=box]; course; institute; student;
	node [shape=ellipse]; {node [label="name"] name0; name1; name2;}
		code; grade; number;
	node [shape=diamond,style=filled,color=lightgrey]; "C-I"; "S-C"; "S-I";

	name0 -- course;
	code -- course;
	course -- "C-I" [label="n",len=1.00];
	"C-I" -- institute [label="1",len=1.00];
	institute -- name1;
	institute -- "S-I" [label="1",len=1.00];
	"S-I" -- student [label="n",len=1.00];
	student -- grade;
	student -- name2;
	student -- number;
	student -- "S-C" [label="m",len=1.00];
	"S-C" -- course [label="n",len=1.00];

	label = "\n\nEntity Relation Diagram";
	fontsize=20;
}
```

<a name='mermaidEd'></a>
##  Mermaid Drawing Editor 
- Opens up the Mermaid Drawing Editor with given input file content 

```
viz:dwg:mermaid -i gantt-1.dwg   -e y
# flag e opens up the editor
```

```
cat gantt-1.dwg
```

```
 gantt
    title Deployment Plan
    dateFormat  YYYY-MM-DD
    section ReleaseCalender
    Recieve   :a1, 2022-06-04, 2d
    Finalize     :a2, after a1  , 1d
    section Prepare For Release
    Prepare ORGs      :b1, after a2, 1d
    Run health checks :b2, after b1, 1d
    section  Pre-deployment steps
    Perform : c1, after b1, 2d
    section Communications
    Via DL and Slack:e1, after c1, 4d
    section  Pipeline
    Create Package: d1, after c1, 1d
    Validate Package: d2, after d1, 1d
    Deploy Package:d3, after d2,1d
    section  Post-deployment steps
    Perform : f3, after d3, 1d
```

 



<a name='umlSeqEd'></a>
##  UML Seq diagram editor
- Opens up the UML Seq Drawing Editor with given input file content 



```
viz:uml:seq -i farmer.seq.txt  -e y
# flag e opens up the editor
```

```
cat farmer.seq.txt
```

```
Title: Farmer and Nature
Nature->Rain:Rains
Rain->Land: Falls
Note right of Land: Thank you!
Land->Farmer:Start farming!
Farmer->Nature: Thanks you Lovely Nature!
Farmer->Nature: I am planting more trees!
```




<a name='dataquery'></a>
## sf:data:query
- SOQL query with auth file
```
kural sf:data:query -q accounts.soql -a mohan.chinnappan.n.sel_at_gmail.com.json

```

### Run data query
[![Run data query Demo](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/data_query.webm.gif)](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/data_query.webm.gif)

<a name='toolingquery'></a>
## sf:tooling:query
```
kural sf:tooling:query -q EntityParticle_s.sql -a mohan.chinnappan.n_ea2_at_gmail.com.json
```
### Example usage

```
cat EntityParticle_s.sql
```
```sql
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


<a name='audit'></a>
## kural sf:tooling:audit
```
kural sf:tooling:audit -s Account -a mohan.chinnappan.n_ea2_at_gmail.com.json 
```

### Demo of tooling audit
![Run tooling_audit-1](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/tooling_audit-1.webm.gif)

-----

<a name='auto'></a>
##  kural browser:auto 
```
# Run optimizer report with auth file

 kural browser:auto -r optimizer.json -a mohan.chinnappan.n.sel_at_gmail.com.json 
 ```
--------------
<a name='pmdscan'></a>
## Run PMD scan
- [Setup the PMD](https://github.com/mohan-chinnappan-n/cli-dx/blob/master/mdapi/pmd-codescan.md)

- Retrieve ApexClass or ApexTrigger

```
sfdx mohanc:mdapi:retrieve -u mohan.chinnappan.n_ea2@gmail.com -t "ApexClass"
sfdx mohanc:mdapi:checkRetrieveStatus -u mohan.chinnappan.n_ea2@gmail.com -i "09S3h0000073Hw7EAE"
unzip 09S3h0000073HzeEAE.zip


```

```
cat pmd-conf.json 
```
```json
{
   "label": "PMD Scan of Apex Classes",
   "pmdBinPath" :"/Users/mchinnappan/node-pmd/pmd-bin-6.47.0/bin/pmd-run.sh",
   "ruleSetFile": "/Users/mchinnappan/.pmd/apex_ruleset.xml",

   "sourcePath" :"/Users/mchinnappan/kural-demos/unpackaged/classes/",
   "outputFormat": "html",
   "outputFile" : "./pmd_results.html"

}


```

```
kural scanner:pmd:scan -r pmd-conf.json 
```

```
=== Command: /Users/mchinnappan/node-pmd/pmd-bin-6.47.0/bin/pmd-run.sh pmd -R /Users/mchinnappan/.pmd/apex_ruleset.xml -d /Users/mchinnappan/kural-demos/unpackaged/classes/ -f html > ./pmd_results.html  ===
=== Output will be written in ./pmd_results.html ===
=== Opening ./pmd_results.html ===
```

----

<a name='pmdscanHTML'></a>
## PMD Scan with new HTML report with charts


```
kural scanner:pmd:scan -r pmd-conf.json
```

```
cat pmd-conf.json 
```
```json
{
   "label": "PMD Scan of Apex Classes",
   "pmdBinPath" :"/Users/mchinnappan/node-pmd/pmd-bin-6.47.0/bin/pmd-run.sh",
   "ruleSetFile": "/Users/mchinnappan/.pmd/apex_ruleset.xml",

   "sourcePath" :"/Users/mchinnappan/kural-demos/unpackaged/classes/",
   "outputFormat": "xml",
   "outputFile" : "./pmd-results.xml"

}
```


```
kural data:transform:xslt -i pmd-results.xml -t pmd-report-v2.xslt > pmd-results.html
```
- [pmd-report-v2.xslt](https://raw.githubusercontent.com/mohan-chinnappan-n/pmd/master/pmd-core/etc/xslt/pmd-report-v2.xslt)

![HTML Report demo](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/new_pmd-report-1.gif)
----



<a name='translate'></a>
##  kural i18n:translate
- Translates a given sentence into various languages 
  and provides verification Google Translate URL (optionally) to verify the translation work
- Uses Google Translate

```
# Translate to French
 kural i18n:translate -i 'Good Morning, Friends!' -f 'en' -t fr
 Bonjour les amis!

# Translate to Tamil
kural i18n:translate -i 'Good Morning, Friends!' -f 'en' -t ta        
காலை வணக்கம் நண்பர்களே!

# Translate to Telugu
kural i18n:translate -i 'Good Morning, Friends!' -f 'en' -t te      
శుభోదయం మిత్రులారా!


# Translate to Marathi
kural i18n:translate -i 'Good Morning, Friends!' -f 'en' -t mr -g true
सुप्रभात, मित्रांनो!




# Translate to Japanese and launch google translate to verify the translation work
kural i18n:translate -i 'Good Morning, Friends!' -f 'en' -t ja -g true     
おはようございます、友達！

 ```
- Translation verification 
 ![en2ja-1](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/en2ja-1.png)

 - [Languages supported -  around 445](https://github.com/mohan-chinnappan-n/kural-docs/blob/master/src/locales.ts)


--------

<a name='prep_translate'></a>
## kural i18n:prepare 
- Prepares xml file for processing and optionally translate 

```
cat input.txt  
```
```                                  
Good Morning, Friends!
Today is a Wonderful day!
```

- Prepare without translation
```
kural i18n:prepare -i input.txt -f en -t  fr -x n
```
```xml
<Media type="AEP" stringCount="2">
	<String source="Good Morning, Friends!">Good Morning, Friends!</String>
	<String source="Today is a Wonderful day!">Today is a Wonderful day!</String>

</Media>
```
- Prepare with translation en-fr
```
kural i18n:prepare -i input.txt -f en -t  fr -x y
```
```xml
<Media type="AEP" stringCount="2">
	<String source="Good Morning, Friends!">Bonjour les amis!</String>
	<String source="Today is a Wonderful day!">Aujourd'hui est une merveilleuse journée!</String>

</Media>
```

- Prepare with translation en-ja
```
kural i18n:prepare -i input.txt -f en -t  ja  -x y
```
```xml
<Media type="AEP" stringCount="2">
	<String source="Good Morning, Friends!">おはようございます、友達！</String>
	<String source="Today is a Wonderful day!">今日は素晴らしい日です！</String>

</Media>
```
-----

<a name='stf2xml'></a>
## kural i18n:stf

-   Process Salesforce Translation File (STF) to xml
```
kural i18n:stf -i Bilingual_fr_2022-09-14\ 0105.stf  > Bilingual_fr_2022-09-14\ 0105.stf.xml
```

[Sample stf input](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/i18n/Bilingual_fr_2022-09-14-0105.stf)

[Sample xml output](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/i18n/Bilingual_fr_2022-09-14-0105.stf.xml)

![Demo](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/i18n/i18n-stf-xml-1.webm.gif)


-----

<a name='vega'></a>
## kural data:viz:vega
-   VegaLite chart for the given data

```
kural data:viz:vega -i field-usage.json

```

- [field-usage.json](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/field-usage.json)

- ![field-usage chart](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/img/field-usage-1.png)



-----
<a name='chartjs'></a>
## kural data:viz:chartjs
-   Chartjs chart for the given data

```
kural data:viz:chartjs -i barchart.json

```

```
cat barchart.json
```

```json
{
  "title": "Charts with Chartjs",
   "width": 400, "height":400,  
"type": "pie",
  "data": {
    "labels": [
      "Apples",
      "Mangos",
      "Pear",
      "Peach"
    ],
    "datasets": [
      {
        "label": "# of Friuts",
        "data": [
          12,
          19,
          3,
          5
        ],
    "backgroundColor": ["cyan", "skyblue", "steelblue", "#99ccff"]
      }
    ]
  },
  "options": {
    "scales": {
      "y": {
        "beginAtZero": false
      }
    }
  }
}

```
-----

<a name='ocr'></a>

```

# English page ocr 
kural ida:ocr -i  eng_bw.png -l eng


# Tamil page ocr
kural ida:ocr -i  tam.png -l tam

```

![eng_bw.png](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/ocr/eng_bw.png)
```
cat eng_bw.png.txt 
```
```
Mild Splendour of the various-vested Night!
Mother of wildly-working visions! haill
I watch thy gliding, while with watery light
Thy weak eye glimmers through a fleecy veil;
And when thou lovest thy pale orb to shroud
Behind the gather’d blackness lost on high;
And when thou dartest from the wind-rent cloud
Thy placid lightning o’er the awaken’d sky.
```

![eng_bw.png](https://raw.githubusercontent.com/mohan-chinnappan-n/kural-docs/master/ocr/tam.png)
```
```
cat tam.png.txt 
```

அகர முதல எழுத்தெல்லாம்‌ ஆதி
பகவன்‌ முதற்றே உலகு.
```



-----

<a name="codeGenLWC"></a>

## codegen:lwc
```
# generates lwc code for accounts.soql
kural codegen:lwc -i accounts.soql

```

``` 
cat accounts.soql
```

```sql

SELECT Id, Name, Industry 
FROM Account

```

<a name='pw_screenshot'></a>
## Screenshots of the given site

 ```
 kural browser:pw:screenshot -s https://github.com --help
USAGE
  $ kural kural browser:pw:screenshot -s

FLAGS
  -s, --site=<value>  (required) [default: https://www.salesforce.com] Site to run

DESCRIPTION
  Get screenshots for the given url in 3 browser types: chromium, firefox and webkit

EXAMPLES
  $ kural browser:pw:screenshot -s https://www.apple.com

~/playwright-book/img  >kural browser:pw:screenshot -s https://github.com --help
USAGE
  $ kural browser:pw:screenshot -s

FLAGS
  -s, --site=<value>  (required) [default: https://www.salesforce.com] Site to run

DESCRIPTION
  Get screenshots for the given url in 3 browser types: chromium, firefox and webkit

EXAMPLES
  $ kural browser:pw:screenshot -s https://www.apple.com
```

----


- Built by [Mohan Chinnappan](https://www.linkedin.com/in/mohan-chinnappan-232ab632/) with ♥
