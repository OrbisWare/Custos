/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Main Menu
*/
local PANEL = {}

function PANEL:Init()
	self:SetSize(1024, 524)
	self:Center()
	self:MakePopup()
	self:SetAllowLua(true)
	self:SetScrollbars(false)
	self:SetVerticalScrollbarEnabled(false)
	self:SetHTML([[
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
	<script>
		function toTop() {
			$("html, body").animate({
				scrollTop: 0
			}, 600);
		}
		function caret() {
			return '<span class="caret"></span>'
		}
		$("#menu-toggle").click(function(e) {
			e.preventDefault();
			$("#wrapper").toggleClass("toggled");
		});
	</script>
	<style>
		.noselect {
			-webkit-touch-callout: none;
			-webkit-user-select: none;
			-khtml-user-select: none;
			-moz-user-select: none;
			-ms-user-select: none;
			user-select: none;
			cursor:default;
		}
		.form-control-inline {
				min-width: 0;
				width: auto;
				display: inline;
		}
		.affix {
			width: 809px;
		}
		::-webkit-scrollbar {
			display: none;
		}

		#wrapper {
			padding: 0;
		}
		#page-wrapper {
    		width: 100%;
    		padding: 0;
    		background-color: #fff;
		}
		@media(min-width:768px) {
			#wrapper {
				padding-left: 225px;
			}

			#page-wrapper {
				padding: 10px;
			}
		}
		.top-nav {
		    padding: 0 15px;
		}
		.top-nav>li {
		    display: inline-block;
		    float: left;
		}
		.top-nav>li>a {
		    padding-top: 15px;
		    padding-bottom: 15px;
		    line-height: 20px;
		    color: #999;
		}
		.top-nav>li>a:hover,
		.top-nav>li>a:focus,
		.top-nav>.open>a,
		.top-nav>.open>a:hover {
		    color: #fff;
		    background-color: #000;
		}
	
		@media(min-width:768px) {
		    .side-nav {
		        position: fixed;
		        top: 51px;
		        left: 225px;
		        width: 225px;
		        margin-left: -225px;
		        border-right: 1px solid #e7e7e7;
		        border-radius: 0;
		        overflow-y: auto;
		        background-color: #f8f8f8;
		        bottom: 0;
		        overflow-x: hidden;
		        padding-bottom: 40px;
		    }
		    .side-nav>li>a {
		        width: 225px;
		    }

		    .side-nav li a:hover,
		    .side-nav li a:focus {
		        outline: none;
		        background-color: #e7e7e7 !important;
		    }
		}
		.side-nav>li>ul {
		    padding: 0;
		}
		.side-nav>li>ul>li>a {
		    display: block;
		    padding: 10px 15px 10px 38px;
		    text-decoration: none;
		    color: #222;
		}
	</style>
</head>
<body>
	<div id="wrapper">
		<div class="navbar navbar-default navbar-fixed-top">
			<div align="right">
				<button type="button" class="close" aria-label="Close" align="right" onclick="console.log('RUNLUA: self:Remove()');">
					<span aria-hidden="true">&times;&nbsp;</span>
				</button>
			</div>
			<div class="navbar-header">
				<div class="navbar-brand" href="index.html">cu</div>
			</div>

			<div class="collapse navbar-collapse navbar-ex1-collapse">
				<ul class="nav navbar-nav side-nav">
					<li>
						<a href="#"><i class="glyphicon glyphicon-home"></i> Home</a>
					</li>
				</ul>
			</div>
		</div>

		<div id="page-wrapper">
			<div class="container-fluid">
				<br>
				<br>
				<br>
				<div class="row">
					<div class="col-lg-12">
						<h1 class="page-header">
							Dashboard <small>Statistics Overview</small>
						</h1>
					</div>
					<div class="col-lg-12">
						<div class="panel panel-primary">
							<div class="panel-heading">
								<h3 class="panel-title">PENIS</h3>
							</div>
							<div class="panel-body">
								Panel content
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>
]])
end
vgui.Register("CUMenu", PANEL, "DHTML")

concommand.Add("cu_menu", function()
	vgui.Create("CUMenu")
end)