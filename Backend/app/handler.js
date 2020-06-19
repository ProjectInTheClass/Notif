'use strict';

const request = require('request');
const cheerio = require('cheerio');
const iconv = require('iconv-lite');
const mysql = require('mysql');
const xml2js = require('xml2js');

module.exports.crawler = (event, context, callback) => {
	csLoop(1, 'info_board');
	csLoop(1, 'job_board');
	hyLoop(1, 1);
	// portalLoop();
	bsLoop(1);
	meLoop(1);

	function hyLoop(category, page) {
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
					switch (category) {
						case 1: 
							data.category = '학사'
							break;
						case 2:
							data.category = '입학'
							break;
						case 3:
							data.category = '모집/채용'
							break;
						case 4:
							data.category = '사회봉사'
							break;
						case 5:
							data.category = '일반'
							break;
						case 6:
							data.category = '산학/연구'
							break;
						case 7:
							data.category = '행사'
							break;
						case 8:
							data.category = '장학'
							break;
						case 9:
							data.category = '학회/세미나'
							break;
						default:
							data.category = ''
					}
					data.time = $(this).find('.notice-date').eq(0).text().trim().replace(/\./gi, '-').substring(2,10)
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
					connection.end();
					if(err) {
						console.log(err);
					} else {
						console.log(rows);
						if (rows.changedRows != 10){
							// if(pagenum == 3) return;
							hyLoop(category, page+1);
						} else {
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
						data.time=$(this).find('td').eq(3).text().replace(/\./gi, '-');
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
					connection.end();
					if(err) {
						console.log(err);
					} else {
						console.log(rows);
						if (rows.changedRows != 10){
							// if(pagenum == 3) return;
							pagenum += 1;
							meLoop(pagenum);
						}
						
					}
				});
		});
	}

	var currentDate = new Date();
	var currentYear = currentDate.getFullYear();
	var currentMonth = currentDate.getMonth() + 1;

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
					var cardDate = $(this).find('td').eq(3).text();
					var cardMonth = cardDate.slice(0,2) * 1;
					if (cardMonth > currentMonth) currentYear -= 1;
					currentMonth = cardMonth;
					data.time = currentYear.toString().slice(2) + '-' + cardDate;
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
					connection.end();
					if(err) {
						console.log(err);
					} else {
						console.log(rows);
						if (rows.changedRows != 25){
							// if(pagenum == 3) return;
							pagenum += 1;
							bsLoop(pagenum);
						}
						
					}
				});
		});
	}

	function portalInnerLoop(list, i) {
		if (i >= list.length)   return;
		var rex = /gongjiSeq=|&header/g;
		var sqlList = new Array();
		var data = new Object();
		data.title = list[i].title[0];
		data.url = 'https://portal.hanyang.ac.kr/GjshAct/findGongjisahangs.do?pgmId=P308200&menuId=M006263&tk=0be29593626429dfc3f1b618045bc8172b86832df0d333bc0f5db47199b9028a';
		data.source = '한양포털'
		data.category = '';
		var parsedDate = new Date(list[i].pubDate[0]);
		data.time = parsedDate.toISOString().substring(2, 10);
		var jsonList = new Array();
		var jsonObject = new Object();
		jsonObject.GongjiSeq = list[i].link[0].split(rex)[1];
		jsonList.push(jsonObject);
		data.json = JSON.stringify(jsonList);
	
		sqlList.push([data.title, data.url, data.source, data.category, data.time, data.json]);
	
		var connection = mysql.createConnection({
			host : 'noti.c0pwj79j83nj.ap-northeast-2.rds.amazonaws.com',
			user : 'admin',
			password: 'notinoti',
			port : 3306,
			database : 'noti'
		});
		
	
		connection.connect();
	
		var sql = 'INSERT IGNORE INTO Cards (title, url, source, category, time_, json_) VALUES (?);';
		connection.query(sql, sqlList,function(err, rows, fields) {
			connection.end();
			if(err) {
				console.log(err);
			} else {
				console.log(rows);
				if (rows.affectedRows == 0) return;
				portalInnerLoop(list, i + 1);
			}
		});
	}
	
	function portalLoop() {
		const url = 'https://portal.hanyang.ac.kr/GjshAct/viewRSS.do?gubun=rss';
		console.log(url)
		request({url: url, encoding: null},
			function (error, res, body) {
				console.log('portal');
				var body = iconv.decode(res.body, 'utf8');
	
				var parser = new xml2js.Parser();
				parser.parseString(body, function (err, result) {
					var json = JSON.parse(JSON.stringify(result));
					var list = json['rss'].channel[0].item;
	
					portalInnerLoop(list, 0);
				});
			});
	}



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
						if ($(this).find('td').eq(2).find('a').attr('href').startsWith("http://")) {
							data.url = $(this).find('td').eq(2).find('a').attr('href');
						}else {
							var rex = /idx=|&page/g;
							var idx = $(this).find('td').eq(2).find('a').attr('href').split(rex)[1];
							data.url = 'http://cs.hanyang.ac.kr/board/'+ boardname +'.php?ptype=view&idx='+idx+'&page=1&code=notice';
						}
						// data.writer = $(this).find('td').eq(3).text()
						data.source = '컴퓨터소프트웨어학부';
                    	data.category = boardname == 'info_board' ? '학사일반' : '취업정보';
						var time = $(this).find('td').eq(4).text()
						data.time = time.substring(0,2) + '-' + time.substring(3,5) + '-' + time.substring(6,8)
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
					connection.end();
					if(err) {
						console.log(err);
					} else {
						console.log(rows);
						if (rows.changedRows != 20){
							pagenum += 1;
							csLoop(pagenum, boardname);
						} else if (boardname == 'job_board') {
							callback(null, response);
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