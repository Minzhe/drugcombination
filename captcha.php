<?php
//set session
session_start();

$image = imagecreatetruecolor(100, 30);  //set image size function
//set verification code color imagecolorallocate(int im, int red, int green, int blue);
$bgcolor = imagecolorallocate($image, 255, 255, 255); //#ffffff
//fill region int imagefill(int im, int x, int y, int col) (x,y) color region,col = color
imagefill($image, 0, 0, $bgcolor);
//set variable
$captcha_code = "";
//7>generate random number and letter
for ($i = 0; $i < 4; $i++) {
    //set font size
    $fontsize = 17;
    //set font color, random color
    $fontcolor = imagecolorallocate($image, rand(30, 200), rand(30, 120), rand(30, 120));   //0-120 dark color
    //set random value range, remove eoor-prone 0 and o
    $data = 'abcdefghigkmnpqrstuvwxy3456789';
    //get value
    $fontcontent = substr($data, rand(0, strlen($data)), 1);

    $captcha_code .= $fontcontent;
    //set coordinate
    $x = ($i * 100 / 4) + rand(5, 10);
    $y = rand(5, 10);

    imagestring($image, $fontsize, $x, $y, $fontcontent, $fontcolor);
}
//store into session
$_SESSION['authcode'] = $captcha_code;
//increase background complexity
for ($i = 0; $i < 200; $i++) {
    //set dot color, 50-200 color lighter than numbers
    $pointcolor = imagecolorallocate($image, rand(50, 200), rand(50, 200), rand(50, 200));
    //imagesetpixel draw a single pixel
    imagesetpixel($image, rand(1, 99), rand(1, 29), $pointcolor);
}
////9>increase background complexity set horizontal line
//for($i=0;$i<4;$i++){
//    //set line color
//    $linecolor = imagecolorallocate($image,rand(80,220), rand(80,220),rand(80,220));
//    //set line by two end points
//    imageline($image,rand(1,99), rand(1,29),rand(1,99), rand(1,29),$linecolor);
//}

//2>set header，image/png
header('Content-Type: image/png');
//3>imagepng() create png function
imagepng($image);
//4>imagedestroy() end function, destroy $image
imagedestroy($image);
?>