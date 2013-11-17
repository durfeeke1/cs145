<?php # currtime.php - show current time
  
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
<h3> Users </h3> 

<?php
 /* $query = "SELECT UserID FROM User WHERE UserId ="."'007cowboy'";
  
  try {
    $result = $db->query($query);
    $row = $result->fetch();
    echo "Current time is: ".htmlspecialchars($row["UserID"]);
  } catch (PDOException $e) {
    echo "Current time query failed: " . $e->getMessage();
  }*/

  try{
  
  // Start a transaction
  $db->beginTransaction();

  //Run Ccmmand
  $UserID = '007cowboy'; 

  $com1 = "SELECT UserID FROM User WHERE UserId = :UserID ";
  $result1 = $db->prepare($com1);
  $result1->execute(array(':UserID' => $UserID));
  
  $db->commit();
  echo "success!";

  }catch (Exception $e) {
      try {
        $db->rollBack();
      } catch (PDOException $pe) {}
      echo "Transaction failed: " . $e->getMessage();
    } 
  
  $db = null;

  $row = $result1->fetch();
   echo "Current time is: ".htmlspecialchars($row["UserID"]);

?>

</center>
</html>

