const mysql = require('mysql');

var mysqlPool = mysql.createPool({
    host : 'noti.c0pwj79j83nj.ap-northeast-2.rds.amazonaws.com',
    user : 'admin',
    password: 'notinoti',
    port : 3306,
    database : 'noti',
    connectionLimit : 100
});

exports.handler = function (event, context, callback) {
    context.callbackWaitsForEmptyEventLoop = false;
    
    var time = event['params']['path']['time'];
    var url = event['params']['path']['url'];
    var number = event['params']['path']['number'];
    var topWeekDate = event['params']['path']['topWeekDate'];

    if (url) {
        // var encodedURL = new Buffer(url, 'base64');
        var sql = 'UPDATE Cards SET favorite = favorite + ('+ number +') where url = \"' + decodeURIComponent(url) +'\"';
        console.log(sql);
            
        mysqlPool.getConnection(function (err, connection) {
            if(err !== null)    return console.log(err)
            connection.query(sql, function (error, rows, field) {
                connection.release()
                if (error != null)  console.log(error);
                else{
                    const response = {
                        statusCode: 200,
                        body : JSON.stringify({
                            message: rows
                        })
                    }
                    callback(null, response)
                }
            })
        });
        
    } else if (topWeekDate) {
        var date = new Date("20"+topWeekDate);
        date = new Date(date.getTime() - (3600 * 24 * 7 * 1000));
        var year = date.getFullYear().toString().slice(2);
        var month = date.getMonth() + 1;
        month = (month < 10 ? "0" : "") + month;
        var day  = date.getDate();
    	day = (day < 10 ? "0" : "") + day;
    	date = year + "-" + month + "-" + day;
    	
    	var sql = 'SELECT * FROM Cards where time_ >= \'' + date +'\' AND favorite > 0 ORDER BY favorite DESC;';
    	
    	mysqlPool.getConnection(function (err, connection) {
            if(err !== null)    return console.log(err)
            connection.query(sql, function (error, rows, field) {
                connection.release()
                if (error != null)  console.log(error);
                else{
                    const response = {
                        statusCode: 200,
                        body : JSON.stringify({
                            message: rows
                        })
                    }
                    callback(null, response)
                }
            })
        });
    	
    } else {
        var sql = 'SELECT * FROM Cards where time_ >= \'' + time +'\';';
        
        mysqlPool.getConnection(function (err, connection) {
            if(err !== null)    return console.log(err)
            connection.query(sql, function (error, rows, field) {
                connection.release()
                if (error != null)  console.log(error);
                else{
                    const response = {
                        statusCode: 200,
                        body : JSON.stringify({
                            message: rows
                        })
                    }
                    callback(null, response)
                }
            })
        });
    }
}