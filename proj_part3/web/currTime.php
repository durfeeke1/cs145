<?php # currTime.php - show current time
  
  include ('./sqlitedb.php');
?>

<html>
<head>
<title>AuctionBase</title>
</head>

<?php 
  include ('./navbar.html');
?>

<center>
<h3> Current Time </h3> 

<?php
  $query = "select curr_time from Time";
  
  try {
    $result = $db->query($query);
    $row = $result->fetch();
    echo "Current time is: ".htmlspecialchars($row["curr_time"]);
  } catch (PDOException $e) {
    echo "Current time query failed: " . $e->getMessage();
  }

  $_SESSION['Time']=htmlspecialchars($row["curr_time"]);  
  $db = null;
?>

</center>
</html>

