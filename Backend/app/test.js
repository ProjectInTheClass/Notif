'use strict';

const request = require('request');
const cheerio = require('cheerio');
const iconv = require('iconv-lite');
const mysql = require('mysql');


csLoop(1, 'info_board');
csLoop(1, 'job_board');

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
                    data.source = boardname == 'info_board' ? '컴퓨터소프트웨어학부-학사일반' : '컴퓨터소프트웨어학부-취업정보'
                    var time = $(this).find('td').eq(4).text()
                    data.time = time.substring(0,2) + '-' + time.substring(3,5) + '-' + time.substring(6,8)
                    data.json = null

                    resultList.push(data);
                    sqlList.push([data.title, data.url, data.source, data.time, data.json]);
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

            var sql = 'INSERT IGNORE INTO Cards (title, url, source, time_, json_) VALUES ?;';
            connection.query(sql, [sqlList],function(err, rows, fields) {
                connection.end();
                if(err) {
                    console.log(err);
                } else {
                    console.log(rows);
                    if (rows.changedRows != 20){
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

