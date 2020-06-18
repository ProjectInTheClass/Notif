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