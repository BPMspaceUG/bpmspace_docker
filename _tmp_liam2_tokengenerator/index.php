<?php
    // Includes    
    define("AUTH_KEY", "liam2_key");

    $origin = isset($_GET['origin']) ? $_GET['origin'] : '--invalid--';

    require_once(__DIR__.'/class-auth.php');
    function getPOSTParamSecure($param) {
        if (isset($_POST[$param])) return $_POST[$param];
        return null;
    }
    // Parameters
    $user = md5(getPOSTParamSecure('usr'));
    $pass = md5(getPOSTParamSecure('pwd'));

    $login_successful = false;
    if (!is_null($user) && !is_null($pass)) {
        // For Testing
        if ($user == '74cc1c60799e0a786ac7094b532f01b1' && $pass == '7b24afc8bc80e548d66c4e7ff72171c5') {
            $user_id = 23;
            $firstname = 'Admin';
            $lastname = 'Admin';
            $login_successful = true;
        }        
        // Set Token when Login was successful
        if ($login_successful) {
            // Generate Token
            $token_data = array();
            $token_data['uid'] = $user_id;
            $token_data['firstname'] = $firstname;
            $token_data['lastname'] = $lastname;
            // Token vaild for 60min
            $token_data['exp'] = time() + 60 /*sec*/ * 60 /*min*/ * 24 /*hours*/;
            $token = JWT::encode($token_data, AUTH_KEY);
            echo json_encode(array('success' => 1, 'token' => $token));
            exit();
        } else {
            echo json_encode(array('success' => 0, 'errormsg' => "Login was not successful!"));
            exit();
        }
    }
?>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <title>Login</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css">
    <style>
        html, body {background-color: #372080ff;}
    </style>
  </head>
  <body>
    <div class="container">
        <div class="row mt-5 text-light">
            <div class="col-xs-1 col-md-3 col-lg-4"></div>
            <form class="form col-xs-10 col-md-6 col-lg-4" method="post" action="login.php">
                <h2 class="display-4 mb-4 text-center" style="font-size: 2.5em;">Please login</h2>
                <div class="alert alert-danger errormsg collapse" role="alert"></div>
                <label for="inputEmail">E-Mail Address</label>
                <input type="text" id="inputEmail" name="usr" class="form-control mb-1" placeholder="Email address" required autofocus>
                <label for="inputPassword">Password</label>
                <input type="password" id="inputPassword" name="pwd" class="form-control" placeholder="Password" required>
                <br>
                <button class="btn btn-lg btn-primary mx-auto btn-block w-50 login" type="submit">🤙🏻 Login</button>
            </form>
            <div class="col-xs-1 col-md-3 col-lg-4"></div>
        </div>
    </div>
    <!-- JS -->
    <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
    <script>
        let origin = '<?php echo $origin; ?>';
        // Login Button Click
        $('.login').click(function(e){
            e.preventDefault();
            var u = $('#inputEmail').val();
            var p = $('#inputPassword').val();
            // Request
            $.ajax({
                method: "POST",
                url: 'index.php',
                data: {usr: u, pwd: p}
            }).done(function(r) {
                var data = JSON.parse(r);
                if (data.success === 0) {
                    console.log("Error", data.errormsg);
                    $('.errormsg').text(data.errormsg);
                    $('.errormsg').show();
                } else {
                    // Success
                    console.log("Success");
                    let = url = origin + '?token=' + data.token;                    
                    if (origin != '--invalid--') 
                        document.location.assign(origin + '?token=' + data.token);
                    else {
                        $('.errormsg').html('<textarea class="w-100">'+data.token+'</textarea>');
                        $('.errormsg').show();
                    }
                }
            });
        })
    </script>
  </body>
</html>