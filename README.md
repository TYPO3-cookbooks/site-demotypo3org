Description
===========

The introduction v4 demo


Content on landing page
========================

This HTML block is for the welcome page of the introduction package::

	<div id="gettingStarted">
	
	  <h1>This is the <em class="themeColorForeground">TYPO3 v4 Introduction Package</em> for testing purpose</h1>
	  <p>Feel free to explore and manipulate content and pages as the website gets automatically reset. Notice, though, that <strong>not all the functionalities are enabled</strong> for security reasons such as extension installation, files upload and updating the content of the home page.</p>
	  <p>To start editing the website, open the <a href="###BACKEND_URL###">Backend</a> and use "admin" and "password" as credential or pick another account as described in the login page.</p>
	  <p>
		 The next reset will happen in <span style="font-weight: bold; font-weight: 100%" id="javascript_countdown_time"></span>.
	  </p>
	  <p>
	  We also offer a demo of the <a href="http://government.v4.demo.typo3.org/home.html">TYPO3 Government Package</a> (German). The purpose is to demonstrate Frontend HTML5 and Accessibility features. Currently, it does <strong>not</strong> offer access to the Backend.
	  </p>
	
	  <h2>So - what's next ?</h2>
	  <p id="gettingStartedStepOne">Grab a cup of coffee and start browsing through this site to learn why TYPO3 is the most powerful open source content management system.</p>
	  <p id="gettingStartedStepTwo"><a href="###BACKEND_URL###" title="You can login as any of the backend users listed to the right." class="themeColorBackground startButton">Log into TYPO3</a></p>
	  <p id="gettingStartedStepFurtherReading"> -<a href="http://typo3.org/community/">Get involved!</a></p>
	</div>
	
	<script type="text/javascript">
	
	// @credit http://stuntsnippets.com/javascript-countdown/
	var javascript_countdown = function () {
	  var time_left = 10; //number of seconds for countdown
	  var output_element_id = 'javascript_countdown_time';
	  var keep_counting = 1;
	  var no_time_left_message = 'No time left for JavaScript countdown!';
	
	  function countdown() {
		if(time_left < 2) {
		  keep_counting = 0;
		}
	
		time_left = time_left - 1;
	  }
	
	  function add_leading_zero(n) {
		if(n.toString().length < 2) {
		  return '0' + n;
		} else {
		  return n;
		}
	  }
	
	  function format_output() {
		var hours, minutes, seconds;
		seconds = time_left % 60;
		minutes = Math.floor(time_left / 60) % 60;
		hours = Math.floor(time_left / 3600);
	
		seconds = add_leading_zero( seconds );
		minutes = add_leading_zero( minutes );
		hours = add_leading_zero( hours );
	
		return hours + ':' + minutes + ':' + seconds;
	  }
	
	  function show_time_left() {
		document.getElementById(output_element_id).innerHTML = format_output();//time_left;
	  }
	
	  function no_time_left() {
		document.getElementById(output_element_id).innerHTML = no_time_left_message;
	  }
	
	  return {
		count: function () {
		  countdown();
		  show_time_left();
		},
		timer: function () {
		  javascript_countdown.count();
	
		  if(keep_counting) {
			setTimeout("javascript_countdown.timer();", 1000);
		  } else {
			no_time_left();
		  }
		},
		//Kristian Messer requested recalculation of time that is left
		setTimeLeft: function (t) {
		  time_left = t;
		  if(keep_counting == 0) {
			javascript_countdown.timer();
		  }
		},
		init: function (t, element_id) {
		  time_left = t;
		  output_element_id = element_id;
		  javascript_countdown.timer();
		}
	  };
	}();
	
	// json-time.appspot.com is sometimes over-quota... use a home made solution
	$.get("/time.php", function(time) {
		var now = new Date(time);
		var hourInterval = 3
		var hour = (now.getHours() + 1) % hourInterval;
		var minute = now.getMinutes();
		var second = now.getSeconds();
		var timeSpent = hour * 3600 + minute * 60 + second;
		var timeLeft = (hourInterval * 3600) - timeSpent;
	
	  //time to countdown in seconds
	  javascript_countdown.init(timeLeft, 'javascript_countdown_time');
	});
	
	/*
	// http://james.padolsey.com/javascript/getting-the-real-time-in-javascript/
	function getTime(zone, success) {
		var url = 'http://json-time.appspot.com/time.json?tz=' + zone,
			ud = 'json' + (+new Date());
		window[ud]= function(o){
			success && success(new Date(o.datetime));
		};
		document.getElementsByTagName('head')[0].appendChild((function(){
			var s = document.createElement('script');
			s.type = 'text/javascript';
			s.src = url + '&callback=' + ud;
			return s;
		})());
	}
	
	getTime('Europe/Zurich', function(time){
	  //time to countdown in seconds
	  javascript_countdown.init(3600, 'javascript_countdown_time');
	});
	*/
	</script>

How do I login?
=================

	<div><p>Log in using one of the user names below with different levels of access:</p></div>
	<div><ul><li>admin</li><li>advanced_editor&nbsp;</li><li>simple_editor &nbsp;</li><li>news_editor&nbsp; </li></ul></div>


Limitation of the demo
=================

	<p>Notice <b>the editing of the home page has been disabled</b> for this demo website along with extension installation and files upload.</p>

Content on BE login page
=========================

::

  <p>Explore the different roles. Login with one of the following username from
  the&nbsp;table below:</p>

  <table summary="" style="margin-top: 10px">
  <tbody>
    <tr>
  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px solid black"><b>username</b></td>

  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px solid black"><b>password</b></td>

  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px solid black"><b>description</b></td>
    </tr>

    <tr>
  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black">admin</td>

  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black">password</td>

  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black">user with full access to the system</td>
    </tr>

    <tr>
  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black"><i>simple_editor</i></td>

  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black">password</td>

  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black">very limited access, ideal for basic editing</td>
    </tr>

    <tr>
  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black"><i>advanced_editor</i></td>

  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black">password</td>

  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black">more power, but still limited to exactly what an editor is
  	supposed to do</td>
    </tr>

    <tr>
  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black"><i>news_editor</i></td>

  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black">password</td>

  	<td rowspan="1" style="padding: 2px 5px 2px 0; border-bottom: 1px dotted black">editor that only has rights to edit and publish news</td>
    </tr>
  </tbody>
  </table>