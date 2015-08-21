<?php
//request data from the database
//code here to connect to database and get the data you want

/* Example JSON format
{
  "item1": "Battleship",
  "item2": "100,25",
  "item3": "12 knots"
}
*/

$item1 = "Battleship";
$item2 = "100, 25";
$item3 = "12 knots";

//return in JSON format
echo "{";
echo "item1: ", json_encode($item1);
echo "item2: ", json_encode($item2);
echo "item3: ", json_encode($item3);
echo "}";
?>
