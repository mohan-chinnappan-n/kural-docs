<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:scan="http://pmd.sourceforge.net/report/2.0.0"

  >

<xsl:template match="scan:pmd">
<!-- https://p2p.wrox.com/xslt/44076-ignoring-namespace-source-xml.html
     https://www.ibm.com/docs/en/i/7.1?topic=functions-example-using-xslt-remove-namespaces
 -->
  <html>
   <head>
   <link rel='stylesheet' type='text/css' href='https://cdn.datatables.net/1.12.1/css/jquery.dataTables.css'/>
   <link rel='stylesheet' type='text/css' href='https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css'/>

   <script src='https://code.jquery.com/jquery-3.6.1.min.js'></script> 
   <script type='text/javascript' charset='utf8' src='https://cdn.datatables.net/1.12.1/js/jquery.dataTables.js'></script>
   
   </head>
  <body>
 <nav class="nav navbar navbar-expand-md navbar-dark bg-dark fixed-top">

 
  <div class="container-fluid">
    <a class="navbar-brand" href="#">PMD Report</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
  
  </div>
</nav>
  <div class='container' style='margin-top:100px;'>
    <h3>Problems found</h3>
    <table id='pmdTable' class='table table-hover table-striped'>
    <thead>
 
      <tr>
        <th>File #</th>
        <th>Issue #</th>
        <th>File</th>
        <th>Line</th>
        <th>Priority</th>
        <th>Rule</th>
        <th>Problem</th>
   
      </tr>
      </thead>
      <xsl:for-each select="scan:file">

      <xsl:variable name="filename" select="@name" />
       <xsl:variable name="slno" select="position()" />


         <xsl:for-each select="scan:violation">
          <tr>
          <td><xsl:value-of select="$slno"/></td>
          <td><xsl:value-of select="position()"/></td>
          <td><xsl:value-of select="$filename"/> </td>
          <td><xsl:value-of select="@beginline"/></td>
          <td><xsl:value-of select="@priority"/></td>
          <td><xsl:value-of select="@ruleset"/></td>
          <td> <a href="{@externalInfoUrl}">Details</a></td>
          </tr>
          </xsl:for-each>
      </xsl:for-each>
    </table>
   </div>
    <script>$(document).ready( function () { $('#pmdTable').DataTable(); } );</script>

  </body>
  </html>
</xsl:template>

</xsl:stylesheet>
