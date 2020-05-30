'use strict';

const request = require('request');
const cheerio = require('cheerio');
const iconv = require('iconv-lite');
const mysql = require('mysql');
const xml2js = require('xml2js');



csLoop(1, 'info_board');
csLoop(1, 'job_board');
//portalLoop();
bsLoop(1);


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
                data.category = $(this).find('td a').eq(0).text();
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
            console.log(pagenum)
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
                    data.json = '';

                    resultList.push(data);
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
                    if (rows.changedRows != 20){
                        // if(pagenum == 3) return;
                        pagenum += 1;
                        csLoop(pagenum, boardname);
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

