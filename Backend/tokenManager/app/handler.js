const mysql = require('mysql');


var mysqlPool = mysql.createPool({
    host : 'noti.c0pwj79j83nj.ap-northeast-2.rds.amazonaws.com',
    user : 'admin',
    password: 'notinoti',
    port : 3306,
    database : 'noti',
    connectionLimit : 100
});
				
module.exports.hello = (event, context, callback) => {
  context.callbackWaitsForEmptyEventLoop = false;
    
  var token = event['params']['path']['token'];
  var channelName = event['params']['path']['channel'];
  var value = event['params']['path']['value'];
  var badgeCount = event['params']['path']['badgecount'];
  
  console.log('token@@@@@@@ ' + token)
  
  if (badgeCount) {
    console.log("badgecount");
    var sql = 'UPDATE PushNoti SET badgeCount = ' + badgeCount + ' WHERE token = "' + token +'"';
    console.log(sql);
    mysqlPool.getConnection(function(err, connection) {
       if (err !== null) return console.log(err);
       connection.query(sql,function (error, rows, field) {
          connection.release();
          if (error != null)  console.log(error);
          else {
              const response = {
                  statusCode: 200,
                  body : JSON.stringify({
                      message: rows
                  })
              }
              callback(null, response);
          }
       });
    });
  }
  else if (!channelName) {
    console.log("create token")
    var AWS = require('aws-sdk');
    
    var params = {
      PlatformApplicationArn: 'arn:aws:sns:ap-northeast-2:199206410574:app/APNS_SANDBOX/Noti', /* required */
      Token: token, /* required */
    }
    
    // Create promise and SNS service object
    var publishTextPromise = new AWS.SNS({apiVersion: '2010-03-31'}).createPlatformEndpoint(params).promise();
    
    // Handle promise's fulfilled/rejected states
    publishTextPromise.then(
      function(data) {
        console.log("EndpointArn is " + data.EndpointArn);
        var sql = 'INSERT IGNORE INTO PushNoti (token, endpointarn) VALUES (\'' + token +'\', \'' + data.EndpointArn + '\')';
        mysqlPool.getConnection(function (err, connection) {
          if (err !== null) return console.log(err)
          connection.query(sql, function (error, rows, field) {
            connection.release();
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
        });
        });
      }).catch(
        function(err) {
        console.error(err, err.stack);
      });
  } else {
    console.log("set push notification")
    var sql = 'UPDATE PushNoti SET ' + channelName + ' = \'' + value + '\' WHERE token = \'' + token + '\'';
    console.log(sql)
    mysqlPool.getConnection(function (err, connection) {
      if (err !== null) return console.log(err)
      connection.query(sql, function (error, rows, field) {
        connection.release();
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
    });
    });
  }
};
