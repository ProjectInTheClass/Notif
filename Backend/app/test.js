'use strict';

const request = require('request');
const cheerio = require('cheerio');
const iconv = require('iconv-lite');
const mysql = require('mysql');
const xml2js = require('xml2js');
const AWS = require('aws-sdk');

AWS.config.update({region: 'ap-northeast-2'});


csLoop(1, 'info_board');
csLoop(1, 'job_board');
portalLoop();
bsLoop(1);
meLoop(1);
hyLoop(1, 1);


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
                // connection.end();
                if(err) {
                    connection.end();
                    console.log(err);
                } else {
                    console.log(rows);
                    if (rows.changedRows != 10){
                        // if(pagenum == 3) return;
                        // var connection = mysql.createConnection({
                        //     host : 'noti.c0pwj79j83nj.ap-northeast-2.rds.amazonaws.com',
                        //     user : 'admin',
                        //     password: 'notinoti',
                        //     port : 3306,
                        //     database : 'noti'
                        // });

                        var sql = 'SELECT endpointarn FROM PushNoti WHERE ' +dbCategories[category]+' = 1';
                        connection.query(sql, function(err, result, fields) {
                            connection.end();
                            if (err) throw err;
                            else {
                                for(var i in result) {
                                    // Create publish parameters
                                    var params = {
                                        MessageStructure: "json",
                                        Message: JSON.stringify({
                                        "APNS_SANDBOX": "{\"aps\":{\"alert\":{\"title\" : \""+ sqlList[i][3] +"-한양대학교\", \"body\" : \""+ sqlList[i][0] +"\"}}}"
                                        }), /* required */
                                        TargetArn: result[i].endpointarn
                                    };
                                
                                    // Create promise and SNS service object
                                    var publishTextPromise = new AWS.SNS({apiVersion: '2010-03-31'}).publish(params).promise();
                                    
                                    // Handle promise's fulfilled/rejected states
                                    publishTextPromise.then(
                                        function(data) {
                                        console.log(`Message ${params.Message} send sent to the topic ${params.TopicArn}`);
                                        console.log("MessageID is " + data.MessageId);
                                        }).catch(
                                        function(err) {
                                        console.error(err, err.stack);
                                        });
                                }
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
                // connection.end();
                if(err) {
                    console.log(err);
                } else {
                    console.log(rows);
                    if (rows.changedRows != 10){

                        var sql = 'SELECT endpointarn FROM PushNoti WHERE megjsh = 1';
                        connection.query(sql, function(err, result, fields) {
                            connection.end();
                            if (err) throw err;
                            else {
                                for(var i in result) {
                                    // Create publish parameters
                                    var params = {
                                        MessageStructure: "json",
                                        Message: JSON.stringify({
                                        "APNS_SANDBOX": "{\"aps\":{\"alert\":{\"title\" : \""+ sqlList[i][3] +"-기계공학부\", \"body\" : \""+ sqlList[i][0] +"\"}}}"
                                        }), /* required */
                                        TargetArn: result[i].endpointarn
                                    };
                                
                                    // Create promise and SNS service object
                                    var publishTextPromise = new AWS.SNS({apiVersion: '2010-03-31'}).publish(params).promise();
                                    
                                    // Handle promise's fulfilled/rejected states
                                    publishTextPromise.then(
                                        function(data) {
                                        console.log(`Message ${params.Message} send sent to the topic ${params.TopicArn}`);
                                        console.log("MessageID is " + data.MessageId);
                                        }).catch(
                                        function(err) {
                                        console.error(err, err.stack);
                                        });
                                }
                                meLoop(pagenum+1);
                            }
                        });
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
                // connection.end();
                if(err) {
                    console.log(err);
                } else {
                    console.log(rows);
                    if (rows.changedRows != 25){
                        var sql = 'SELECT endpointarn FROM PushNoti WHERE bsgjsh = 1';
                        connection.query(sql, function(err, result, fields) {
                            connection.end();
                            if (err) throw err;
                            else {
                                for(var i in result) {
                                    // Create publish parameters
                                    var params = {
                                        MessageStructure: "json",
                                        Message: JSON.stringify({
                                        "APNS_SANDBOX": "{\"aps\":{\"alert\":{\"title\" : \""+ sqlList[i][3] +"-경영학부\", \"body\" : \""+ sqlList[i][0] +"\"}}}"
                                        }), /* required */
                                        TargetArn: result[i].endpointarn
                                    };
                                
                                    // Create promise and SNS service object
                                    var publishTextPromise = new AWS.SNS({apiVersion: '2010-03-31'}).publish(params).promise();
                                    
                                    // Handle promise's fulfilled/rejected states
                                    publishTextPromise.then(
                                        function(data) {
                                        console.log(`Message ${params.Message} send sent to the topic ${params.TopicArn}`);
                                        console.log("MessageID is " + data.MessageId);
                                        }).catch(
                                        function(err) {
                                        console.error(err, err.stack);
                                        });
                                }
                                bsLoop(pagenum+1);
                            }
                        });
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
    // const url = 'https://portal.hanyang.ac.kr/sso/lgin.do';
    // request({
    //     url: url,
    //     method: 'POST',
    //     // headers: {
    //     //     "Cookie": "ipSecGb=MQ%3D%3D; savedUserId=anVucm9vdDA5MDk%3D; WMONID=GQOvjLQn9EC; HYIN_JSESSIONID=tKgxq9hHchZjg48jxEDNXGgyBn-zjBNY3LXGhGaQ-wD4VqbXc4Nu!942074279!220462321; newLoginStatus=PORTAL8e1d20d1-e3df-4118-9884-5d5e75ed4505; COM_JSESSIONID=C1Uxq-QZlU2oBt_tL9XW_qLQbXuIEI4jg9UJsp4RI8eUfub3yGjc!-1908862846!2143065293; _SSO_Global_Logout_url=get%5Ehttps%3A%2F%2Fportal.hanyang.ac.kr%2Flgot.do%24get%5Ehttps%3A%2F%2Fportal.hanyang.ac.kr%2Fhaksa%2Flgot.do%24; HAKSA_JSESSIONID=D0oxq-o982mmyEIviMiFnft8hPXwrAneB_oFB5bbyH-mmR0y7guZ!-1049547854!193342111"
    //     // },
    //     form: {
    //         'loginGb': '1',
    //         'systemGb': 'PORTAL',
    //         'ipSecGb': '1',
    //         'returl': 'https://portal.hanyang.ac.kr/port.do',
    //         'signeddata': '',
    //         'challenge': '',
    //         'symm_enckey': '',
    //         'userId': '579b0e1bc633c7132bacb287696',
    //         'password': '44bf566127f77cad5f6f7a25b5e7a232f8e0a81775be49de3a547d1e3155edcda5acdad15ae658379216c9dabef519045e36b8d19e8d8930fe3ed0aabbf4d7c9',
    //         'keyNm': 'sso_002'
    //         }
    //     },
    //     function (error, res, body) {
    //         console.log(res.headers);
    //         // const url2 = 'https://portal.hanyang.ac.kr/GjshAct/findGongjisahangs.do?gongjiGb=&portalCampusCd=null&pgmId=P308200&menuId=M006263&tk=0be29593626429dfc3f1b618045bc8172b86832df0d333bc0f5db47199b9028a';
    //         // request({
    //         //     url: url2,
    //         //     method: 'POST',
    //         //     headers: {
    //         //         "Cookie": "ipSecGb=MQ%3D%3D; savedUserId=anVucm9vdDA5MDk%3D; WMONID=GQOvjLQn9EC; HYIN_JSESSIONID=tKgxq9hHchZjg48jxEDNXGgyBn-zjBNY3LXGhGaQ-wD4VqbXc4Nu!942074279!220462321; newLoginStatus=PORTAL8e1d20d1-e3df-4118-9884-5d5e75ed4505; COM_JSESSIONID=C1Uxq-QZlU2oBt_tL9XW_qLQbXuIEI4jg9UJsp4RI8eUfub3yGjc!-1908862846!2143065293; _SSO_Global_Logout_url=get%5Ehttps%3A%2F%2Fportal.hanyang.ac.kr%2Flgot.do%24get%5Ehttps%3A%2F%2Fportal.hanyang.ac.kr%2Fhaksa%2Flgot.do%24; HAKSA_JSESSIONID=D0oxq-o982mmyEIviMiFnft8hPXwrAneB_oFB5bbyH-mmR0y7guZ!-1049547854!193342111"
    //         //     },
    //         //     json: {
    //         //         'skipRows': '0',
    //         //         'maxRows': '10',
    //         //         'gsearch': '2',
    //         //         'param': ''
    //         //     }
    //         // },
    //         // function (error, res, body) {
    //         //     // console.log(res)
    //         // });
    //     });


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
					// connection.end();
					if(err) {
						console.log(err);
					} else {
						console.log(rows);
						if (rows.changedRows != 20){
							var sql = 'SELECT endpointarn FROM PushNoti WHERE ' + (boardname == 'info_board' ? 'cshsib' : 'cscujb') +' = 1';
							connection.query(sql, function(err, result, fields) {
								connection.end();
								if (err) throw err;
								else {
									for(var i in result) {
										// Create publish parameters
										var params = {
											MessageStructure: "json",
											Message: JSON.stringify({
											"APNS_SANDBOX": "{\"aps\":{\"alert\":{\"title\" : \""+ sqlList[i][3] +"-컴퓨터소프트웨어학부\", \"body\" : \""+ sqlList[i][0] +"\"}}}"
											}), /* required */
											TargetArn: result[i].endpointarn
										};
									
										// Create promise and SNS service object
										var publishTextPromise = new AWS.SNS({apiVersion: '2010-03-31'}).publish(params).promise();
										
										// Handle promise's fulfilled/rejected states
										publishTextPromise.then(
											function(data) {
											console.log(`Message ${params.Message} send sent to the topic ${params.TopicArn}`);
											console.log("MessageID is " + data.MessageId);
											}).catch(
											function(err) {
											console.error(err, err.stack);
											});
									}
									csLoop(pagenum + 1, boardname);
								}
							});
                        } else if (boardname == 'job_board') {
                            connection.end();
							process.exit();
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