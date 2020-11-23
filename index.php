!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<title>James Ho - Summary</title>
<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" type="text/css" href="css/mystyle.css" />
<style>
.container{
 margin: 0 20 0 20;
 width: 80%;
}
.content{
 padding: 0px;
 margin-left: 5px;
}
.content span{
 width: 250px;
}
.content span:hover{
 cursor: pointer;
}
li {
 list-style-type:circle;
}
ul {
 margin-left:20px;
}
p.sz10 {
 font-size:10px;
 padding-bottom:8px;
}
table.sz10 {
 font-size:10px;
 color:navy;
 border:1px solid grey;
}
th {
 border:1px solid grey;
}
td {
 border:1px solid grey;
}

</style>
<link href='/jquery/jquery-ui.css' rel='stylesheet' type='text/css'> 
<script type='text/javascript' src='/jquery/jquery-3.2.1.min.js'></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script type='text/javascript'>
$(function(){
  $('div.leftPane').load('navigate.php');
});
$( document ).ready(function() {
 $( ".content span" ).tooltip({
   track:true,
   open: function( event, ui ) {
   var skill = this.id;
 
   $.ajax({
    url:'fetch_details.php',
    type:'post',
    data:{skill:skill},
    success: function(response){
 
    // Setting content option
    $("#"+skill).tooltip('option','content',response);
   }
  });
    $(".ui-tooltip").css({"max-width":"700","font-size":"10px"}); 
  }

 });

 $(".content span").mouseout(function(){
   // re-initializing tooltip
   $(this).attr('title','Please wait...');
   $(this).tooltip();
   $('.ui-tooltip').hide();
 });


});
</script>
</head>

<body>

<h1>JAMES HO</h1>
	<div class="all">

 		<div class="leftPane" >
		</div>

		<div class="main">
<br />
			<h2> &nbsp; Summary</h2>
		<fieldset>
			<img class="mypic" src="images/jho_pic_100x125.gif" alt="james pic" />
			<p>I hold a Bachelor of Science degree in Computer Engineering graduating Magna Cum Laude from San Jose State University. 
I have 15+ years experience in the Information Technology (IT) field having worked a combined 7 years as a relational database and 
configuration database management system administrator for an EDA software company and a computer chip design company, 
1.5 years as a Customer Support Engineer for a mobile banking company, 1.5 years as an Application Engineer in document repository management 
in the Healthcare Industry, 2.5 years as a Programmer Analyst to migrate to a new Enterprise Pharmacy System (EPS), 8 months as a Unix developer, and 2+ years as a Technical Support Engineer with a focus on Unix shell scripting. 
<br /><br /><a href="https://www.linkedin.com/in/james-ho-b2a87a">LinkedIn Profile</a><br /></p>
			<p>During my work in the IT field, I have developed skills in the below disciplines.  To see a list of accomplishments for each specific area, hover over the item.
			</p>
			<div class='container'>

<form action="" method="POST">
			<ul>
				<li class="spaceA"><div class='content'><span title="Please wait ..." id="unix">Unix/Linux</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="nagios">Nagios XI monitoring</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="automation">Automation</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="shell_scripting">Shell programming</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="web_development">Web Development &nbsp; - &nbsp; </span><a href='web_development.html'>(see more info)</a></div></li>
				<li class="spaceA"><div class="content floatleft"><span title="Please wait ..." id="jenkins">Jenkins &nbsp; - &nbsp; </span><a href='jenkins_pipeline.html'>(see more info)</a></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="git">Git &nbsp; - &nbsp; </span><a href='github.html'>(see more info)</a></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="chef_inspec">Chef Inspec</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="expect_scripts">Expect scripts</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="sql">SQL</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="elixir">Elixir report tool</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="reporting">Cognos/Elixir/Crystal Report tools</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="rdbms">Relational database management systems (RDBMS)</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="cdms">Configuration database management/version control systems (CDMS) </span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="apache_web_server">Apache Web Server</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="crm">Customer Relations Management (CRM) administration</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="pgp">PGP</span></div></li>
                                <li class="spaceA"><div class="content"><span title="Please wait ..." id="html">HTML</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="css">CSS</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="jquery">jQuery</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="php">PHP</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="perl">PERL</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="cgi">CGI</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="javascript">Javascript</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="tomcat_web_server">Tomcat Web Server</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="etl">ETL</span></div></li>
				<li class="spaceA"><div class="content"><span title="Please wait ..." id="data_warehouse">Data Warehouse</span></div></li>
			</ul>
</form>
			</div>


<br /><br />

			
		</fieldset>
		</div>

	</div>
</body>

</html>
