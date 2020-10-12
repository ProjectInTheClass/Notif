'use strict';

const request = require('request');
const cheerio = require('cheerio');
const iconv = require('iconv-lite');
const mysql = require('mysql');
const xml2js = require('xml2js');
const AWS = require('aws-sdk');
AWS.config.update({region: 'ap-northeast-2'});

module.exports.crawler = (event, context, callback) => {
	var date = new Date();
	date.setTime(date.getTime() + (9 * 60 * 60 * 1000));
	var hour = date.getHours();
    hour = (hour < 10 ? "0" : "") + hour;

    var min  = date.getMinutes();
    min = (min < 10 ? "0" : "") + min;

    var year = date.getFullYear().toString().slice(2);

    var month = date.getMonth() + 1;
    month = (month < 10 ? "0" : "") + month;

    var day  = date.getDate();
	day = (day < 10 ? "0" : "") + day;
	
	var crawlingTime = year + "-" + month + "-" + day + " " + hour + ":" + min 

	dmLoop(1, 0);
	hyLoop(1, 1);
	// portalLoop();
	bsLoop(1);
	meLoop(1);
	csLoop(1, 'info_board');
	csLoop(1, 'job_board');

	function dmLoop(page, listIndex) {
		const dmList = ["enrolledstudent", "freshman", "addition", "direct_notice", "happy_notice", "rc_notice", "structure_safe_pds"];
		const url = "http://www.dormitory.hanyang.ac.kr/board/list";
		var sqlList = new Array();
		
		// if(page == 2) {
		//     if (listIndex == dmList.length - 1) return;
		//     dmLoop(1, listIndex+1);
		//     return;
		// }
	
		request.post({url:url, 
			form: {
				tb_name: dmList[listIndex],
				pageNum: page
			}},
			function (error, res, body) {
				console.log("dormitory ",dmList[listIndex] , page);
				const $ = cheerio.load(body);
				var rex = /javascript:goViewLink\(|\);/g;
				$("tbody").find("tr").each(function (index, elem) {
					var data = new Array();
					data.title = $(this).find("a").eq(0).text();
					data.url = "http://www.dormitory.hanyang.ac.kr/board/view?tb_name="+ dmList[listIndex] +"&idx=" + $(this).find('a').eq(0).attr('href').split(rex)[1];
					data.source = "학생생활관";
					data.category = (listIndex < 3 ? '모집안내' : '공지사항');
					// data.time = $(this).find(".listdate").eq(0).text().substring(2,10);
					data.time = crawlingTime
					data.json = "";
	
					// console.log(data);
					sqlList.push([data.title, data.url, data.source, data.category, data.time, data.json]);
				});
	
				if (sqlList.length == 0) {
					if (listIndex == dmList.length - 1) return;
					dmLoop(1, listIndex+1);
					return;
				}
	
				var connection = mysql.createConnection({
					host : 'noti.c0pwj79j83nj.ap-northeast-2.rds.amazonaws.com',
					user : 'admin',
					password: 'notinoti',
					port : 3306,
					database : 'noti'
				});
	
				connection.connect();
	
				var sql = 'INSERT IGNORE INTO Cards (title, url, source, category, time_, json_) VALUES ?;';
				connection.query(sql, [sqlList],function(err, rows, fields) {
					// connection.end();
					if(err) {
						console.log(err);
						if (listIndex == dmList.length - 1) return;
						dmLoop(1, listIndex+1);
						return;
					} else {
						console.log(rows);
						if (rows.affectedRows != 0) {
							var sql = 'SELECT endpointarn, badgeCount FROM PushNoti WHERE '+ (listIndex < 3 ? 'dmmjan' : 'dmgjsh') +' = 1';
								connection.query(sql, function(err, result, fields) {
									if (err) throw err;
									else {
										fnotification(result, rows, sqlList, connection);
										connection.end();
										dmLoop(page+1, listIndex);
									}
								});
						} else {
							connection.end();
							if (listIndex == dmList.length - 1) return;
							dmLoop(1, listIndex+1);
						}
					}
				});
			});
	}   

	function hyLoop(category, page) {
		const categories = ['', '학사', '입학', '모집/채용', '사회봉사', '일반','산학/연구', '행사', '장학', '학회/세미나'];
		const dbCategories = ['', 'hyhs', 'hyih', 'hymjcy', 'hyshbs', 'hyib', 'hyshyg', 'hyhs2', 'hyjh', 'hyhhsmn'];
		const url = 'https://www.hanyang.ac.kr/web/www/notice_all?p_p_id=viewNotice_WAR_noticeportlet&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=column-1&p_p_col_count=1&_viewNotice_WAR_noticeportlet_sCategoryId='+ category +'&_viewNotice_WAR_noticeportlet_sCurPage='+ page +'&_viewNotice_WAR_noticeportlet_action=view';
		request({url: url,encoding: null},
			function (error, res, body) {
				console.log('hanyang ',category, page);
				const $ = cheerio.load(iconv.decode(body, 'utf-8'));
				var rex = /view_message\(|\);/g;
				var sqlList = new Array();
				$('tbody').find('.title-info').each(function (index, elem) {
					var data = new Object();
					data.title = $(this).find('a').eq(0).text();
					data.url = 'https://www.hanyang.ac.kr/web/www/notice_all?p_p_id=viewNotice_WAR_noticeportlet&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=column-1&p_p_col_count=1&_viewNotice_WAR_noticeportlet_sCategoryId=1&_viewNotice_WAR_noticeportlet_sCurPage=1&_viewNotice_WAR_noticeportlet_sUserId=0&_viewNotice_WAR_noticeportlet_action=view_message&_viewNotice_WAR_noticeportlet_messageId=' + $(this).find('a').eq(0).attr('href').split(rex)[1]
					data.source = '한양대학교'
					data.category = categories[category];
					// data.time = $(this).find('.notice-date').eq(0).text().trim().replace(/\./gi, '-').substring(2,10)
					data.time = crawlingTime;
					data.json = '';
					
					// console.log(data)
					sqlList.push([data.title, data.url, data.source, data.category, data.time, data.json]);
				});
	
				var connection = mysql.createConnection({
					host : 'noti.c0pwj79j83nj.ap-northeast-2.rds.amazonaws.com',
					user : 'admin',
					password: 'notinoti',
					port : 3306,
					database : 'noti'
				});
	
				var sql = 'INSERT IGNORE INTO Cards (title, url, source, category, time_, json_) VALUES ?;';
				connection.query(sql, [sqlList],function(err, rows, fields) {
					// connection.end();
					if(err) {
						console.log(err);
					} else {
						console.log(rows);
						if (rows.changedRows != 10){
							var sql = 'SELECT endpointarn, badgeCount FROM PushNoti WHERE ' +dbCategories[category]+' = 1';
							connection.query(sql, function(err, result, fields) {
								if (err) throw err;
								else {
									notification(result, rows, sqlList, connection);
									connection.end();
									hyLoop(category, page+1);
								}
							});
						} else {
							connection.end();
							if (category == 9) return;
							hyLoop(category+1, 1);
						}
						
					}
				});
			});
	}

	function meLoop(pagenum) {
		const url = 'http://me.hanyang.ac.kr/ko/cmnt/mann/views/findCmntList.do';
		request.post({url: url,
			headers: {
				'Host': 'me.hanyang.ac.kr',
				'Connection': 'keep-alive',
				'Content-Length': '36',
				'Cache-Control': 'max-age=0',
				'Upgrade-Insecure-Requests': '1',
				'Origin': 'http://me.hanyang.ac.kr',
				'Content-Type': 'application/x-www-form-urlencoded',
				'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36',
				'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
				'Referer': 'http://me.hanyang.ac.kr/ko/cmnt/mann/views/findCmntList.do',
				'Accept-Encoding': 'gzip, deflate',
				'Accept-Language': 'ko-KR,ko;q=0.9,en;q=0.8,ja;q=0.7',
			},
			form: {
				'page': pagenum,
				'catCd': '',
				'searchType': '',
				'searchVal': ''
				}
			}, 
			function(error, res, body) {
				console.log('mePage' + pagenum);
				const $ = cheerio.load(body);
	
				var sqlList = new Array();
	
				$('tbody').find('tr').each(function (index, elem) {
					// console.log($(this).find('td').eq(0).text());
					if ($(this).find('td').eq(0).text() != '공지') {
						var data = new Object();
						data.title = $(this).find('td a').eq(0).text();
						data.url = 'http://me.hanyang.ac.kr/ko/cmnt/mann/views/findCmntInfo.do?boardSeq='+$(this).find('td input').eq(0).attr('value')+'&searchType=&searchVal=&menuCd=mann&catCd=&page=1';
						data.source = '기계공학부'
						data.category = '공지사항';
						// data.time=$(this).find('td').eq(3).text().replace(/\./gi, '-');
						data.time = crawlingTime;
						data.json='';
						
						sqlList.push([data.title, data.url, data.source, data.category, data.time, data.json]);
					}
				});
	
				var connection = mysql.createConnection({
					host : 'noti.c0pwj79j83nj.ap-northeast-2.rds.amazonaws.com',
					user : 'admin',
					password: 'notinoti',
					port : 3306,
					database : 'noti'
				});
				
	
				connection.connect();
	
				var sql = 'INSERT IGNORE INTO Cards (title, url, source, category, time_, json_) VALUES ?;';
				connection.query(sql, [sqlList],function(err, rows, fields) {
					// connection.end();
					if(err) {
						console.log(err);
					} else {
						console.log(rows);
						if (rows.changedRows != 10){
							var sql = 'SELECT endpointarn, badgeCount FROM PushNoti WHERE megjsh = 1';
							connection.query(sql, function(err, result, fields) {
								if (err) throw err;
								else {
									notification(result, rows, sqlList, connection);
									connection.end();
									meLoop(pagenum+1);
								}
							});
						} else {
							connection.end();
						}
					}
				});
		});
	}

	var currentDate = new Date();
	var currentYear = currentDate.getFullYear();
	var currentDay = String(currentDate.getDate()).padStart(2, '0');
	var currentMonth = String(currentDate.getMonth() + 1).padStart(2, '0');

	function bsLoop(pagenum) {
		const url = 'https://biz.hanyang.ac.kr/board/bbs/board.php?bo_table=m4111&page=' + pagenum;
		console.log(url)

		var sqlList = new Array();
		request({url: url,encoding: null},
			function (error, res, body) {
				console.log('bsPage' + pagenum);
				const $ = cheerio.load(iconv.decode(body, 'utf-8'));
				
				// console.log($('.board_list tbody').html());
				$('.board_list tbody').find('tr').each(function (index, elem) {
					if (index == 0) return;
					var data = new Object();
					data.title = $(this).find('td a').eq(1).text();
					var rex = /wr_id=|&page/g;
					data.url = 'https://biz.hanyang.ac.kr/board/bbs/board.php?bo_table=m4111&wr_id=' + $(this).find('td a').eq(1).attr('href').split(rex)[1]+'&page=1';
					data.source = '경영학부';
					data.category = '공지사항';
					// var cardDate = $(this).find('td').eq(3).text();
					// if (cardDate.charAt(2) == ":") data.time = currentYear.toString().slice(2) + "-" + currentMonth + "-" + currentDay
					// else {
					// 	var cardMonth = cardDate.slice(0,2);
					// 	if (cardMonth > currentMonth) currentYear -= 1;
					// 	currentMonth = cardMonth;
					// 	data.time = currentYear.toString().slice(2) + '-' + cardDate;
					// }
					data.time = crawlingTime;
					data.json = '';
					
					sqlList.push([data.title, data.url, data.source, data.category, data.time, data.json]);
				});

				var connection = mysql.createConnection({
					host : 'noti.c0pwj79j83nj.ap-northeast-2.rds.amazonaws.com',
					user : 'admin',
					password: 'notinoti',
					port : 3306,
					database : 'noti'
				});
				

				connection.connect();

				var sql = 'INSERT IGNORE INTO Cards (title, url, source, category, time_, json_) VALUES ?;';
				connection.query(sql, [sqlList],function(err, rows, fields) {
					// connection.end();
					if(err) {
						console.log(err);
					} else {
						console.log(rows);
						if (rows.changedRows != 25){
							var sql = 'SELECT endpointarn, badgeCount FROM PushNoti WHERE bsgjsh = 1';
							connection.query(sql, function(err, result, fields) {
								if (err) throw err;
								else {
									notification(result, rows, sqlList, connection);
									connection.end();
									bsLoop(pagenum+1);
								}
							});
						} else {
							connection.end();
						}
						
					}
				});
		});
	}

	// function portalInnerLoop(list, i) {
	// 	if (i >= list.length)   return;
	// 	var rex = /gongjiSeq=|&header/g;
	// 	var sqlList = new Array();
	// 	var data = new Object();
	// 	data.title = list[i].title[0];
	// 	data.url = 'https://portal.hanyang.ac.kr/GjshAct/findGongjisahangs.do?pgmId=P308200&menuId=M006263&tk=0be29593626429dfc3f1b618045bc8172b86832df0d333bc0f5db47199b9028a';
	// 	data.source = '한양포털'
	// 	data.category = '';
	// 	var parsedDate = new Date(list[i].pubDate[0]);
	// 	data.time = parsedDate.toISOString().substring(2, 10);
	// 	var jsonList = new Array();
	// 	var jsonObject = new Object();
	// 	jsonObject.GongjiSeq = list[i].link[0].split(rex)[1];
	// 	jsonList.push(jsonObject);
	// 	data.json = JSON.stringify(jsonList);
	
	// 	sqlList.push([data.title, data.url, data.source, data.category, data.time, data.json]);
	
	// 	var connection = mysql.createConnection({
	// 		host : 'noti.c0pwj79j83nj.ap-northeast-2.rds.amazonaws.com',
	// 		user : 'admin',
	// 		password: 'notinoti',
	// 		port : 3306,
	// 		database : 'noti'
	// 	});
		
	
	// 	connection.connect();
	
	// 	var sql = 'INSERT IGNORE INTO Cards (title, url, source, category, time_, json_) VALUES (?);';
	// 	connection.query(sql, sqlList,function(err, rows, fields) {
	// 		connection.end();
	// 		if(err) {
	// 			console.log(err);
	// 		} else {
	// 			console.log(rows);
	// 			if (rows.affectedRows == 0) return;
	// 			portalInnerLoop(list, i + 1);
	// 		}
	// 	});
	// }
	
	// function portalLoop() {
	// 	const url = 'https://portal.hanyang.ac.kr/GjshAct/viewRSS.do?gubun=rss';
	// 	console.log(url)
	// 	request({url: url, encoding: null},
	// 		function (error, res, body) {
	// 			console.log('portal');
	// 			var body = iconv.decode(res.body, 'utf8');
	
	// 			var parser = new xml2js.Parser();
	// 			parser.parseString(body, function (err, result) {
	// 				var json = JSON.parse(JSON.stringify(result));
	// 				var list = json['rss'].channel[0].item;
	
	// 				portalInnerLoop(list, 0);
	// 			});
	// 		});
	// }



	function csLoop(pagenum, boardname) {
		const url = 'http://cs.hanyang.ac.kr/board/'+ boardname +'.php?ptype=&page='+pagenum+'&code=notice';
		console.log(url)
		request({url: url,encoding: null},
			function (error, res, body) {
				console.log("csPage" + pagenum);
				if (error)  console.log(error)
				const $ = cheerio.load(iconv.decode(body, 'EUC-KR'));

				var resultList = new Array();
				var sqlList = new Array();
				$('.bbs_con tbody').find('tr').each(function (index, elem) {
					if ($(this).find('td').eq(1).text() != '[공지]') {
						var data = new Object();
						data.title = $(this).find('td').eq(2).find('a').text()
						let href = $(this).find('td').eq(2).find('a').attr('href')
						if (href.startsWith("http://")||href.startsWith("https://")) {
							data.url = $(this).find('td').eq(2).find('a').attr('href');
						}else {
							var rex = /idx=|&page/g;
							var idx = $(this).find('td').eq(2).find('a').attr('href').split(rex)[1];
							data.url = 'http://cs.hanyang.ac.kr/board/'+ boardname +'.php?ptype=view&idx='+idx+'&page=1&code=notice';
						}
						// data.writer = $(this).find('td').eq(3).text()
						data.source = '컴퓨터소프트웨어학부';
                    	data.category = boardname == 'info_board' ? '학사일반' : '취업정보';
						// var time = $(this).find('td').eq(4).text()
						// data.time = time.substring(0,2) + '-' + time.substring(3,5) + '-' + time.substring(6,8)
						data.time = crawlingTime;
						data.json = null

						resultList.push(data);
						sqlList.push([data.title, data.url, data.source, data.category, data.time, data.json]);
					}
				});

				// console.log(sqlList);

				var connection = mysql.createConnection({
					host : 'noti.c0pwj79j83nj.ap-northeast-2.rds.amazonaws.com',
					user : 'admin',
					password: 'notinoti',
					port : 3306,
					database : 'noti'
				});
				

				connection.connect();

				var sql = 'INSERT IGNORE INTO Cards (title, url, source, category, time_, json_) VALUES ?;';
				connection.query(sql, [sqlList],function(err, rows, fields) {
					// connection.end();
					if(err) {
						console.log(err);
					} else {
						console.log(rows);
						if (rows.changedRows != 20){
							var sql = 'SELECT endpointarn, badgeCount FROM PushNoti WHERE ' + (boardname == 'info_board' ? 'cshsib' : 'cscujb') +' = 1';
							connection.query(sql, function(err, result, fields) {
								if (err) throw err;
								else {
									notification(result, rows, sqlList, connection);
									connection.end();
									csLoop(pagenum + 1, boardname);
								}
							});
						} else if (boardname == 'job_board') {
							connection.end();
							callback(null, response);
						} else {
							connection.end();
						}
					}
				});

				const response = {
					statusCode: 200,
					body: JSON.stringify({
						message: JSON.stringify(resultList)
					}),
				};
				
				//  console.log(response);
		});
	}

	function notification(result, rows, sqlList, connection) {
		for (var cardIndex = 0; cardIndex < rows.affectedRows; cardIndex++) {
			for(var i in result) {
				// Create publish parameters
				result[i].badgeCount += 1;
				var params = {
					MessageStructure: "json",
					Message: JSON.stringify({
						"APNS": "{\"aps\":{\"alert\":{\"title\" : \""+ sqlList[cardIndex][3] +"-"+sqlList[cardIndex][2]+"\", \"body\" : \""+ sqlList[cardIndex][0] +"\"}, \"sound\" : \"default\", \"badge\": "+ result[i].badgeCount +"}, \"url\" : \""+sqlList[cardIndex][1]+"\"}"
					}), /* required */
					TargetArn: result[i].endpointarn
				};
			
				// Create promise and SNS service object
				var publishTextPromise = new AWS.SNS({apiVersion: '2010-03-31'}).publish(params).promise();
				
				console.log('endpointarn: ' + result[i].endpointarn);
				// Handle promise's fulfilled/rejected states
				publishTextPromise.then(
					function(data) {
					console.log(`Message ${params.Message} send sent to the topic ${params.TopicArn}`);
					console.log("MessageID is " + data.MessageId);
					}).catch(
					function(err) {
					console.error(err, err.stack);
					});

				var sql = 'UPDATE PushNoti SET badgeCount = '+ result[i].badgeCount +' WHERE endpointarn = "' + result[i].endpointarn + '"' 
				connection.query(sql, function(err, result, fields) {
					if (err) throw err;
					else {
						console.log(result);
					}
				});
			}
		}
	}

	
	// request('http://cs.hanyang.ac.kr/board/info_board.php?ptype=&page=1&code=notice', function (error, res, body) {
	

	// const $ = cheerio.load(iconv.decode(body, 'EUC-KR'));

	// let result = $('.bbs_con')
	// const response = {
	// 	statusCode: 200,
	// 	body: JSON.stringify({
	// 			message: result.text(),
	// 			input: event,
	// 		}),
	// };
	// callback(null, response);
	// });
}